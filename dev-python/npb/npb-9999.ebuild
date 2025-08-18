# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1
inherit git-r3

DESCRIPTION="A personal pastebin for Nextcloud in python."
HOMEPAGE="https://github.com/Jimmy2027/NPB"
EGIT_REPO_URI="https://github.com/Jimmy2027/NPB.git"
KEYWORDS="~amd64 ~x86"
LICENSE="GPL-2"
SLOT="0"
DEPEND="
    dev-python/pyocclient[${PYTHON_USEDEP}]
    "

RDEPEND="${DEPEND}"