# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit meson python-single-r1 xdg

DESCRIPTION="Cross-desktop libraries and common resources for the X-Apps project"
HOMEPAGE="https://github.com/linuxmint/xapp"
SRC_URI="https://github.com/linuxmint/xapp/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk-doc introspection vala"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-libs/glib-2.56:2
	>=x11-libs/gtk+-3.22:3[introspection?]
	x11-libs/cairo
	x11-libs/libX11
	x11-libs/libXtst
	gnome-base/libgnomekbd
	>=gnome-base/gnome-desktop-3:3
	introspection? ( >=dev-libs/gobject-introspection-1.56:= )
"

DEPEND="${RDEPEND}"

BDEPEND="
	${PYTHON_DEPS}
	dev-util/glib-utils
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc )
	vala? ( dev-lang/vala:= )
"

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc docs)
		$(meson_use vala vapi)
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
