# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..14} )

inherit git-r3 python-single-r1 readme.gentoo-r1 shell-completion

DESCRIPTION="Zsh plugin for completion, syntax highlighting, and output wrapping for mlir-opt"
HOMEPAGE="https://github.com/oowekyala/mlir-zsh-plugin"
EGIT_REPO_URI="https://github.com/oowekyala/${PN}.git"

LICENSE="Apache-2.0 MIT"
SLOT="0"
IUSE="+pygments"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	app-shells/zsh
	pygments? (
		$(python_gen_cond_dep '
			dev-python/pygments[${PYTHON_USEDEP}]
		')
	)
"

DISABLE_AUTOFORMATTING="true"

DOC_CONTENTS="\
In order to use ${CATEGORY}/${PN}, add
\`source /usr/share/zsh/site-functions/mlir.plugin.zsh\`
at the end of your ~/.zshrc"

src_install() {
	dozshcomp mlir.plugin.zsh _mlir_opt wrap_mlir_opt pygmentize_mlir

	insinto /usr/share/zsh/site-functions/py
	doins py/MlirLexer.py py/mlir_opt_comp_helper.py

	python_fix_shebang "${ED}/usr/share/zsh/site-functions/py"

	dodoc README.md

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
