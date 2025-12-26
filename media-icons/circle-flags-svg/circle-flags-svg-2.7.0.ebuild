EAPI=8

DESCRIPTION="Collection of circular SVG country and language flags"
HOMEPAGE="https://github.com/linuxmint/circle-flags"
SRC_URI="http://packages.linuxmint.com/pool/main/c/circle-flags/circle-flags_${PV}+mint1.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

S="${WORKDIR}/circle-flags"

src_install() {
    insinto /usr/share
    doins -r usr/share/*
}
