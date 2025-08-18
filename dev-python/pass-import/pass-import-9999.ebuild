# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1
inherit git-r3

DESCRIPTION="A pass extension for importing data from most of the existing password manager."
HOMEPAGE="https://github.com/roddhjav/pass-import"
EGIT_REPO_URI="https://github.com/roddhjav/pass-import.git"
KEYWORDS="~amd64 ~x86"
LICENSE="GPL-3"
SLOT="0"
DEPEND="
    dev-python/pyyaml[${PYTHON_USEDEP}]
    "

RDEPEND="${DEPEND}"