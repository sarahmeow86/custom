# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson xdg

COMMIT="ac2c3864aaacc31afc252d88d1d4b669270f2f44"

DESCRIPTION="Virtual keyboard input tool for KDE Plasma Wayland (wtype for KWin)"
HOMEPAGE="https://github.com/Sporif/KWtype"
SRC_URI="https://github.com/Sporif/KWtype/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/KWtype-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-libs/wayland
	dev-qt/qtbase:6[dbus]
	kde-plasma/kwayland:6
	x11-libs/libxkbcommon
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-qt/qtbase:6
	virtual/pkgconfig
"
