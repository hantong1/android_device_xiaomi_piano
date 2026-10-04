# Xiaomi Pad 8 Pro (piano)

Unofficial LineageOS 23.2, TWRP and OrangeFox trees for the Xiaomi Pad 8 Pro
(Snapdragon 8 Elite / SM8750).

Lineage uses the stock audio and display stack from HyperOS Global OS3.0.304.
The cleaned base is in development and awaits build and device validation.

## Status

| Component | Status |
| --- | --- |
| LineageOS 23.2 stock base | Validation pending |
| MiuiCamera, Dolby and volume boost | Integrated; validation pending |
| Stylus, keyboard and cover support | Retained; validation pending |
| Cellular connectivity | Not supported; Wi-Fi-only tablet |
| TWRP and OrangeFox | See [releases](../../releases) |

## Branches

| Branch | Checkout path |
| --- | --- |
| `lineage-23.2` | `device/xiaomi/piano` |
| `device-common-16` | `device/xiaomi/sm8750-common` |
| `vendor-16` | `vendor/xiaomi/piano` |
| `vendor-common-16` | `vendor/xiaomi/sm8750-common` |
| `kernel-16` | `device/xiaomi/piano-kernel` |
| `miuicamera-16` | `vendor/xiaomi/piano-miuicamera` |
| `twrp-16` | TWRP: `device/xiaomi/piano` |
| `ofox-16` | OrangeFox: `device/xiaomi/piano` |

## Build

In a LineageOS 23.2 source checkout, save this as
`.repo/local_manifests/piano.xml`, then run `repo sync`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="piano" fetch="https://github.com/ALXP-DANIEL" />
  <project name="android_device_xiaomi_piano" path="device/xiaomi/piano" remote="piano" revision="lineage-23.2" />
  <project name="android_device_xiaomi_piano" path="device/xiaomi/sm8750-common" remote="piano" revision="device-common-16" />
  <project name="android_device_xiaomi_piano" path="vendor/xiaomi/piano" remote="piano" revision="vendor-16" clone-depth="1" />
  <project name="android_device_xiaomi_piano" path="vendor/xiaomi/sm8750-common" remote="piano" revision="vendor-common-16" clone-depth="1" />
  <project name="android_device_xiaomi_piano" path="device/xiaomi/piano-kernel" remote="piano" revision="kernel-16" clone-depth="1" />
  <project name="android_device_xiaomi_piano" path="vendor/xiaomi/piano-miuicamera" remote="piano" revision="miuicamera-16" clone-depth="1" />
</manifest>
```

Set `PIANO_AVB_KEY_PATH` to a source-relative symlink to your existing external
RSA4096 AVB key. Keep the same key when building updates.

```sh
export PIANO_AVB_KEY_PATH=piano-local-keys/lineage-23.2-avb.pem
device/xiaomi/piano/patches/apply-patches.sh
source build/envsetup.sh
breakfast piano userdebug
m bacon
```

Recovery build instructions are on the `twrp-16` and `ofox-16` branches.

## Install

Follow the selected release's firmware and recovery requirements. In recovery,
choose ADB sideload:

```sh
adb sideload lineage-23.2-RELEASE-piano.zip
```

No-wipe updates to the new EROFS base are awaiting validation.
Keep the bootloader unlocked.

[Downloads and release notes](../../releases).
