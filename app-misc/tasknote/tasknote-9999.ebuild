# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1
inherit git-r3

DESCRIPTION="A simple python package that allows to add markdown notes to Taskwarrior tasks."
HOMEPAGE="https://github.com/Jimmy2027/TaskNote"
EGIT_REPO_URI="https://github.com/Jimmy2027/TaskNote.git"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="${DEPEND}"
