# Overview Manager for OpenWrt

[Русский](README.md)

A LuCI application for arranging the cards on the `Status -> Overview` page.
Widgets can be reordered by dragging, moved with buttons, and hidden entirely.

## How it works

Stock LuCI loads the files in
`/www/luci-static/resources/view/status/include` in alphabetical order.
Overview Manager adds an early service include, matches the cards to their
source files and applies the layout stored in UCI to the DOM.

Files belonging to other packages are never modified, renamed or deleted.
Removing Overview Manager restores stock LuCI behaviour on its own.

## Compatibility

- official OpenWrt `24.10.x` with `opkg`;
- official OpenWrt `25.12.x` with `apk`;
- the stock `luci-mod-status` Status Overview page;
- third-party widgets installed as a LuCI status include.

On OpenWrt 25.12 the stock Hide button keeps its state separately, in the
`localStorage` of one browser. It keeps working independently of the shared
Overview Manager layout.

## Translations

The interface uses the stock LuCI mechanism: `_()` in JavaScript and gettext
catalogues in `po/`. At build time `po/<lang>/overview-manager.po` is compiled
into `/usr/lib/lua/luci/i18n/overview-manager.<lang>.lmo` and ships in the main
package, and `/etc/uci-defaults/luci-app-overview-manager` registers the
language in `luci.languages`. The interface language follows the LuCI setting;
no separate `luci-i18n-*` package is needed.

The package translates only its own strings: a fully Russian LuCI also needs
`luci-i18n-base-ru`. A new language is added as a
`po/<lang>/overview-manager.po` catalogue; `scripts/test-po2lmo.py` checks that
the catalogues match the sources.

## Limitations

A LuCI status include has no common description of its internals: every widget
implements arbitrary `load()` and `render()`. Overview Manager therefore
arranges the order and visibility of cards, but does not edit their contents.

A hidden widget is not displayed, but its own data collection may still run on
the page poll.

## Build and check

```sh
./scripts/ci-check.sh
```

The IPK is written to `dist/`. The APK is built with the official OpenWrt 25.12
SDK:

```sh
OPENWRT_SDK_DIR=/path/to/openwrt-sdk-25.12.x-target \
  ./scripts/build-apk.sh
```

A release APK is signed with the shared publisher key:

```sh
OPENWRT_SDK_DIR=/path/to/openwrt-sdk-25.12.x-target \
OPENWRT_APK_SIGNING_KEY=/secure/path/release-private.pem \
  ./scripts/build-apk-release.sh
```

The private key is not stored in the repository. This repository builds and
signs only its own package and publishes it as a release asset; the index is
assembled by [Nikitid/openwrt-feed](https://github.com/Nikitid/openwrt-feed).
See [Joining the shared feed](https://github.com/Nikitid/openwrt-feed/blob/main/docs/MEMBER_INTEGRATION.md).

## Installation

### OpenWrt 24.10

Download `luci-app-overview-manager_*_all.ipk` from
[Releases](https://github.com/Nikitid/luci-layout/releases) and upload it
through `System -> Software -> Upload Package`.

### OpenWrt 25.12

```sh
wget -O /tmp/nikitid-feed.sh \
  https://raw.githubusercontent.com/Nikitid/openwrt-feed/feed/install.sh
sh /tmp/nikitid-feed.sh luci-app-overview-manager
```

The installer verifies the publisher public key against a pinned checksum,
adds the shared signed repository and installs only the named package.

Later upgrades:

```sh
apk update
apk upgrade luci-app-overview-manager
```

Only Overview Manager is upgraded, never every package on the router.

## Documentation

- [Repository map](docs/MAP.md) - where things live
- [Architecture](docs/ARCHITECTURE.md) - why the page is built this way
- [Working rules](AGENTS.md)

## License

[MIT](LICENSE)
