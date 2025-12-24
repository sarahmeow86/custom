# Maintainer: Luna Jernberg <droidbittin@gmail.com>

EAPI=9
PYTHON_COMPAT=( python3_12 python3_13 )

DESCRIPTION="Python bindings for the Internet Movie Database (IMDb)"
HOMEPAGE="https://cinemagoer.github.io/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Dependencies
DEPEND="dev-python/lxml[${PYTHON_USEDEP}]
        dev-python/sqlalchemy[${PYTHON_USEDEP}]
        dev-python/tqdm[${PYTHON_USEDEP}]
        dev-python/setuptools[${PYTHON_USEDEP}]
        dev-python/importlib-metadata[${PYTHON_USEDEP}]"

RDEPEND="${DEPEND}"

SRC_URI="https://github.com/cinemagoer/cinemagoer/archive/refs/tags/2023.05.01.tar.gz -> ${PN}-${PV}.tar.gz"
SRC_URI_SHA256="eceeae2c4241d2eab39aaddbe99a7aa61d28578fb127bf9aa44c8bea024c25e5"

S="${WORKDIR}/${PN}-${PV}"

src_prepare() {
    default
    # Rename directory like PKGBUILD did
    mv "${WORKDIR}/cinemagoer-${PV}" "${S}"
}

src_compile() {
    cd "${S}"
    python_build
}

src_install() {
    cd "${S}"
    python_install
    dodoc README.rst
}
