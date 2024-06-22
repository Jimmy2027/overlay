# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( pypy3 python3_{10..12} )

inherit distutils-r1

MY_P=${P/_beta/b}
DESCRIPTION="Data parsing and validation using Python type hints"
HOMEPAGE="
	https://github.com/pydantic/pydantic/
	https://pypi.org/project/pydantic/
"
SRC_URI="
	https://github.com/pydantic/pydantic/archive/v${PV/_beta/b}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S=${WORKDIR}/${MY_P}

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
IUSE="native-extensions"

RDEPEND="
	>=dev-python/typing-extensions-4.1.0[${PYTHON_USEDEP}]
"
BDEPEND="
	native-extensions? (
		<dev-python/cython-3[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

src_prepare() {
	sed -i -e '/CFLAGS/d' setup.py || die
	distutils-r1_src_prepare
}

python_compile() {
	if [[ ${EPYTHON} == pypy3 ]] || ! use native-extensions; then
		# do not build extensions on PyPy to workaround
		# https://github.com/cython/cython/issues/4763
		local -x SKIP_CYTHON=1
	fi
	distutils-r1_python_compile
}

