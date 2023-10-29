# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8
inherit vim-plugin
inherit git-r3

DESCRIPTION="fzf ❤️ vim"
HOMEPAGE="https://github.com/junegunn/fzf.vim"
EGIT_REPO_URI="https://github.com/junegunn/fzf.vim.git"

LICENSE="MIT"
KEYWORDS="~amd64 ~x86"

RDEPEND="
    app-editors/vim
	app-shells/fzf
"

src_unpack() {
    git-r3_src_unpack
}


    # vim-plugin_src_install
src_install() {
    # Move the plugin files to the desired location
    insinto /usr/share/vim/vimfiles/pack/plugins/start/
    doins -r "${S}/autoload" "${S}/doc" "${S}/plugin"
}
