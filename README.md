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

Run the setup script:

```sh
curl -fsSLO https://raw.githubusercontent.com/ALXP-DANIEL/android_device_xiaomi_piano/main/sync-device.sh
bash sync-device.sh
```

Choose your ROM, the trees and branches to sync, then optional TWRP or
OrangeFox trees. Recovery trees use a separate directory. For ROM trees,
run from your ROM source checkout.

EvoX requires a compatible device branch; one is not published yet.
