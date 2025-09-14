# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 git-r3

DESCRIPTION="Python tool to manage multi-monitor setups using EDID information"
HOMEPAGE="https://github.com/Jimmy2027/screenman"
EGIT_REPO_URI="https://github.com/Jimmy2027/screenman.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

DEPEND="
dev-python/click[${PYTHON_USEDEP}]
media-libs/libv4l
"

RDEPEND="${DEPEND}"
