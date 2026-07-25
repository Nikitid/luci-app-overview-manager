#!/bin/sh

set -eu

fail() {
  printf 'check-apk-trust: %s\n' "$*" >&2
  exit 1
}

root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
. "$root/apk-feed.env"
public_key="$root/$OPENWRT_APK_KEY_FILE"

[ -r "$public_key" ] || fail "public key not found: $OPENWRT_APK_KEY_FILE"
actual="$(sha256sum "$public_key" | awk '{ print $1 }')"
[ "$actual" = "$OPENWRT_APK_TRUST_SHA256" ] ||
  fail "public key checksum mismatch: $actual"
openssl pkey -pubin -in "$public_key" -noout >/dev/null 2>&1 ||
  fail 'release public key is not a valid PEM public key'

tracked_files() {
  find "$root" -path "$root/.git" -prune -o \
    -path "$root/build" -prune -o -path "$root/dist" -prune -o \
    -type f -print
}

# Keep this in sync with the secret patterns in .gitignore. The previous
# anchored form missed names such as release-private.pem.
if tracked_files |
    grep -Ei '\.key$|private[^/]*\.(pem|key)$|signing[^/]*\.(pem|key)$|/signing/' \
    >/dev/null; then
  fail 'private signing material is present in the source tree'
fi

# A private key under an unexpected name still has recognisable contents. The
# scan runs in a subshell, so it only reports and leaves failing to the caller.
key_material="$(tracked_files |
  grep -Ei '\.(pem|key|crt)$' |
  while IFS= read -r candidate; do
    if grep -q 'PRIVATE KEY' "$candidate"; then
      printf '%s\n' "${candidate#"$root"/}"
    fi
  done)"
[ -z "$key_material" ] ||
  fail "private key material found in: $(printf '%s' "$key_material" | tr '\n' ' ')"

grep -Fq "OPENWRT_APK_TRUST_SHA256=$OPENWRT_APK_TRUST_SHA256" \
  "$root/scripts/install-openwrt25.sh" ||
  fail 'bootstrap public-key checksum is out of sync'
grep -Fq "OPENWRT_APK_CHANNEL_BASE=$OPENWRT_APK_CHANNEL_BASE" \
  "$root/scripts/install-openwrt25.sh" ||
  fail 'bootstrap feed URL is out of sync'

printf 'APK trust configuration OK\n'
