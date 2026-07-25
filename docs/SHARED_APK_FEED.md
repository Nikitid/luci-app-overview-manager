# Shared OpenWrt 25.12 APK feed

## Trust identity

Overview Manager uses the existing IKEv2 Manager P-256 release key as the
shared publisher identity.

- tracked public key: `keys/nikitid-openwrt-release.pem`;
- legacy public-key name: `ikev2-manager-release.pem`;
- SHA-256:
  `f27474d9261f1084350cf4ba34ecdff29e533769c36483d8dd85566e30a6a703`;
- private key source: protected `OPENWRT_APK_SIGNING_KEY` CI secret only.

The two public-key files may have different names but must contain identical
key material. Existing routers with the legacy key already trust Overview
Manager packages signed by the shared private key.

## Feed ownership

The stable `apk-feed` branch in `ikev2-manager-openwrt` remains the single
writer of the shared `packages.adb` index. Application repositories publish
signed APK release assets but must not independently overwrite that branch.

For an Overview Manager release:

1. tag and publish the Overview Manager release;
2. build and verify `luci-app-overview-manager-<version>.apk` with
   `scripts/build-apk-release.sh`;
3. make the signed APK available as a release asset;
4. refresh the central feed from `ikev2-manager-openwrt`;
5. verify the package and rebuilt index with the shared public key;
6. publish the rebuilt `packages.adb`, all current APKs and the public key.

The central index must retain existing packages when one application is
updated. It must never be regenerated from only the package that triggered the
workflow.

## Bootstrap compatibility

`scripts/install-openwrt25.sh` accepts either:

- `/etc/apk/keys/nikitid-openwrt-release.pem`; or
- `/etc/apk/keys/ikev2-manager-release.pem`.

It also reuses the existing `ikev2-manager.list` repository entry when it
already points to the shared feed. New installations use generic
`nikitid-openwrt` names.

The current feed supports `mediatek/filogic` with
`aarch64_cortex-a53`. Additional targets require signed APKs for those
architectures and corresponding index entries.
