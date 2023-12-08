# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8,9,10,11,12} )

inherit distutils-r1

DESCRIPTION="A generic test automation framework"
HOMEPAGE="https://robotframework.org/"
SRC_URI="https://github.com/robotframework/robotframework/archive/refs/tags/v6.0.2.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

distutils_enable_tests setup.py

python_install_all() {
    distutils-r1_python_install_all
    
    # Install console scripts
    dobin src/robot/run.py
    dobin src/robot/rebot.py
    dobin src/robot/libdoc.py
}