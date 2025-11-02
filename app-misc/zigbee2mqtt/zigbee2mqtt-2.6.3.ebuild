# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/Koenkk/zigbee2mqtt"
	EGIT_BRANCH="dev"
	inherit git-r3
else
	SRC_URI="https://github.com/Koenkk/zigbee2mqtt/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

inherit nodejs-mod systemd tmpfiles

DESCRIPTION="It bridges events and allows you to control your Zigbee devices via MQTT"
HOMEPAGE="https://www.zigbee2mqtt.io/"
COMMIT="6e001b48ec278c6c141579c9eacc045f190fc289"

LICENSE="0BSD Apache-2.0 BSD-2 CC-BY-4.0 GPL-3 ISC MIT PYTHON"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="network-sandbox"

BDEPEND="
	net-libs/nodejs[npm]
	sys-devel/gcc
	virtual/pkgconfig
	dev-lang/python:*
"

RDEPEND="
	acct-group/zigbee2mqtt
	acct-user/zigbee2mqtt
	app-misc/mosquitto
"

pkg_pretend() {
	if [[ -e "${EROOT}/etc/env.d/90${PN}" ]] && \
	    ! grep -q "CONFIG_PROTECT=\"/var/lib/${PN}\"" "${EROOT}/etc/env.d/90${PN}" 2>/dev/null; then
		eerror "Bad CONFIG_PROTECT"
		eerror "update ${EROOT}/etc/env.d/90${PN} to include CONFIG_PROTECT=\"/var/lib/${PN}\""
		eerror ""
		eerror ""
		die "Bad CONFIG_PROTECT"
	fi
}

src_prepare() {
	nodejs-mod_src_prepare

	# Install node modules (include dev deps for tsc)
	if [[ ! -d node_modules ]]; then
		einfo "Installing node modules via npm"
		# make sure devDependencies are included
		export npm_config_production=false
		# prefer ci if you have a lockfile in the tarball; fallback to install
		if [[ -f package-lock.json ]]; then
			npm ci --audit false --color false --progress false --verbose \
				|| die "npm ci failed"
		else
			npm install --audit false --color false --progress false --verbose \
				|| die "npm install failed"
		fi
	fi
}

src_compile() {
	# Build TypeScript → dist/
	export npm_config_production=false
	npm run build || die "npm run build failed"
	# npm run build calls "node index.js writehash" which writes "unknown"
	# because there's no git repo. Overwrite it with the correct hash.
	echo "${COMMIT}" > dist/.hash || die

	# Rebuild native addons for the current Node.js ABI
	einfo "Rebuilding native addons"

	# Force rebuild of @serialport/bindings-cpp
	cd node_modules/@serialport/bindings-cpp || die
	node-gyp rebuild || die "Failed to rebuild @serialport/bindings-cpp"
	cd - >/dev/null || die

	# Rebuild any other native modules
	npm rebuild || die "npm rebuild failed"
}

src_test() {
	# Skip tests as they require specific test environment
	# and have minor issues with commit hash detection
	:
}

src_install() {

	echo -e "\nadvanced:" >>data/configuration.yaml
	echo -e "  network_key: GENERATE" >>data/configuration.yaml
	echo -e "  pan_id: GENERATE" >>data/configuration.yaml
	echo -e "  log_directory: /var/log/${PN}" >>data/configuration.yaml

	nodejs-mod_src_install

	keepdir /var/log/${PN}

	insinto /var/lib/${PN}
	doins data/configuration.yaml

	dotmpfiles "${FILESDIR}"/zigbee2mqtt.conf

	doinitd "${FILESDIR}"/${PN}
	systemd_dounit "${FILESDIR}/${PN}.service"

	dodir /etc/env.d
	echo "CONFIG_PROTECT=\"/var/lib/${PN}"\" >>"${ED}"/etc/env.d/90${PN} || die
}

pkg_postinst() {
	tmpfiles_process zigbee2mqtt.conf
}
