# Shared OpenWrt 25.12 APK feed

Overview Manager is a member application of the shared feed
[Nikitid/openwrt-feed](https://github.com/Nikitid/openwrt-feed). The member
contract is `docs/MEMBER_INTEGRATION.md` in that repository;
`Nikitid/ikev2-openwrt` is the reference implementation.

## Trust identity

One publisher key signs every member package and the index.

- tracked public key: `keys/nikitid-openwrt-release.pem`;
- SHA-256:
  `f27474d9261f1084350cf4ba34ecdff29e533769c36483d8dd85566e30a6a703`;
- private key source: protected `OPENWRT_APK_SIGNING_KEY` Actions secret only,
  configured identically in every member repository.

A per-application key would add another trust anchor to every router without
adding isolation, because apk binds a key to neither a package nor a
repository.

## What this repository does

A stable tag builds the package with the pinned OpenWrt SDK, signs it with the
publisher key and publishes it as the release asset
`luci-app-overview-manager-<version>.apk`.

It does not build an index, does not download sibling applications and does not
host a feed URL. A release therefore never depends on another application being
ready. The feed is hosted separately so that renaming or retiring this project
cannot move a URL already recorded in `/etc/apk/repositories.d` on an installed
router.

After a release the workflow can notify the feed with a `repository_dispatch`
using `OPENWRT_FEED_DISPATCH_TOKEN`, so the index rebuilds at once. That step is
best effort by contract: it exits successfully when the secret is absent,
because the feed also rebuilds on a schedule and on manual dispatch, so a
missing or expired token delays the index instead of failing a release.

**That token is deliberately not configured here.** Triggering another
repository needs a credential that would have to be copied into every member
repository, and its blast radius is write access to the feed every router
trusts. The only thing gained is not waiting for the scheduled rebuild, which
is a poor trade for infrequent releases. Refresh the index directly instead:

```sh
gh workflow run "Build feed" --repo Nikitid/openwrt-feed
```

Reversing this decision needs no change to the workflow — only the secret.

Registration lives in the feed repository, as an `owner/repo:package` entry in
`FEED_MEMBERS`. A member without a published release is skipped, so until the
first tag is published the application is simply absent from the index.

## Installation and updates

The feed ships one installer for every member application, so this repository
carries no bootstrap script of its own:

```sh
wget -O /tmp/nikitid-feed.sh \
  https://raw.githubusercontent.com/Nikitid/openwrt-feed/feed/install.sh
sh /tmp/nikitid-feed.sh luci-app-overview-manager
```

Every documented and scripted package transaction names the packages it
touches:

```sh
apk update
apk upgrade luci-app-overview-manager
```

A blanket upgrade of the whole router is never used or documented;
`scripts/check-apk-trust.sh` fails the build if one appears.

## Targets

The feed currently builds for `mediatek/filogic` with `aarch64_cortex-a53`.
Additional targets need signed packages for those architectures and matching
index entries. The IPK path is architecture-independent and works on OpenWrt
24.10 regardless of the feed.
