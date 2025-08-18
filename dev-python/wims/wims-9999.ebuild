# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1
inherit git-r3

DESCRIPTION="Database to store location of stuff."
HOMEPAGE="https://github.com/Jimmy2027/WhereIsMyStuff"
EGIT_REPO_URI="https://github.com/Jimmy2027/WhereIsMyStuff.git"
KEYWORDS="~amd64 ~x86"
LICENSE="GPL-3"
SLOT="0"
DEPEND="
    dev-python/pymongo[${PYTHON_USEDEP}]
    dev-python/modun[${PYTHON_USEDEP}]
    dev-python/fuzzywuzzy[${PYTHON_USEDEP}]
    dev-python/pandas[${PYTHON_USEDEP}]
    dev-python/tabulate[${PYTHON_USEDEP}]
    "

RDEPEND="${DEPEND}"