# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=7

PYTHON_COMPAT=( python3_{7..11} )

inherit distutils-r1
inherit git-r3

DESCRIPTION="A pass extension for importing data from most of the existing password manager."
HOMEPAGE="https://github.com/roddhjav/pass-import"
EGIT_REPO_URI="https://github.com/roddhjav/pass-import.git"
KEYWORDS="~amd64 ~x86"
LICENSE="GNU General Public License v3.0"
SLOT="0"
DEPEND="
    dev-python/pyyaml[${PYTHON_USEDEP}]
    "

RDEPEND="${DEPEND}"

src_unpack() {
    git-r3_src_unpack
}

python_install_all() {
    distutils-r1_python_install_all
}