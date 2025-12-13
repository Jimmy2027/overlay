# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.85.0"

inherit cargo git-r3

DESCRIPTION="Sync server for Taskchampion, the task database backend for Taskwarrior"
HOMEPAGE="https://github.com/GothenburgBitFactory/taskchampion-sync-server"
EGIT_REPO_URI="https://github.com/GothenburgBitFactory/${PN}.git"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD ISC MIT Unicode-3.0 Unlicense"
SLOT="0"
IUSE="+sqlite postgres"
REQUIRED_USE="|| ( sqlite postgres )"

QA_FLAGS_IGNORED="
	/usr/bin/taskchampion-sync-server
	/usr/bin/taskchampion-sync-server-postgres
"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_configure() {
	local myfeatures=(
		$(usev sqlite)
		$(usev postgres)
	)
	cargo_src_configure --no-default-features
}

src_install() {
	cargo_src_install --path server
	einstalldocs
}
