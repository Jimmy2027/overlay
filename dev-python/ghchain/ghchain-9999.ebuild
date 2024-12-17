# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{7..12} )

DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1
inherit git-r3

DESCRIPTION="Chain pull requests from your devbranch's commits."
HOMEPAGE="https://github.com/Jimmy2027/ghchain"
EGIT_REPO_URI="https://github.com/Jimmy2027/ghchain.git"
LICENSE="MIT License"
KEYWORDS=""
SLOT="0"


DEPEND="
dev-python/click[${PYTHON_USEDEP}]
>=dev-python/pydantic-2[${PYTHON_USEDEP}]
dev-python/gitpython[${PYTHON_USEDEP}]
"

RDEPEND="${DEPEND}"