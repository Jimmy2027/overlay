# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit vim-plugin
DESCRIPTION="Neovim plugin for GitHub Copilot"
HOMEPAGE="https://github.com/github/copilot.vim"
SRC_URI="https://github.com/github/copilot.vim/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	app-editors/vim
"

S="${WORKDIR}/copilot.vim-${PV}"

src_install() {
	vim-plugin_src_install
}

pkg_postinst() {
	elog "To finish the installation start Neovim and invoke :Copilot setup."
}