# Copyright 2025 Gentoo Authors
EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit python-single-r1 xdg-utils gnome2-utils

DESCRIPTION="An IPTV streaming application with support for live TV, movies and series"
HOMEPAGE="https://github.com/linuxmint/hypnotix"
SRC_URI="https://github.com/linuxmint/hypnotix/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3.0-or-later"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Dependencies
DEPEND="
    ${PYTHON_DEPS}
    media-icons/circle-flags-svg
    x11-themes/hicolor-icon-theme
    media-video/mpv[libmpv]
    $(python_gen_cond_dep '
        dev-python/pycairo[${PYTHON_USEDEP}]
        dev-python/pygobject[${PYTHON_USEDEP}]
        dev-python/requests[${PYTHON_USEDEP}]
        dev-python/setproctitle[${PYTHON_USEDEP}]
        dev-python/unidecode[${PYTHON_USEDEP}]
    ')
    dev-python/cinemagoer[${PYTHON_SINGLE_USEDEP}]
    x11-libs/xapp
    net-misc/yt-dlp
"
RDEPEND="${DEPEND}"
BDEPEND="${PYTHON_DEPS}"

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
    python_fix_shebang "${ED}"/usr/lib/hypnotix/hypnotix.py
    fperms +x /usr/lib/hypnotix/hypnotix.py
    python_optimize "${ED}"/usr/lib/hypnotix

    # Install schemas
    insinto /usr/share/glib-2.0/schemas
    doins usr/share/glib-2.0/schemas/*.gschema.xml

    # Install desktop file
    insinto /usr/share/applications
    doins usr/share/applications/hypnotix.desktop

    # Install icons and assets
    insinto /usr/share/hypnotix
    doins -r usr/share/hypnotix/*
    
    # Compile GSettings schemas
    insinto /usr/share/glib-2.0/schemas
}

pkg_postinst() {
    xdg_icon_cache_update
    gnome2_schemas_update
}

pkg_postrm() {
    xdg_icon_cache_update
    gnome2_schemas_update
}
