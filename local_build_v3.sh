#!/usr/bin/env bash

set -euxo pipefail

# Requirements:
# 1. https://zmk.dev/docs/development/setup
# 2. checkout zmk repo to feat/pointers-move-scroll on petejohansson's repo


build_mouse () {
    local shield=mouse
    rm -rf $CURRENT_DIR/build/$shield
    export NRF_MODULE_DIRS="$HOME/zmk-esb-v3/zmk-feature-split-esb/nrf"
    export NRFXLIB_MODULE_DIRS="$HOME/zmk-esb-v3/zmk-feature-split-esb/nrfxlib"
    export ZMK_ESB_MODULE_DIRS="$HOME/zmk-esb-v3/zmk-feature-split-esb"
    export ZMK_BEHAVIOR_ATTR_CYCLE="$HOME/zmk_modules/zmk-behavior-sensor-attr-cycle"
    export ZMK_PAW_3395_DRIVER="$HOME/zmk_modules/ggrocer-zmk-paw3395-driver"
    # export ZMK_PAW_3395_DRIVER="$HOME/zmk_modules/zmk-paw3395-driver"
    export ZMK_RGBLED_WIDGET="$HOME/zmk_modules/zmk-vfx-rgbled-indicator"
    export ZMK_MODULE_DIRS="${ZMK_ESB_MODULE_DIRS};${NRF_MODULE_DIRS};${NRFXLIB_MODULE_DIRS};${ZMK_BEHAVIOR_ATTR_CYCLE};${ZMK_PAW_3395_DRIVER};${ZMK_RGBLED_WIDGET}"
    # export ZMK_MODULE_DIRS="${ZMK_ESB_MODULE_DIRS};${NRF_MODULE_DIRS};${NRFXLIB_MODULE_DIRS};${ZMK_PAW_3395_DRIVER};${ZMK_RGBLED_WIDGET}"
    west build \
        -p -b nice_nano_v2 \
        -S studio-rpc-usb-uart \
        -S zmk-usb-logging \
        -d "$CURRENT_DIR/build/$shield" -- \
        -DZMK_CONFIG="$CURRENT_DIR" \
        -DSHIELD=keyatura_$shield \
        -DZMK_EXTRA_MODULES="${ZMK_MODULE_DIRS}"

    cp "$CURRENT_DIR/build/$shield/zephyr/zmk.uf2" "$CURRENT_DIR/build/$shield/$shield.uf2"
    cp "$CURRENT_DIR/build/$shield/zephyr/zmk.uf2" "$CURRENT_DIR/build/uf_files/$shield.uf2"
}

build_dongle () {
    local shield=dongle
    rm -rf $CURRENT_DIR/build/$shield
    export NRF_MODULE_DIRS="$HOME/zmk-esb-v3/zmk-feature-split-esb/nrf"
    export NRFXLIB_MODULE_DIRS="$HOME/zmk-esb-v3/zmk-feature-split-esb/nrfxlib"
    export ZMK_ESB_MODULE_DIRS="$HOME/zmk-esb-v3/zmk-feature-split-esb"
    export ZMK_BEHAVIOR_ATTR_CYCLE="$HOME/zmk_modules/zmk-behavior-sensor-attr-cycle"
    export ZMK_RGBLED_WIDGET="$HOME/zmk_modules/zmk-vfx-rgbled-indicator"
    export ZMK_MODULE_DIRS="${ZMK_ESB_MODULE_DIRS};${NRF_MODULE_DIRS};${NRFXLIB_MODULE_DIRS};${ZMK_BEHAVIOR_ATTR_CYCLE};${ZMK_RGBLED_WIDGET}"
    west build \
        -p -b nice_nano_v2 \
        -S studio-rpc-usb-uart \
        -S zmk-usb-logging \
        -d "$CURRENT_DIR/build/$shield" -- \
        -DZMK_CONFIG="$CURRENT_DIR" \
        -DSHIELD=keyatura_$shield \
        -DZMK_EXTRA_MODULES="${ZMK_MODULE_DIRS}" \
        -DCONFIG_ZMK_STUDIO=y

    cp "$CURRENT_DIR/build/$shield/zephyr/zmk.uf2" "$CURRENT_DIR/build/$shield/$shield.uf2"
    cp "$CURRENT_DIR/build/$shield/zephyr/zmk.uf2" "$CURRENT_DIR/build/uf_files/$shield.uf2"
}

CURRENT_DIR="$(pwd)"

DEFAULTZMKAPPDIR="$HOME/zmk-esb-v3/zmk/"
ZMK_APP_DIR="$DEFAULTZMKAPPDIR/app"

cd $DEFAULTZMKAPPDIR && source .venv/bin/activate && cd -

mkdir -p $CURRENT_DIR/build
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR="$HOME/zephyr-sdk-0.17.0"

pushd $ZMK_APP_DIR

# build_dongle
build_mouse

deactivate

popd
