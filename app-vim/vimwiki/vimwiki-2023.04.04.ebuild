# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="v2023.04.04_1"

inherit vim-plugin
DESCRIPTION="A personal wiki for Vim"
HOMEPAGE="https://vimwiki.github.io/"
SRC_URI="https://github.com/vimwiki/vimwiki/archive/${MY_PV}.tar.gz -> ${MY_PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	app-editors/vim
"

S="${WORKDIR}/vimwiki-${MY_PV##v}"

src_install() {
	vim-plugin_src_install
}