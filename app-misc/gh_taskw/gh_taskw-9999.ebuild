# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1
inherit git-r3

DESCRIPTION="Taskwarrior integration for Github notifications"
HOMEPAGE="https://github.com/Jimmy2027/gh_taskw"
EGIT_REPO_URI="https://github.com/Jimmy2027/gh_taskw.git"
KEYWORDS="~amd64 ~x86"
LICENSE="MIT License"
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

src_unpack() {
    git-r3_src_unpack
}

python_install_all() {
    distutils-r1_python_install_all
}