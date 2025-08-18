# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1
inherit git-r3

DESCRIPTION="Python client library for ownCloud."
HOMEPAGE="https://github.com/owncloud/pyocclient"
EGIT_REPO_URI="https://github.com/owncloud/pyocclient.git"
KEYWORDS="~amd64 ~x86"
LICENSE="MIT"
SLOT="0"
DEPEND="
    dev-python/six[${PYTHON_USEDEP}]
    dev-python/requests[${PYTHON_USEDEP}]
    "

RDEPEND="${DEPEND}"