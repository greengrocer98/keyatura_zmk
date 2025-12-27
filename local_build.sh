#!/usr/bin/env bash

set -euxo pipefail

# Requirements:
# 1. https://zmk.dev/docs/development/setup
# 2. checkout zmk repo to feat/pointers-move-scroll on petejohansson's repo


build_mouse () {
    local side=mouse
    rm -rf $CURRENT_DIR/build/$side
    export NRF_MODULE_DIRS="$HOME/zmk-esb/zmk-feature-split-esb/nrf"
    export NRFXLIB_MODULE_DIRS="$HOME/zmk-esb/zmk-feature-split-esb/nrfxlib"
    export ZMK_ESB_MODULE_DIRS="$HOME/zmk-esb/zmk-feature-split-esb"
    export ZMK_RGBLED_WIDGET="$HOME/zmk_modules/zmk-rgbled-widget"
    export ZMK_PMW_3610_DRIVER="$HOME/zmk_modules/efogdev-zmk-pmw3610-driver"
    export ZMK_MODULE_DIRS="${ZMK_ESB_MODULE_DIRS};${NRF_MODULE_DIRS};${NRFXLIB_MODULE_DIRS};${ZMK_PMW_3610_DRIVER};${ZMK_RGBLED_WIDGET}"
    west build \
        -p -b nice_nano \
        -d "$CURRENT_DIR/build/$side" -- \
        -DZMK_CONFIG="$CURRENT_DIR" \
        -DSHIELD=keyatura_$side \
        -DZMK_EXTRA_MODULES="${ZMK_MODULE_DIRS}"

    cp "$CURRENT_DIR/build/$side/zephyr/zmk.uf2" "$CURRENT_DIR/build/$side/keyatura_${side}_esb.uf2"
    cp "$CURRENT_DIR/build/$side/zephyr/zmk.uf2" "$CURRENT_DIR/build/uf_files/keyatura_${side}_esb.uf2"
}

build () {
    local shield=keyatura
    rm -rf $CURRENT_DIR/build/$shield
    # export ZMK_RGBLED_WIDGET="$HOME/zmk_modules/zmk-rgbled-widget"
    export ZMK_RGBLED_WIDGET="$HOME/zmk-vfx-indicator"
    export ZMK_MODULE_DIRS="${ZMK_RGBLED_WIDGET}"
    west build \
        -p -b nice_nano \
        -S studio-rpc-usb-uart \
        -d "$CURRENT_DIR/build/$shield" -- \
        -DZMK_CONFIG="$CURRENT_DIR" \
        -DSHIELD=$shield \
        -DZMK_EXTRA_MODULES="${ZMK_MODULE_DIRS}" \
        -DCONFIG_ZMK_STUDIO=y

    cp "$CURRENT_DIR/build/$shield/zephyr/zmk.uf2" "$CURRENT_DIR/build/$shield/$shield.uf2"
    cp "$CURRENT_DIR/build/$shield/zephyr/zmk.uf2" "$CURRENT_DIR/build/uf_files/$shield.uf2"
}

build_reset () {
    rm -rf $CURRENT_DIR/build/reset
    west build \
        -p -b nice_nano \
        -S studio-rpc-usb-uart \
        -d "$CURRENT_DIR/build/reset" -- \
        -DZMK_CONFIG="$CURRENT_DIR" \
        -DSHIELD=settings_reset

    cp "$CURRENT_DIR/build/reset/zephyr/zmk.uf2" "$CURRENT_DIR/build/reset/reset.uf2"
}

CURRENT_DIR="$(pwd)"

DEFAULTZMKAPPDIR="$HOME/zmk/"
ZMK_APP_DIR="$DEFAULTZMKAPPDIR/app"

cd $DEFAULTZMKAPPDIR && source .venv/bin/activate && cd -

mkdir -p $CURRENT_DIR/build
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR="$HOME/zephyr-sdk-0.17.0"

pushd $ZMK_APP_DIR

build

deactivate

popd
