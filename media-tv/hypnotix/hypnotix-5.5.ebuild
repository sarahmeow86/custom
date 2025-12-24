EAPI=8

PYTHON_COMPAT=( python3_{11,12} )

inherit python-r1 gnome2-utils xdg

DESCRIPTION="IPTV streaming application with support for live TV, movies and series"
HOMEPAGE="https://github.com/linuxmint/hypnotix"
SRC_URI="https://github.com/linuxmint/hypnotix/archive/refs/tags/${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
    ${PYTHON_DEPS}
    media-gfx/circle-flags-svg>=2.7.0
    gnome-base/dconf
    x11-themes/hicolor-icon-theme
    media-video/mpv
    dev-python/pycairo
    dev-python/pygobject
    dev-python/cinemagoer
    dev-python/requests
    dev-python/setproctitle
    dev-python/unidecode
    x11-libs/xapp
    x11-themes/xapp-symbolic-icons
    net-misc/yt-dlp
"

DEPEND="${RDEPEND}"

src_prepare() {
    default

    # Set version in About dialog
    sed -i \
        "s/__DEB_VERSION__/${PV}/g" \
        usr/lib/hypnotix/hypnotix.py || die

    # Fix license path (matches Arch fix)
    sed -i \
        's|common-licenses/GPL|licenses/common/GPL/license.txt|g' \
        usr/lib/hypnotix/hypnotix.py || die
}

src_compile() {
    emake
}

src_install() {
    insinto /
    doins -r usr
}

pkg_postinst() {
    gnome2_schemas_update
    xdg_pkg_postinst
}

pkg_postrm() {
    gnome2_schemas_update
    xdg_pkg_postrm
}
