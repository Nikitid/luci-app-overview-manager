# Overview Manager for OpenWrt

LuCI application for configuring cards on `Status -> Overview`. It can reorder
widgets with drag and drop or arrow buttons and hide widgets that are not
needed.

The application does not patch, rename or delete files owned by other
packages. It adds an early status include and applies the UCI-backed layout to
the rendered Overview DOM. Removing the package restores stock LuCI behavior.

Supported targets are official OpenWrt 24.10 with `opkg` and OpenWrt 25.12
with `apk`.

Interface strings use the stock LuCI mechanism: `_()` in JavaScript with
gettext catalogs under `po/`. Each `po/<lang>/overview-manager.po` is compiled
into `/usr/lib/lua/luci/i18n/overview-manager.<lang>.lmo` and ships inside the
main package, and `/etc/uci-defaults/luci-app-overview-manager` registers the
language in `luci.languages`. The interface follows the configured LuCI
language and no separate `luci-i18n-*` package is required.

The package translates its own strings only, so a fully translated LuCI still
needs the matching `luci-i18n-base-*` package.

LuCI status includes do not expose a shared schema for their internal fields.
Overview Manager therefore controls card order and visibility but does not
edit widget content.

Run `./scripts/ci-check.sh` to validate the source and build a deterministic
IPK.

OpenWrt 25.12 releases use the shared P-256 publisher key already used by
IKEv2 Manager. The private key is supplied only through the protected
`OPENWRT_APK_SIGNING_KEY` CI secret. See
[Shared APK feed](docs/SHARED_APK_FEED.md) for the publishing contract and
legacy-key compatibility.

[MIT](LICENSE)
