# Maintainer: Luna Jernberg <droidbittin@gmail.com>
EAPI=9
PYTHON_COMPAT=( python3_12 python3_13 )

DESCRIPTION="An IPTV streaming application with support for live TV, movies and series."
HOMEPAGE="https://github.com/linuxmint/hypnotix"
LICENSE="GPL-3.0-or-later"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Dependencies
DEPEND="
    media-icons/circle-flags-svg
    x11-misc/dconf
    x11-themes/hicolor-icon-theme
    media-video/mpv
    dev-python/pycairo[${PYTHON_USEDEP}]
    dev-python/pygobject[${PYTHON_USEDEP}]
    dev-python/python-cinemagoer[${PYTHON_USEDEP}]
    dev-python/requests[${PYTHON_USEDEP}]
    dev-python/setproctitle[${PYTHON_USEDEP}]
    dev-python/unidecode[${PYTHON_USEDEP}]
    x11-misc/xapp
    media-video/yt-dlp
    x11-themes/xapp-symbolic-icons
"

RDEPEND="${DEPEND}"

SRC_URI="https://github.com/linuxmint/hypnotix/archive/refs/tags/5.5.tar.gz -> ${PN}-${PV}.tar.gz"
SRC_URI_SHA256="8eb7991ceeab93096c8a8c9850b2fd920511b52ad13330b1a25fd8488b6fd71f"

S="${WORKDIR}/${PN}-${PV}"

src_prepare() {
    default
    # Patch About dialog version
    sed -i "s/__DEB_VERSION__/${PV}/g" "${S}/usr/lib/${PN}/${PN}.py"
    # Fix license path if needed
    sed -i 's|common-licenses/GPL|licenses/common/GPL/license.txt|g' "${S}/usr/lib/${PN}/${PN}.py"
}

src_compile() {
    cd "${S}"
    make
}

src_install() {
    cd "${S}"
    cp -r usr/ "${ED}/"
}
