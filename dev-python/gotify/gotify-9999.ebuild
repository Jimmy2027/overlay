# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{7..12} )

inherit distutils-r1
inherit git-r3

DESCRIPTION="python-gotify is a python client library to interact with your gotify server without having to handle requests manually."
HOMEPAGE="https://github.com/d-k-bo/python-gotify"
EGIT_REPO_URI="https://github.com/d-k-bo/python-gotify.git"
KEYWORDS="~amd64 ~x86"
LICENSE="MIT License"
SLOT="0"
DEPEND="
dev-python/httpx[${PYTHON_USEDEP}]
"

RDEPEND="${DEPEND}"

src_unpack() {
    git-r3_src_unpack
}

python_install_all() {
    distutils-r1_python_install_all
}