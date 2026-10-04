#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d .repo || ! -d build ]]; then
    echo "Run this script from the root of a LineageOS source checkout." >&2
    exit 1
fi

manifest=.repo/local_manifests/piano.xml
mkdir -p .repo/local_manifests
if [[ -e "$manifest" ]]; then
    echo "$manifest already exists; review it and run repo sync." >&2
    exit 1
fi

cat > "$manifest" <<'XML'
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
XML

repo sync device/xiaomi/piano device/xiaomi/sm8750-common \
    vendor/xiaomi/piano vendor/xiaomi/sm8750-common \
    device/xiaomi/piano-kernel vendor/xiaomi/piano-miuicamera
