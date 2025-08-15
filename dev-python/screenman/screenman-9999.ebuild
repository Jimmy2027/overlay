# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{7..13} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1
inherit git-r3

DESCRIPTION="A Python tool to manage and configure multi-monitor setups using EDID information, allowing users to apply predefined screen layouts with ease."
HOMEPAGE="https://github.com/Jimmy2027/screenman"
EGIT_REPO_URI="https://github.com/Jimmy2027/screenman.git"
LICENSE="MIT License"
KEYWORDS=""
SLOT="0"


DEPEND="
dev-python/click[${PYTHON_USEDEP}]
sys-apps/edid-decode
"

RDEPEND="${DEPEND}"
