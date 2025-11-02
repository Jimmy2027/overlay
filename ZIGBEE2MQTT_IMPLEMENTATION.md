# Zigbee2MQTT Gentoo Ebuild Implementation

## Objective

Install zigbee2mqtt version 2.6.3 on a Gentoo Linux system using a custom ebuild in the `jimmys_overlay` repository.

## Repository Structure

- **Working directory**: `/home/hendrik/src/overlay` (local git repository)
- **System overlay**: `/var/db/repos/jimmys_overlay` (where Portage reads ebuilds)
- **Sync command**: `cd /var/db/repos/jimmys_overlay && sudo git pull locoverlay main`

## Initial Approach

Started with an existing zigbee2mqtt ebuild from HomeAssistantRepository (version 1.40.1) and adapted it for version 2.6.3.

### Files Created

1. **Main ebuild**: `app-misc/zigbee2mqtt/zigbee2mqtt-2.6.3.ebuild`
2. **Service files** (copied from upstream):
   - `files/zigbee2mqtt` (OpenRC init script)
   - `files/zigbee2mqtt.service` (systemd service)
   - `files/zigbee2mqtt.conf` (tmpfiles configuration)
3. **Metadata**: `metadata.xml`
4. **Eclasses** (copied from HomeAssistantRepository):
   - `eclass/nodejs-mod.eclass`
   - `eclass/nodejs.eclass`

## Major Issues Encountered & Solutions

### Issue 1: Missing Pre-packaged node_modules Tarball

**Problem**: Original ebuild expected a pre-built `node_modules` tarball that didn't exist for version 2.6.3.

**Error**:
```
No digest file available and download failed
```

**Solution**: Modified `src_prepare` to install node_modules during build using npm:
```bash
src_prepare() {
    nodejs-mod_src_prepare

    if [[ ! -d node_modules ]]; then
        einfo "Installing node modules via npm"
        export npm_config_production=false
        if [[ -f package-lock.json ]]; then
            npm ci --audit false --color false --progress false --verbose || die
        else
            npm install --audit false --color false --progress false --verbose || die
        fi
    fi
}
```

### Issue 2: Network Sandbox Blocking npm

**Problem**: Portage's `network-sandbox` feature blocked npm from accessing the network.

**Error**:
```
npm http fetch GET https://registry.npmjs.org/npm attempt 1 failed with EAI_AGAIN
```

**Solution**: Added `RESTRICT="network-sandbox"` to the ebuild.

### Issue 3: Missing TypeScript Compilation

**Problem**: The ebuild didn't compile TypeScript during build, so `dist/` directory was missing at runtime. This caused zigbee2mqtt to attempt rebuilding at runtime, which failed.

**Error** (when running zigbee2mqtt):
```
Building Zigbee2MQTT... (hash changed), failed
Error: Command failed: pnpm run prepack
```

**Solution**: Added `src_compile` function to build TypeScript during the ebuild compilation phase:
```bash
src_compile() {
    # Build TypeScript → dist/
    export npm_config_production=false
    npm run build || die "npm run build failed"

    # npm run build calls "node index.js writehash" which writes "unknown"
    # because there's no git repo. Overwrite it with the correct hash.
    echo "${COMMIT}" > dist/.hash || die
}
```

### Issue 4: Hash File Containing "unknown"

**Problem**: `npm run build` executes `node index.js writehash`, which writes "unknown" to `dist/.hash` when there's no git repository. At runtime, zigbee2mqtt compares this hash with the current working directory's git hash, causing a mismatch.

**Investigation**:
```bash
# Installed hash file contained:
$ cat /usr/lib64/node_modules/zigbee2mqtt/dist/.hash
unknown

# Runtime check in index.js:
const distHash = fs.readFileSync(hashFile, "utf8");  // "unknown"
const hash = await currentHash();  // git hash from cwd or "unknown"
if (hash !== "unknown" && distHash !== hash) {
    await build("hash changed");  // This triggered the rebuild
}
```

**Solution**: Overwrite `dist/.hash` with the correct commit hash AFTER `npm run build` completes:
```bash
echo "${COMMIT}" > dist/.hash || die
```

**Important Note**: When running zigbee2mqtt, ensure you're NOT in a git repository directory, as the runtime will compare the `dist/.hash` with the current directory's git hash.

### Issue 5: Missing Native Node.js Addons

**Problem**: The `@serialport/bindings-cpp` native addon wasn't compiled for the current Node.js ABI (137 for Node.js 24.7.0).

**Error** (when running zigbee2mqtt):
```
Error: No native build was found for platform=linux arch=x64 runtime=node abi=137 uv=1 libc=glibc node=24.7.0
    loaded from: /usr/lib64/node_modules/zigbee2mqtt/node_modules/@serialport/bindings-cpp
```

**Investigation**:
- `npm rebuild` didn't actually compile the native addon
- `npm run install` (in @serialport/bindings-cpp) only runs `node-gyp-build`, which tries to load prebuilt binaries but doesn't compile

**Solution**: Use `node-gyp rebuild` directly:
```bash
src_compile() {
    # ... TypeScript build ...

    # Rebuild native addons for the current Node.js ABI
    einfo "Rebuilding native addons"

    # Force rebuild of @serialport/bindings-cpp
    cd node_modules/@serialport/bindings-cpp || die
    node-gyp rebuild || die "Failed to rebuild @serialport/bindings-cpp"
    cd - >/dev/null || die

    # Rebuild any other native modules
    npm rebuild || die "npm rebuild failed"
}
```

**Build Dependencies Added**:
```bash
BDEPEND="
    net-libs/nodejs[npm]
    sys-devel/gcc
    virtual/pkgconfig
    dev-lang/python:*
"
```

## Final Ebuild Structure

```bash
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

    # Install node modules (include dev deps for tsc)
    if [[ ! -d node_modules ]]; then
        einfo "Installing node modules via npm"
        export npm_config_production=false
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
    # Skip tests
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
```

## Build & Test Commands

### 1. Update Manifest
```bash
cd /home/hendrik/src/overlay/app-misc/zigbee2mqtt
ebuild zigbee2mqtt-2.6.3.ebuild manifest
```

### 2. Commit Changes
```bash
git add app-misc/zigbee2mqtt/zigbee2mqtt-2.6.3.ebuild
git commit --no-gpg-sign -m "Your commit message"
```

### 3. Sync to System Overlay
```bash
cd /var/db/repos/jimmys_overlay
sudo git pull locoverlay main
```

### 4. Emerge Package
```bash
sudo emerge -v app-misc/zigbee2mqtt::jimmys_overlay
```

### 5. Test zigbee2mqtt
```bash
# IMPORTANT: Run from a non-git directory (e.g., home directory)
cd ~
zigbee2mqtt
```

## Current Status (as of 2025-11-02)

**Last Build**: Failed - `node-gyp: command not found`

**Last Change**: Modified `src_compile` to use `node-gyp rebuild` directly, but node-gyp isn't in PATH

**Current Issue**: Need to use `npx node-gyp` instead of `node-gyp` to use npm's bundled version

**Next Step**: Update ebuild to use `npx node-gyp rebuild`

## Known Issues & Workarounds

1. **Git Hash Detection**: When running zigbee2mqtt, ensure you're NOT in a git repository directory. The `index.js` file checks the current working directory's git hash and compares it with `dist/.hash`. If they don't match, it tries to rebuild.

2. **Network Sandbox**: The ebuild requires `RESTRICT="network-sandbox"` because npm needs network access to download packages during the build.

3. **Native Addons**: The `@serialport/bindings-cpp` module requires compilation for the specific Node.js ABI. Simple `npm rebuild` doesn't work; we need to explicitly run `node-gyp rebuild` in the module's directory.

## Upstream References

- **Zigbee2MQTT GitHub**: https://github.com/Koenkk/zigbee2mqtt
- **Commit for v2.6.3**: `6e001b48ec278c6c141579c9eacc045f190fc289`
- **Original ebuild source**: HomeAssistantRepository overlay

## Future Improvements

1. Consider creating a pre-built node_modules tarball to avoid network access during emerge
2. Investigate using pnpm instead of npm (upstream uses pnpm)
3. Add proper test phase if upstream tests can run in the build environment
4. Consider splitting native addon compilation into a separate package

## Debugging Commands

```bash
# Check if native addon was compiled
ls -la /usr/lib64/node_modules/zigbee2mqtt/node_modules/@serialport/bindings-cpp/build/

# Check hash file content
cat /usr/lib64/node_modules/zigbee2mqtt/dist/.hash

# Check current git hash (from zigbee2mqtt source)
git rev-parse --short=8 HEAD

# Monitor background build
# Replace <id> with actual background bash ID
sudo BashOutput <id>

# Check portage build logs
ls -la /var/tmp/portage/app-misc/zigbee2mqtt-2.6.3/
```

## Contact & Resources

- Gentoo ebuild guide: https://wiki.gentoo.org/wiki/Basic_guide_to_write_Gentoo_Ebuilds
- GURU contributor guidelines: https://wiki.gentoo.org/wiki/Project:GURU/Information_for_Contributors
- Node.js native addons: https://nodejs.org/api/addons.html
