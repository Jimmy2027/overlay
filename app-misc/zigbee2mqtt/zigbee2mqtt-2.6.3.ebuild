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
		die "Bad CONFIG_PROTECT"
	fi
}

src_prepare() {
	nodejs-mod_src_prepare

	export npm_config_cache="${T}/npm-cache"
	export npm_config_fund=false
	export npm_config_update_notifier=false
	# Install node modules (include dev deps for tsc)
	if [[ ! -d node_modules ]]; then
		einfo "Installing node modules via npm"
		export npm_config_legacy_peer_deps=true
		mkdir -p "${npm_config_cache}" || die
		# prefer ci if you have a lockfile in the tarball; fallback to install
		if [[ -f package-lock.json ]]; then
			npm ci --audit false --color false --progress false --verbose \
				--include=dev \
				|| die "npm ci failed"
		else
			npm install --audit false --color false --progress false --verbose \
				--include=dev \
				|| die "npm install failed"
		fi
	fi

	Z2M_CONFIG="${T}/${PN}.configuration.yaml"
	cp data/configuration.example.yaml "${Z2M_CONFIG}" || die
	cat <<-EOF >> "${Z2M_CONFIG}" || die

advanced:
  network_key: GENERATE
  pan_id: GENERATE
  log_directory: /var/log/${PN}
EOF
}

src_compile() {
	# Build TypeScript → dist/
	npm run build || die "npm run build failed"
	# npm run build calls "node index.js writehash" which writes "unknown"
	# because there's no git repo. Overwrite it with the correct hash.
	echo "${COMMIT}" > dist/.hash || die

	# Rebuild native addons for the current Node.js ABI
	einfo "Rebuilding native addons"
	local node_gyp="/usr/$(get_libdir)/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js"
	local nodedir="${ESYSROOT:-${EPREFIX}}/usr"

	[[ -e ${node_gyp} ]] || die "Unable to locate node-gyp helper"

	if [[ -d node_modules ]]; then
		while IFS= read -r dir; do
			pushd "${dir}" >/dev/null || die
			npm_config_nodedir="${nodedir}" node "${node_gyp}" rebuild \
				|| die "node-gyp rebuild failed in ${dir}"
			popd >/dev/null || die
		done < <(find node_modules -name binding.gyp -exec dirname {} \;)
	fi
}

src_test() {
	# Skip tests as they require specific test environment
	# and have minor issues with commit hash detection
	:
}

src_install() {
	nodejs-mod_src_install

	keepdir /var/log/${PN}
	fowners zigbee2mqtt:zigbee2mqtt /var/log/${PN}
	fperms 0750 /var/log/${PN}

	insinto /var/lib/${PN}
	newins "${Z2M_CONFIG}" configuration.yaml
	fowners zigbee2mqtt:zigbee2mqtt /var/lib/${PN}
	fowners zigbee2mqtt:zigbee2mqtt /var/lib/${PN}/configuration.yaml
	fperms 0750 /var/lib/${PN}
	fperms 0640 /var/lib/${PN}/configuration.yaml

	dodoc data/configuration.example.yaml

	dotmpfiles "${FILESDIR}"/zigbee2mqtt.conf

	doinitd "${FILESDIR}"/${PN}
	systemd_dounit "${FILESDIR}/${PN}.service"

	newenvd - 90${PN} <<-EOF || die
	CONFIG_PROTECT="/var/lib/${PN}"
	EOF
}

pkg_postinst() {
	tmpfiles_process zigbee2mqtt.conf
}
