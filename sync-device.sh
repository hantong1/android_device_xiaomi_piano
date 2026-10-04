#!/usr/bin/env bash
set -euo pipefail

rom=lineage
tree_selection=all
interactive=$([[ $# -eq 0 ]] && echo yes || echo no)
recovery=none
device_branch=
recovery_dir=
usage() {
    echo "Usage: bash sync-device.sh [--rom lineage|evox|none] [--device-branch BRANCH] [--recovery none|twrp|ofox|both] [--recovery-dir PATH]"
}
while [[ $# -gt 0 ]]; do
    case "$1" in
        --rom|--device-branch|--recovery|--recovery-dir)
            [[ $# -ge 2 && -n "$2" ]] || { usage >&2; exit 1; }
            case "$1" in
                --rom) rom=$2 ;;
                --device-branch) device_branch=$2 ;;
                --recovery) recovery=$2 ;;
                --recovery-dir) recovery_dir=$2 ;;
            esac
            shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done
if [[ "$interactive" == yes && -z "${PIANO_NONINTERACTIVE:-}" && -t 0 ]]; then
    echo "ROM tree:"
    echo "  1) LineageOS"
    echo "  2) Evolution X (requires an EvoX device branch)"
    echo "  3) Recovery only"
    read -r -p "Choose [1]: " choice
    case "${choice:-1}" in
        1) rom=lineage ;;
        2) rom=evox; read -r -p "EvoX device branch: " device_branch ;;
        3) rom=none ;;
        *) echo "Invalid ROM selection." >&2; exit 1 ;;
    esac
    if [[ "$rom" != none ]]; then
        echo "Trees: 1=device 2=common 3=vendor 4=vendor-common 5=kernel 6=camera"
        read -r -p "Choose numbers separated by spaces, or all [all]: " tree_selection
        tree_selection=${tree_selection:-all}
    fi
    echo "Recovery: 1=none 2=TWRP 3=OrangeFox 4=both"
    read -r -p "Choose [1]: " choice
    case "${choice:-1}" in
        1) recovery=none ;;
        2) recovery=twrp ;;
        3) recovery=ofox ;;
        4) recovery=both ;;
        *) echo "Invalid recovery selection." >&2; exit 1 ;;
    esac
    if [[ "$recovery" != none ]]; then
        read -r -p "Recovery parent directory [../piano-recovery]: " recovery_dir
        recovery_dir=${recovery_dir:-../piano-recovery}
    fi
fi
case "$rom" in
    lineage) device_branch=${device_branch:-lineage-23.2} ;;
    evox)
        [[ -n "$device_branch" ]] || { echo "EvoX needs --device-branch pointing to a compatible EvoX tree; none is published yet." >&2; exit 1; } ;;
    none) ;;
    *) usage >&2; exit 1 ;;
esac
case "$recovery" in none|twrp|ofox|both) ;; *) usage >&2; exit 1 ;; esac

url=https://github.com/ALXP-DANIEL/android_device_xiaomi_piano.git
paths=(device/xiaomi/piano device/xiaomi/sm8750-common vendor/xiaomi/piano vendor/xiaomi/sm8750-common device/xiaomi/piano-kernel vendor/xiaomi/piano-miuicamera)
branches=("$device_branch" device-common-16 vendor-16 vendor-common-16 kernel-16 miuicamera-16)
selected=()
if [[ "$rom" != none ]]; then
    [[ -d .repo && -d build ]] || { echo "Run from the root of your ROM source checkout." >&2; exit 1; }
    if [[ "$tree_selection" == all ]]; then
        selected=(0 1 2 3 4 5)
    else
        for number in $tree_selection; do
            [[ "$number" =~ ^[1-6]$ ]] || { echo "Invalid tree number: $number" >&2; exit 1; }
            index=$((number - 1))
            for old in "${selected[@]}"; do
                [[ "$old" != "$index" ]] || { echo "Duplicate tree: $number" >&2; exit 1; }
            done
            selected+=("$index")
        done
    fi
    if [[ "$interactive" == yes && -t 0 ]]; then
        for index in "${selected[@]}"; do
            read -r -p "${paths[$index]} branch [${branches[$index]}]: " branch
            branches[$index]=${branch:-${branches[$index]}}
        done
    fi
    manifest=.repo/local_manifests/piano.xml
    [[ ! -e "$manifest" ]] || { echo "$manifest exists; preserve or edit it before configuring another setup." >&2; exit 1; }
    for index in "${selected[@]}"; do
        [[ "${branches[$index]}" =~ ^[a-zA-Z0-9._/-]+$ ]] || { echo "Invalid branch name." >&2; exit 1; }
        git ls-remote --exit-code --heads "$url" "refs/heads/${branches[$index]}" >/dev/null
    done
fi
recoveries=()
case "$recovery" in
    twrp|ofox) recoveries=("$recovery") ;;
    both) recoveries=(twrp ofox) ;;
esac
if [[ "$rom" == none && ${#recoveries[@]} -eq 0 ]]; then
    echo "No trees selected." >&2; exit 1
fi
if [[ ${#recoveries[@]} -gt 0 ]]; then
    recovery_dir=${recovery_dir:-../piano-recovery}
    recovery_dir=$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$recovery_dir")
    if [[ "$rom" != none ]]; then
        case "$recovery_dir/" in "$(pwd -P)/"*) echo "Keep recovery trees outside the ROM checkout." >&2; exit 1 ;; esac
    fi
    for item in "${recoveries[@]}"; do
        destination="$recovery_dir/$item"
        if [[ -e "$destination" ]]; then
            git -C "$destination" rev-parse --is-inside-work-tree >/dev/null
            [[ -z "$(git -C "$destination" status --porcelain)" ]] || { echo "$destination has local changes." >&2; exit 1; }
        fi
    done
fi

echo "ROM: $rom"
for index in "${selected[@]}"; do echo "  ${paths[$index]}: ${branches[$index]}"; done
for item in "${recoveries[@]}"; do echo "  $item recovery: $recovery_dir/$item"; done
if [[ "$interactive" == yes && -t 0 ]]; then
    read -r -p "Sync this setup? [Y/n]: " answer
    case "${answer:-y}" in y|Y|yes|YES) ;; *) exit 0 ;; esac
fi
if [[ "$rom" != none ]]; then
    mkdir -p .repo/local_manifests
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<manifest>'
        echo '  <remote name="piano" fetch="https://github.com/ALXP-DANIEL" />'
        for index in "${selected[@]}"; do
            printf '  <project name="android_device_xiaomi_piano" path="%s" remote="piano" revision="%s" />\n' "${paths[$index]}" "${branches[$index]}"
        done
        echo '</manifest>'
    } > "$manifest"
    sync_paths=()
    for index in "${selected[@]}"; do sync_paths+=("${paths[$index]}"); done
    repo sync "${sync_paths[@]}"
fi
for item in "${recoveries[@]}"; do
    destination="$recovery_dir/$item"
    if [[ -e "$destination" ]]; then
        git -C "$destination" fetch "$url" "$item-16"
        git -C "$destination" switch --detach FETCH_HEAD
    else
        mkdir -p "$recovery_dir"
        git clone --depth 1 --branch "$item-16" "$url" "$destination"
    fi
    echo "Recovery device tree: $destination"
done
