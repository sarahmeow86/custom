# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils

DESCRIPTION="Symbolic icons for XApp applications"
HOMEPAGE="https://github.com/linuxmint/xapp-symbolic-icons"
SRC_URI="http://packages.linuxmint.com/pool/main/x/xapp-symbolic-icons/${PN}_${PV}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="x11-themes/hicolor-icon-theme"

S="${WORKDIR}/${PN}"

src_install() {
	insinto /usr/share/icons
	doins -r usr/share/icons/*
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
