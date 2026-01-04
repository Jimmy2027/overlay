# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A client-optimized language for fast apps on any platform"
HOMEPAGE="https://flutter.dev/"

SRC_URI="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${PV}-stable.tar.xz"

S="${WORKDIR}/${PN}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples"
RESTRICT="strip"

RDEPEND="
	dev-vcs/git
"

QA_PREBUILT="opt/flutter/*"

src_prepare() {
	default
	# Remove Windows batch files
	find . -iname '*.bat' -delete || die
}

src_compile() {
	# Skip - pre-built binary distribution
	:
}

src_install() {
	use examples || rm -r examples/ || die

	insinto /opt/${PN}
	doins -r .

	# Set execute permissions on binaries
	fperms a+x /opt/${PN}/bin/flutter
	fperms a+x /opt/${PN}/bin/dart
	fperms a+x /opt/${PN}/bin/internal/shared.sh
	fperms a+x /opt/${PN}/bin/internal/update_dart_sdk.sh

	# Create symlinks for CLI access
	dodir /opt/bin
	dosym -r /opt/${PN}/bin/flutter /opt/bin/flutter
	dosym -r /opt/${PN}/bin/dart /opt/bin/dart
}

pkg_postinst() {
	elog "Flutter has been installed to /opt/flutter"
	elog ""
	elog "Run 'flutter doctor' to check your setup and see any additional"
	elog "dependencies needed for your target platforms."
	elog ""
	elog "For Linux desktop development, you may need:"
	elog "  sys-devel/clang"
	elog "  dev-build/cmake"
	elog "  dev-build/ninja"
	elog "  x11-libs/gtk+:3"
}
