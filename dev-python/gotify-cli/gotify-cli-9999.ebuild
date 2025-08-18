# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1
inherit git-r3

DISTUTILS_USE_PEP517=setuptools

DESCRIPTION="A command line interface to send messages with gotify."
HOMEPAGE="https://github.com/Jimmy2027/gotify_cli"
EGIT_REPO_URI="https://github.com/Jimmy2027/gotify_cli.git"
KEYWORDS="~amd64 ~x86"
LICENSE="MIT"
SLOT="0"
DEPEND="
    dev-python/gotify[${PYTHON_USEDEP}]
    dev-python/platformdirs[${PYTHON_USEDEP}]
    dev-python/click[${PYTHON_USEDEP}]
    "

RDEPEND="${DEPEND}"