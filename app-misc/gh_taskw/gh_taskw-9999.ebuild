# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1
inherit git-r3

DESCRIPTION="Taskwarrior integration for Github notifications"
HOMEPAGE="https://github.com/Jimmy2027/gh_taskw"
EGIT_REPO_URI="https://github.com/Jimmy2027/gh_taskw.git"
KEYWORDS="~amd64 ~x86"
LICENSE="MIT"
SLOT="0"

IUSE="tasknote gotify"

DEPEND="
dev-python/tasklib[${PYTHON_USEDEP}]
tasknote? (
    app-misc/tasknote[${PYTHON_USEDEP}]
)
gotify? (
    dev-python/gotify[${PYTHON_USEDEP}]
)
"

RDEPEND="${DEPEND}"