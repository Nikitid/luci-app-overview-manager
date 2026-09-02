# Repository Guidelines

## Start of Work

- Read `docs/MAP.md` to find the files a task touches.
- Read the sibling OpenWrt repositories' `docs/TRAPS.md` before changing LuCI
  code: the resource-cache, ACL-path and CSS-specificity traps recorded there
  apply to every LuCI application here.
- Run `git status -sb` and preserve unrelated changes.


## Scope

This repository contains a LuCI application for ordering and hiding widgets on
the OpenWrt Status Overview page.

Read [Implementation notes](docs/IMPLEMENTATION_NOTES.md) before changing the
Overview include, the translation catalogs or anything that ships to the router.
It records the upstream LuCI behaviour these depend on, which is not visible
from this repository, and how to re-verify each point.

Documentation splits by audience. `docs/` is published and covers the codebase,
the upstream behaviour it relies on and the feed contract. `local/` is
untracked and holds notes tied to one machine, router or account — device
access, deployment and verification procedures, release runbook, secret
handling. Keep hostnames, paths and credential handling out of `docs/`.

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
- This repository is a member of the shared feed and signs only its own
  package: no feed URL, no bootstrap script, no index. See
  [Shared APK feed](docs/SHARED_APK_FEED.md).
- Name the package in every package-manager command, in scripts and in docs
  alike. Never upgrade the whole router.
- Shell that ships to the router must run under BusyBox ash and BusyBox
  utilities. `scripts/check-busybox-compat.sh` scans the staged package,
  because the build host's GNU coreutils hide the difference.

## Validation

```sh
./scripts/ci-check.sh
```
