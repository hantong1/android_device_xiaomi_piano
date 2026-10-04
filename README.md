# Xiaomi Pad 8 Pro (piano)

Device trees for the Xiaomi Pad 8 Pro, powered by Snapdragon 8 Elite (SM8750).
LineageOS 23.2 uses Xiaomi's stock kernel, audio and display stack from
HyperOS Global OS3.0.304.

## Branches

| Branch | Tree |
| --- | --- |
| `lineage-23.2` | Device |
| `device-common-16` | SM8750 common device |
| `vendor-16` | Device vendor |
| `vendor-common-16` | SM8750 common vendor |
| `kernel-16` | Prebuilt kernel and modules |
| `miuicamera-16` | MiuiCamera |
| `twrp-16` | TWRP recovery |
| `ofox-16` | OrangeFox recovery |

## Sync device trees

Run from the root of a LineageOS source checkout:

```sh
curl -fsSL https://raw.githubusercontent.com/ALXP-DANIEL/android_device_xiaomi_piano/main/sync-device.sh | bash
```
