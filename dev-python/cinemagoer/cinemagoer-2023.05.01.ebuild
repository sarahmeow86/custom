# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..13} )

inherit python-single-r1

DESCRIPTION="Python bindings for the Internet Movie Database (IMDb)"
HOMEPAGE="https://cinemagoer.github.io/"
SRC_URI="https://github.com/cinemagoer/cinemagoer/archive/refs/tags/${PV}.tar.gz -> cinemagoer-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/lxml[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
	')
"

BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/build[${PYTHON_USEDEP}]
		dev-python/installer[${PYTHON_USEDEP}]
	')
"

S="${WORKDIR}/cinemagoer-${PV}"

src_compile() {
	${EPYTHON} -m build --wheel --no-isolation || die
}

src_install() {
	${EPYTHON} -m installer --destdir="${D}" dist/*.whl || die
	einstalldocs
}
