# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

inherit python-r1

DESCRIPTION="A Python client for the Gotify API"
HOMEPAGE="https://github.com/d-k-bo/python-gotify"
SRC_URI="https://github.com/d-k-bo/python-gotify/archive/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="stream test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
    test? ( ${PYTHON_REQUIRED_USE} )"

# Dependencies
RDEPEND=">=dev-python/httpx-0.22.0[${PYTHON_USEDEP}]"
DEPEND="dev-python/flit_core[${PYTHON_USEDEP}]
    test? (
        dev-python/pytest-asyncio[${PYTHON_USEDEP}]
        dev-python/pytest-cov[${PYTHON_USEDEP}]
        dev-python/pytest[${PYTHON_USEDEP}]
        dev-python/typeguard[${PYTHON_USEDEP}]
    )"
BDEPEND=""

# Optional dependencies
OPTIONAL_DEPEND="stream? ( >=dev-python/websockets-10.3[${PYTHON_USEDEP}] )"

src_prepare() {
    default
}

src_compile() {
    python_setup
    python_compile
}

src_test() {
    python_test
}

src_install() {
    python_install
}
