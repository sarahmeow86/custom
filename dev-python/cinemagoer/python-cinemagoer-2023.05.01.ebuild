# Maintainer: Luna Jernberg <droidbittin@gmail.com>

EAPI=8
PYTHON_COMPAT=( python3_{11..13} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Python bindings for the Internet Movie Database (IMDb)"
HOMEPAGE="https://cinemagoer.github.io/"
SRC_URI="https://github.com/cinemagoer/cinemagoer/archive/refs/tags/${PV}.tar.gz -> cinemagoer-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

# Dependencies
RDEPEND="
    dev-python/lxml[${PYTHON_USEDEP}]
    dev-python/sqlalchemy[${PYTHON_USEDEP}]
"

BDEPEND="
    dev-python/setuptools[${PYTHON_USEDEP}]
    test? (
        dev-python/pytest[${PYTHON_USEDEP}]
    )
"

S="${WORKDIR}/cinemagoer-${PV}"

distutils_enable_tests pytest
