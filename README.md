# Custom Gentoo Overlay

This overlay provides packages not available in the official Gentoo repository, mostly software from Linux Mint plus a few other tools.

## Packages

- **media-tv/hypnotix** - IPTV streaming application with support for live TV, movies and series
- **dev-python/cinemagoer** - Python bindings for the Internet Movie Database (IMDb)
- **x11-misc/circle-flags-svg** - Collection of circular SVG country and language flags
- **app-admin/topgrade** - Upgrades everything on the system with a single command
- **games-util/input-remapper** - Change and program the mapping of input device buttons (fixes a broken shebang present in GURU's ebuild)
- **www-client/brave-origin** - Standalone Brave web browser without rewards, wallet, AI or other extras
- **app-misc/handy** - Offline speech-to-text dictation app using local whisper.cpp/ONNX models (~amd64)
- **gui-apps/kwtype** - Virtual keyboard input tool for KDE Plasma Wayland, used by app-misc/handy to type accented characters (~amd64)
- **dev-python/mkdocs** - Static site generator geared towards project documentation, removed from ::gentoo
- **dev-python/mkdocs-material** - Material Design theme for MkDocs, removed from ::gentoo (~amd64)

## Installation

1. Add the overlay using eselect-repository:
```bash
sudo eselect repository add custom git https://github.com/sarahmeow86/custom.git
```

2. Sync the overlay:
```bash
sudo emaint sync -r custom
```

3. Install packages:
```bash
sudo emerge --ask media-tv/hypnotix
```

## Notes

- All packages are marked as stable; most target `amd64 x86`, a few (app-admin/topgrade, games-util/input-remapper) are `amd64`-only, and www-client/brave-origin targets `amd64 arm64`
- Source packages are fetched from packages.linuxmint.com, crates.io, GitHub, and prebuilt `.deb` releases (www-client/brave-origin)
- app-misc/handy's src_compile reaches the network (RESTRICT="network-sandbox") to run `bun install`/`bun run build` for its JS frontend, since there's no Gentoo vendoring tool for the Bun/npm ecosystem equivalent to pycargoebuild for Rust
- dev-python/mkdocs and dev-python/mkdocs-material were last-rited and removed from ::gentoo in early 2026 along with several of their dependencies (bug #971358); this overlay also carries the now-orphaned dev-python/ghp-import, dev-python/pyyaml-env-tag, dev-python/mkdocs-get-deps, dev-python/paginate, dev-python/readtime and dev-python/mkdocs-material-extensions to satisfy them (dev-python/mergedeep is still available from ::guru)
- The overlay uses EAPI=8
