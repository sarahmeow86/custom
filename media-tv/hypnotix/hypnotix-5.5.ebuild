# Copyright 2025 Gentoo Authors
EAPI=8


DESCRIPTION="An IPTV streaming application with support for live TV, movies and series"
HOMEPAGE="https://github.com/linuxmint/hypnotix"
SRC_URI="https://github.com/linuxmint/hypnotix/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3.0-or-later"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Dependencies
DEPEND="
    media-tv/circle-flags-svg
    x11-themes/hicolor-icon-theme
    media-video/mpv
    dev-python/pycairo
    dev-python/pygobject
    dev-python/python-cinemagoer
    dev-python/requests
    dev-python/setproctitle
    dev-python/unidecode
    x11-misc/xapp
    x11-misc/xapp-symbolic-icons
    media-video/yt-dlp
"
RDEPEND="${DEPEND}"

# Use Python 3.11+
PYTHON_COMPAT=(python3_11 python3_12)

src_prepare() {
    default

    # Set version in About dialog
    sed -i "s/__DEB_VERSION__/${PV}/g" "usr/lib/hypnotix/hypnotix.py"

    # Fix license path
    sed -i 's|common-licenses/GPL|licenses/common/GPL/license.txt|g' "usr/lib/hypnotix/hypnotix.py"
}

src_install() {
    dobin usr/bin/hypnotix
    insinto /usr/lib/hypnotix
    doins usr/lib/hypnotix/*.py

    # Install schemas
    insinto /usr/share/glib-2.0/schemas
    doins usr/share/glib-2.0/schemas/*.gschema.xml

    # Install desktop file
    insinto /usr/share/applications
    doins usr/share/applications/hypnotix.desktop

    # Install icons and assets
    insinto /usr/share/hypnotix
    doins -r usr/share/hypnotix/*
}
