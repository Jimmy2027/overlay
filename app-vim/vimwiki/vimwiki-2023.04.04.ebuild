# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit vim-plugin

DESCRIPTION="A personal wiki for Vim"
HOMEPAGE="https://vimwiki.github.io/"
SRC_URI="https://github.com/vimwiki/vimwiki/archive/v2023.04.04_1.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="~amd64 ~x86"

RDEPEND="
    app-vim/vim
"

S="${WORKDIR}/${PN}"

src_install() {
    vim-plugin_src_install
}
