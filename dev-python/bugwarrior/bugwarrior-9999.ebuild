# Taken and modified from pypi repo.

EAPI=8

REALNAME="${PN}"
LITERALNAME="${PN}"
REALVERSION="${PV}"
DIGEST_SOURCES="yes"
PYTHON_COMPAT=( python{3_10,3_11,3_12} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1
inherit git-r3

DESCRIPTION="Sync github, bitbucket, and track issues with taskwarrior"

HOMEPAGE="http://github.com/ralphbean/bugwarrior"
LICENSE="GPL-3+"
EGIT_REPO_URI="https://github.com/GothenburgBitFactory/bugwarrior.git"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="activecollab bts bugzilla gmail jira keyring megaplan phabricator trac"
DEPENDENCIES="dev-python/click[${PYTHON_USEDEP}]
>=dev-python/dogpile-cache-0.5.3[${PYTHON_USEDEP}]
dev-python/jinja[${PYTHON_USEDEP}]
>=dev-python/lockfile-0.9.1[${PYTHON_USEDEP}]
dev-python/python-dateutil[${PYTHON_USEDEP}]
dev-python/pytz[${PYTHON_USEDEP}]
dev-python/requests[${PYTHON_USEDEP}]
>=dev-python/six-1.9.0[${PYTHON_USEDEP}]
dev-python/taskw[${PYTHON_USEDEP}]
activecollab? ( dev-python/pyac[${PYTHON_USEDEP}] )
activecollab? ( dev-python/pypandoc[${PYTHON_USEDEP}] )
bts? ( dev-python/PySimpleSOAP[${PYTHON_USEDEP}] )
bts? ( dev-python/python-debianbts[${PYTHON_USEDEP}] )
bugzilla? ( >=dev-python/python-bugzilla-2.0.0[${PYTHON_USEDEP}] )
gmail? ( dev-python/google-api-python-client[${PYTHON_USEDEP}] )
gmail? ( dev-python/google-auth-oauthlib[${PYTHON_USEDEP}] )
jira? ( dev-python/jira[${PYTHON_USEDEP}] )
keyring? ( dev-python/keyring[${PYTHON_USEDEP}] )
megaplan? ( dev-python/megaplan[${PYTHON_USEDEP}] )
phabricator? ( dev-python/phabricator[${PYTHON_USEDEP}] )
trac? ( dev-python/offtrac[${PYTHON_USEDEP}] )"
BDEPEND="${DEPENDENCIES}"
RDEPEND="${DEPENDENCIES}"
