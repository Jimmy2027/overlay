# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit vim-plugin

DESCRIPTION="VimWiki: A personal wiki for Vim"
HOMEPAGE="https://github.com/tools-life/taskwiki"
SRC_URI="https://github.com/tools-life/taskwiki/archive/refs/tags/1.0.0.tar.gz -> taskwiki-1.0.0.tar.gz"
LICENSE=""
KEYWORDS="~amd64"

RDEPEND="
app-editors/vim
app-misc/task
dev-python/tasklib
"

S="${WORKDIR}/taskwiki-1.0.0"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	# Nothing to compile
	:;
}

src_install() {
	local vimdir
	vimdir="/usr/share/vim/vimfiles/pack"

	if [ -z "${vimdir}" ]; then
		die "Vim pack directory ${vimdir} not found. Is Vim properly installed?"
	fi

	dodir "${vimdir}/plugins/start/${PN}" || die "Failed to create directory ${vimdir}/plugins/start/${PN}"

	# Copy the files to the installation directory
	insinto "${vimdir}/plugins/start/${PN}"
	doins -r .
}
