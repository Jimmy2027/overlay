# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..9} )

inherit distutils-r1
inherit git-r3

DESCRIPTION="A personal pastebin in python."
HOMEPAGE="https://https://github.com/Jimmy2027/PPB"
EGIT_REPO_URI="https://github.com/Jimmy2027/PPB.git"
KEYWORDS="~amd64 ~x86"
LICENSE="GNU General Public License v2.0"
LOT="0"
DEPEND="
    dev-python/flask[${PYTHON_USEDEP}]
    dev-python/pandas[${PYTHON_USEDEP}]
    "

RDEPEND="${DEPEND}"

src_unpack() {
    git-r3_src_unpack
}

python_install_all() {
    distutils-r1_python_install_all
}