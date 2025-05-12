# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{9..13} )

inherit distutils-r1
inherit git-r3

DESCRIPTION="A simple python package that allows to add markdown notes to Taskwarrior tasks."
HOMEPAGE="https://github.com/Jimmy2027/TaskNote"
EGIT_REPO_URI="https://github.com/Jimmy2027/TaskNote.git"
KEYWORDS="~amd64 ~x86"
LICENSE="MIT License"
SLOT="0"
DEPEND=""

RDEPEND="${DEPEND}"

src_unpack() {
    git-r3_src_unpack
}

python_install_all() {
    distutils-r1_python_install_all
}