#!/bin/sh

set -eu

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

mkdir -p "$tmp/bin"
cat >"$tmp/bin/wget" <<'EOF'
#!/bin/sh
[ "${FAKE_WGET_FAIL:-0}" = 0 ] || exit 1
output=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -O)
      output="$2"
      shift 2
      ;;
    *) shift ;;
  esac
done
[ -n "$output" ]
cp "${FAKE_PUBLIC_KEY:?}" "$output"
printf 'wget\n' >>"${FAKE_LOG:?}"
EOF

cat >"$tmp/bin/apk" <<'EOF'
#!/bin/sh
printf 'apk %s\n' "$*" >>"${FAKE_LOG:?}"
case "${1:-}:${2:-}" in
  update:*)
    [ "${FAKE_APK_FAIL_UPDATE:-0}" = 0 ]
    ;;
  info:--installed)
    [ "${FAKE_INSTALLED:-0}" = 1 ]
    ;;
  *)
    exit 0
    ;;
esac
EOF
chmod 755 "$tmp/bin/wget" "$tmp/bin/apk"

make_root() {
  target="$1"
  mkdir -p "$target/etc/apk/keys" "$target/etc/apk/repositories.d"
  cat >"$target/etc/openwrt_release" <<'EOF'
DISTRIB_ID='OpenWrt'
DISTRIB_RELEASE='25.12.5'
DISTRIB_TARGET='mediatek/filogic'
DISTRIB_ARCH='aarch64_cortex-a53'
EOF
  : >"$target/etc/apk/world"
}

run_installer() {
  target="$1"
  PATH="$tmp/bin:$PATH" \
  FAKE_LOG="$tmp/actions.log" \
  FAKE_PUBLIC_KEY="$root/keys/nikitid-openwrt-release.pem" \
  FAKE_INSTALLED="${FAKE_INSTALLED:-0}" \
  FAKE_WGET_FAIL="${FAKE_WGET_FAIL:-0}" \
  FAKE_APK_FAIL_UPDATE="${FAKE_APK_FAIL_UPDATE:-0}" \
  OVERVIEW_INSTALL_ROOT="$target" \
  OVERVIEW_APK_RELEASE_BASE=https://example.invalid/releases \
  OVERVIEW_APK_CHANNEL_BASE=https://example.invalid/shared-feed \
    "$root/scripts/install-openwrt25.sh"
}

fresh="$tmp/fresh"
make_root "$fresh"
: >"$tmp/actions.log"
run_installer "$fresh" >/dev/null
cmp -s "$root/keys/nikitid-openwrt-release.pem" \
  "$fresh/etc/apk/keys/nikitid-openwrt-release.pem"
grep -qx 'https://example.invalid/shared-feed/packages.adb' \
  "$fresh/etc/apk/repositories.d/nikitid-openwrt.list"
grep -qx 'wget' "$tmp/actions.log"
grep -qx 'apk update' "$tmp/actions.log"
grep -qx 'apk add --simulate luci-app-overview-manager' "$tmp/actions.log"
grep -qx 'apk add luci-app-overview-manager' "$tmp/actions.log"

legacy="$tmp/legacy"
make_root "$legacy"
cp "$root/keys/nikitid-openwrt-release.pem" \
  "$legacy/etc/apk/keys/ikev2-manager-release.pem"
printf '%s\n' 'https://example.invalid/shared-feed/packages.adb' \
  >"$legacy/etc/apk/repositories.d/ikev2-manager.list"
: >"$tmp/actions.log"
FAKE_WGET_FAIL=1 FAKE_INSTALLED=1 run_installer "$legacy" >/dev/null
[ ! -e "$legacy/etc/apk/keys/nikitid-openwrt-release.pem" ]
[ ! -e "$legacy/etc/apk/repositories.d/nikitid-openwrt.list" ]
! grep -q '^wget$' "$tmp/actions.log"
grep -qx 'apk upgrade --simulate luci-app-overview-manager' "$tmp/actions.log"
grep -qx 'apk upgrade luci-app-overview-manager' "$tmp/actions.log"

failed="$tmp/failed"
make_root "$failed"
: >"$tmp/actions.log"
if FAKE_APK_FAIL_UPDATE=1 run_installer "$failed" >/dev/null 2>&1; then
  printf 'bootstrap succeeded despite apk update failure\n' >&2
  exit 1
fi
[ ! -e "$failed/etc/apk/keys/nikitid-openwrt-release.pem" ]
[ ! -e "$failed/etc/apk/repositories.d/nikitid-openwrt.list" ]

printf 'APK bootstrap tests OK\n'
