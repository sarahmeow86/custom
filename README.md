# Custom Gentoo Overlay

This overlay provides packages from Linux Mint that are not available in the official Gentoo repository.

## Packages

- **media-tv/hypnotix** - IPTV streaming application with support for live TV, movies and series
- **dev-python/cinemagoer** - Python bindings for the Internet Movie Database (IMDb)
- **media-icons/circle-flags-svg** - Collection of circular SVG country and language flags
- **x11-misc/xapp-symbolic-icons** - Symbolic icons for XApp applications

## Installation

1. Add the overlay using eselect-repository:
```bash
sudo eselect repository add custom git https://github.com/sarahmeow86/custom.git
```

2. Sync the overlay:
```bash
sudo emaint sync -r custom
```

3. Add the custom category to Portage:
```bash
echo "media-icons" | sudo tee -a /etc/portage/categories
```

4. Install packages:
```bash
sudo emerge --ask media-tv/hypnotix
```

## Notes

- All packages are marked as stable (`amd64 x86`)
- Source packages are fetched from packages.linuxmint.com and GitHub
- The overlay uses EAPI=8
