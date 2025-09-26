# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="OpenAI Codex CLI - an AI-powered coding assistant for your terminal"
HOMEPAGE="https://github.com/openai/codex"
SRC_URI="https://github.com/openai/codex/releases/download/rust-v${PV}/codex-npm-${PV}.tgz"
S="${WORKDIR}/package"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"

RESTRICT="bindist strip"

RDEPEND="
	>=net-libs/nodejs-20
	sys-apps/ripgrep
"

src_compile() {
	# Skip, nothing to compile here.
	:
}

src_install() {
	dodoc README.md

	# We are using a strategy of "install everything that's left"
	# so removing these here will prevent duplicates in /opt/codex-cli
	rm -f README.md package.json || die
	# remove vendored ripgrep if present
	rm -rf vendor/ripgrep || die

	insinto /opt/${PN}
	doins -r ./*
	fperms a+x opt/codex-cli/bin/codex.js

	# Set execute permissions on vendor binaries
	fperms a+x opt/codex-cli/vendor/x86_64-unknown-linux-musl/codex/codex
	fperms a+x opt/codex-cli/vendor/aarch64-unknown-linux-musl/codex/codex
	fperms a+x opt/codex-cli/vendor/x86_64-apple-darwin/codex/codex
	fperms a+x opt/codex-cli/vendor/aarch64-apple-darwin/codex/codex

	dodir /opt/bin
	dosym -r /opt/${PN}/bin/codex.js /opt/bin/codex

	# Create ripgrep symlink structure expected by codex-cli
	if use amd64; then
		dodir /opt/${PN}/node_modules/@vscode/ripgrep/bin
		dosym -r /usr/bin/rg /opt/${PN}/node_modules/@vscode/ripgrep/bin/rg
	fi

	# nodejs defaults to disabling deprecation warnings when running code
	# from any path containing a node_modules directory. Since we're installing
	# outside of the realm of npm, explicitly pass an option to disable
	# deprecation warnings so it behaves the same as it does if installed via
	# npm.
	sed -i 's/env node/env -S node --no-deprecation/' "${ED}/opt/codex-cli/bin/codex.js" || die
}