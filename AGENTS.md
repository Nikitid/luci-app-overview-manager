# Repository Guidelines

## Scope

This repository contains a LuCI application for ordering and hiding widgets on
the OpenWrt Status Overview page.

## Working rules

- Preserve OpenWrt 24.10 and 25.12 compatibility.
- Do not patch, rename or delete widget files owned by other packages.
- Keep the saved layout in UCI and restore stock LuCI behavior on uninstall.
- Match the adjacent IKEv2 Manager and MTProto Monitor visual conventions.
- Do not reboot the router or restart WAN.
- Translate user-visible strings with `_()` and keep `po/` in sync with the
  sources. Keep msgids on one line and free of repeated whitespace: `_()`
  normalises whitespace before hashing, while `po2lmo` hashes the raw msgid.
- The Overview include runs on every poll cycle. Keep it free of DOM writes
  when the layout has not changed.

## Validation

```sh
./scripts/ci-check.sh
```
