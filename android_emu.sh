#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

#=============================
# Set default values
#=============================
ARCH="x86_64"
TARGET="default"
API_LEVEL="35"
BUILD_TOOLS="36.1.0"
ANDROID_API_LEVEL="android-${API_LEVEL}"
ANDROID_APIS="${TARGET};${ARCH}"
EMULATOR_PACKAGE="system-images;${ANDROID_API_LEVEL};${ANDROID_APIS}"
EMULATOR_NAME="Portable_Pixel_6_Pro"
DEVICE_NAME="pixel_6_pro"
PLATFORM_VERSION="platforms;${ANDROID_API_LEVEL}"
BUILD_TOOL="build-tools;${BUILD_TOOLS}"
ANDROID_CMD="commandlinetools-linux-13114758_latest.zip"
ANDROID_SDK_PACKAGES="${EMULATOR_PACKAGE} ${PLATFORM_VERSION} ${BUILD_TOOL} platform-tools emulator"
ANDROID_SDK_ROOT="$SCRIPT_DIR/opt/android"
AVD_HOME="$SCRIPT_DIR/.android/avd"

INSTALL=0
HEADLESS=0

export ANDROID_SDK_ROOT
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/tools:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/build-tools/${BUILD_TOOLS}"
export ANDROID_AVD_HOME="$AVD_HOME"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -i        Install Android SDK, dependencies, and create AVD if missing
  -n        Run emulator in headless mode (no window, no GPU, no audio)
  -h        Show this help message

Examples:
  $(basename "$0") -i        Install SDK + create AVD, then run emulator
  $(basename "$0") -n        Run emulator headless
  $(basename "$0") -i -n     Install SDK + create AVD, then run emulator headless
  $(basename "$0")           Run emulator normally (installs if missing)
EOF
}

install_android_sdk() {
    # Install system dependencies
    sudo apt update
    sudo apt install -y curl sudo wget unzip bzip2 libdrm-dev libxkbcommon-dev \
        libgbm-dev libasound-dev libnss3 libxcursor1 libpulse-dev libxshmfence-dev \
        xauth xvfb x11vnc fluxbox wmctrl libdbus-glib-1-2

    # Download and install Android SDK
    sudo mkdir -p "$ANDROID_SDK_ROOT"
    sudo chown -R $(whoami):$(whoami) "$ANDROID_SDK_ROOT"

    if [ ! -d "$ANDROID_SDK_ROOT/cmdline-tools" ]; then
        if [ ! -f "$ANDROID_CMD" ]; then
            wget -O $ANDROID_CMD https://dl.google.com/android/repository/$ANDROID_CMD
        fi
        unzip -d "$ANDROID_SDK_ROOT" $ANDROID_CMD
        mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools/tools"
        mv "$ANDROID_SDK_ROOT/cmdline-tools/"{bin,lib,NOTICE.txt,source.properties} \
            "$ANDROID_SDK_ROOT/cmdline-tools/tools/" || true
    fi

    # Accept licenses and install packages
    yes | sdkmanager --licenses
    yes | sdkmanager --verbose --no_https ${ANDROID_SDK_PACKAGES}

    mkdir -p $AVD_HOME
    echo "no" | avdmanager --verbose create avd --force --name "$EMULATOR_NAME" --device "$DEVICE_NAME" --package "$EMULATOR_PACKAGE"

    echo -e "\n Android emulator setup complete!"
}

run_emulator() {
    EMULATOR_ARGS=""
    if [[ "$HEADLESS" == "1" ]]; then
        EMULATOR_ARGS="-no-window -gpu off -no-audio"
    fi

    if ! command -v emulator &>/dev/null; then
        echo "Emulator not found. Running install..."
        install_android_sdk
    fi

    emulator -avd "${EMULATOR_NAME}" ${EMULATOR_ARGS}
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i) INSTALL=1 ;;
        -n) HEADLESS=1 ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
    shift
done

if [[ "$INSTALL" -eq 1 ]]; then
    install_android_sdk
fi

run_emulator
