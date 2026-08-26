# Custom Gentoo Overlay

This overlay provides packages not available in the official Gentoo repository, mostly software from Linux Mint plus a few other tools.

## Packages

- **media-tv/hypnotix** - IPTV streaming application with support for live TV, movies and series
- **dev-python/cinemagoer** - Python bindings for the Internet Movie Database (IMDb)
- **x11-misc/circle-flags-svg** - Collection of circular SVG country and language flags
- **app-admin/topgrade** - Upgrades everything on the system with a single command
- **games-util/input-remapper** - Change and program the mapping of input device buttons (fixes a broken shebang present in GURU's ebuild)

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

- All packages are marked as stable; most target `amd64 x86`, a few (app-admin/topgrade, games-util/input-remapper) are `amd64`-only
- Source packages are fetched from packages.linuxmint.com, crates.io, and GitHub
- The overlay uses EAPI=8
