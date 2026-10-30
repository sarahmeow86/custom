#!/usr/bin/env python3
"""Bump the overlay's packages to their latest upstream version.

Each package in packages.json names where its upstream releases live. For
every package behind upstream the newest ebuild is renamed to the new
version (old one dropped), Cargo crates are regenerated when needed, then
Manifest and md5-cache are updated and pkgcheck must not report anything
the previous version did not. Every bump is one commit. Packages marked
"review" go to their own branch with a pull request instead of master.

  autobump.py --check            only report what is outdated
  autobump.py                    bump and commit locally
  autobump.py --push             bump, commit, push, open PRs/issues (CI)
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.parse
import urllib.request
from pathlib import Path

from portage.versions import vercmp

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
VERSION_RE = re.compile(r"^v?(\d+(?:\.\d+)*)$")


def log(msg):
    print(msg, flush=True)


def run(*cmd, cwd=REPO, env=None, capture=False, check=True):
    full_env = dict(os.environ, **(env or {}))
    res = subprocess.run(cmd, cwd=cwd, env=full_env, text=True,
                         stdout=subprocess.PIPE if capture else None,
                         stderr=subprocess.STDOUT if capture else None)
    if check and res.returncode != 0:
        out = res.stdout or ""
        raise RuntimeError(f"{' '.join(map(str, cmd))} failed ({res.returncode})\n{out[-4000:]}")
    return res.stdout


def github_token():
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if not token and shutil.which("gh"):
        res = subprocess.run(["gh", "auth", "token"], text=True, capture_output=True)
        token = res.stdout.strip() if res.returncode == 0 else None
    return token


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "custom-overlay-autobump"})
    if url.startswith("https://api.github.com/") and (token := github_token()):
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def gh_api(path):
    return json.loads(fetch(f"https://api.github.com/{path}"))


def newest(versions):
    best = None
    for v in versions:
        if best is None or vercmp(v, best) > 0:
            best = v
    return best


def upstream_brave(cp, cfg, current):
    pn = cp.split("/")[1]
    found = []
    for page in (1, 2, 3):
        for rel in gh_api(f"repos/brave/brave-browser/releases?per_page=100&page={page}"):
            if not (rel.get("name") or "").startswith(cfg["channel"] + " "):
                continue
            m = VERSION_RE.match(rel["tag_name"])
            if not m:
                continue
            ver = m.group(1)
            assets = {a["name"] for a in rel["assets"]}
            needed = {f"{pn}_{ver}_{arch}.deb{ext}"
                      for arch in cfg["arches"] for ext in ("", ".sha256", ".sha256.asc")}
            if needed <= assets:
                found.append(ver)
        if found:
            break
    return newest(found), {}


def upstream_github_release(cp, cfg, current):
    tag = gh_api(f"repos/{cfg['repo']}/releases/latest")["tag_name"]
    m = VERSION_RE.match(tag)
    return (m.group(1) if m else None), {}


def upstream_github_tag(cp, cfg, current):
    tags = gh_api(f"repos/{cfg['repo']}/tags?per_page=100")
    return newest(m.group(1) for t in tags if (m := VERSION_RE.match(t["name"]))), {}


def upstream_github_commit(cp, cfg, current):
    commit = gh_api(f"repos/{cfg['repo']}/commits?per_page=1")[0]
    date = commit["commit"]["committer"]["date"][:10].replace("-", "")
    base = current.split("_p")[0]
    return f"{base}_p{date}", {"COMMIT": commit["sha"]}


def upstream_mint(cp, cfg, current):
    listing = fetch(f"http://packages.linuxmint.com/pool/main/{cfg['pool']}/").decode()
    names = {urllib.parse.unquote(n) for n in re.findall(r'href="([^"]+)"', listing)}
    pattern = re.compile(cfg["pattern"] + "$")
    return newest(m.group(1) for n in names if (m := pattern.match(n))), {}


UPSTREAMS = {
    "brave": upstream_brave,
    "github-release": upstream_github_release,
    "github-tag": upstream_github_tag,
    "github-commit": upstream_github_commit,
    "mint": upstream_mint,
}


def current_ebuild(cp):
    pn = cp.split("/")[1]
    versions = [p.name[len(pn) + 1:-len(".ebuild")]
                for p in (REPO / cp).glob(f"{pn}-*.ebuild")]
    ver = newest(v for v in versions if not v.startswith("9999"))
    return ver, REPO / cp / f"{pn}-{ver}.ebuild"


def pkgcheck_keywords(cp):
    out = run("pkgcheck", "scan", "-R", "FormatReporter", "--format", "{name}", cp,
              capture=True, check=False)
    return {line.strip() for line in out.splitlines() if line.strip()}


def bump(cp, cfg, old, new, extra, distdir):
    pn = cp.split("/")[1]
    before = pkgcheck_keywords(cp)
    old_path = REPO / cp / f"{pn}-{old}.ebuild"
    new_path = REPO / cp / f"{pn}-{new}.ebuild"
    run("git", "mv", old_path, new_path)

    text = new_path.read_text()
    for var, value in extra.items():
        text, n = re.subn(rf'^{var}="[^"]*"', f'{var}="{value}"', text, flags=re.M)
        if n != 1:
            raise RuntimeError(f"{var}= not found exactly once in {new_path.name}")
    new_path.write_text(text)

    if cargo := cfg.get("cargo"):
        with tempfile.TemporaryDirectory() as tmp:
            tarball = Path(tmp) / "src.tar.gz"
            tarball.write_bytes(fetch(cargo["url"].format(ver=new)))
            with tarfile.open(tarball) as tar:
                tar.extractall(tmp, filter="data")
            run("pycargoebuild", "-C", "-M", "-d", distdir, "-i", new_path,
                Path(tmp) / cargo["dir"].format(ver=new))

    run("ebuild", new_path, "manifest", env={"DISTDIR": distdir})
    if (REPO / "metadata" / "md5-cache").is_dir():
        repo_name = (REPO / "profiles" / "repo_name").read_text().strip()
        gentoo = run("portageq", "get_repo_path", "/", "gentoo", capture=True).strip()
        repos_conf = (f"[DEFAULT]\nmain-repo = gentoo\n[gentoo]\nlocation = {gentoo}\n"
                      f"[{repo_name}]\nlocation = {REPO}\nmasters = gentoo\n")
        old_cache = REPO / "metadata" / "md5-cache" / cp.split("/")[0] / f"{pn}-{old}"
        if old_cache.exists():
            run("git", "rm", "-q", old_cache)
        with tempfile.TemporaryDirectory() as cache_dir:
            run("egencache", "--update", "--repo", repo_name, "--cache-dir", cache_dir,
                "--repositories-configuration", repos_conf, cp)

    new_problems = pkgcheck_keywords(cp) - before
    if new_problems:
        out = run("pkgcheck", "scan", cp, capture=True, check=False)
        raise RuntimeError(f"pkgcheck reports new problems: {', '.join(sorted(new_problems))}\n{out}")

    run("git", "add", "-A", cp, "metadata")
    run("git", "commit", "-q", "-m", f"{cp}: add {new}, drop {old}")


def restore(cp):
    run("git", "reset", "-q", "--hard", "HEAD")
    run("git", "clean", "-qfd", cp)


def gh(*args, capture=True):
    return run("gh", *args, capture=capture)


def report_failure(cp, new, error):
    title = f"autobump: {cp} {new} failed"
    existing = gh("issue", "list", "--state", "open", "--search", f'"{title}" in:title',
                  "--json", "title", "--jq", ".[].title")
    if title in existing.splitlines():
        return
    body = f"The automatic bump of `{cp}` to {new} failed:\n\n```\n{error[-6000:]}\n```\n"
    gh("issue", "create", "--title", title, "--body", body)


def open_review_pr(cp, cfg, old, new, extra, distdir, base):
    pn = cp.split("/")[1]
    branch = f"autobump/{pn}-{new}"
    if run("git", "ls-remote", "--heads", "origin", branch, capture=True).strip():
        log(f"  {branch} already exists, skipping")
        return
    run("git", "switch", "-q", "-c", branch)
    try:
        bump(cp, cfg, old, new, extra, distdir)
        run("git", "push", "-q", "origin", branch)
        gh("pr", "create", "--base", base, "--head", branch,
           "--title", f"{cp}: add {new}, drop {old}",
           "--body", f"Automatic bump of `{cp}` from {old} to {new}. "
                     "Marked for review: build and test it before merging.")
    finally:
        restore(cp)
        run("git", "switch", "-q", base)
        run("git", "branch", "-q", "-D", branch)


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--check", action="store_true", help="only report outdated packages")
    parser.add_argument("--push", action="store_true", help="push, open PRs and issues")
    parser.add_argument("--distdir", default=os.environ.get("DISTDIR"),
                        help="where to download distfiles (default: a temporary dir)")
    parser.add_argument("packages", nargs="*", help="limit to these category/package")
    args = parser.parse_args()

    config = json.loads((HERE / "packages.json").read_text())
    selected = args.packages or list(config)
    distdir = args.distdir or tempfile.mkdtemp(prefix="autobump-distfiles-")
    base = run("git", "branch", "--show-current", capture=True).strip()
    if not args.check and run("git", "status", "--porcelain", capture=True).strip():
        sys.exit("the working tree has uncommitted changes, commit or stash them first")
    failures = 0

    for cp in selected:
        cfg = config[cp]
        old, _ = current_ebuild(cp)
        try:
            new, extra = UPSTREAMS[cfg["type"]](cp, cfg, old)
        except Exception as e:
            log(f"{cp}: cannot read upstream: {e}")
            failures += 1
            continue
        if new is None or vercmp(new, old) <= 0:
            log(f"{cp}: {old} is up to date")
            continue
        log(f"{cp}: {old} -> {new}")
        if args.check:
            continue
        try:
            if cfg.get("review") and args.push:
                open_review_pr(cp, cfg, old, new, extra, distdir, base)
            else:
                bump(cp, cfg, old, new, extra, distdir)
        except Exception as e:
            failures += 1
            log(f"  FAILED: {e}")
            restore(cp)
            if args.push:
                report_failure(cp, new, str(e))

    if args.push and not args.check:
        run("git", "push", "-q", "origin", base)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
