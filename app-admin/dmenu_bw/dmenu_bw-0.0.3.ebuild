# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

DESCRIPTION="A minimal Bitwarden GUI written in POSIX shellscript."
HOMEPAGE="https://github.com/Sife-ops/dmenu_bw"
SRC_URI="https://github.com/Sife-ops/dmenu_bw/archive/refs/tags/v${PV}.tar.gz"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="app-misc/jq"
DEPEND="${RDEPEND}"

src_install() {
	emake DESTDIR="${D}" install
}