#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

#=============================
# Set default values
#=============================
ANDROID_CMD="commandlinetools-linux-13114758_latest.zip"
ANDROID_SDK_PACKAGES="platform-tools extras;google;auto"
ANDROID_SDK_ROOT="$SCRIPT_DIR/opt/android"

INSTALL=0
HEADLESS=0

export ANDROID_SDK_ROOT
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/tools:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/extras/google/auto/"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -i        Install Android SDK, dependencies
  -h        Show this help message

Examples:
  $(basename "$0") -i        Install SDK
  $(basename "$0")           Run Desktop Head Unit normally (installs if missing)
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

    chmod +x $ANDROID_SDK_ROOT/extras/google/auto/desktop-head-unit

    echo -e "\n Android auto setup complete!"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i) INSTALL=1 ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
    shift
done

if [[ "$INSTALL" -eq 1 ]]; then
    install_android_sdk
elif ! command -v desktop-head-unit &>/dev/null; then
    echo "Android Desktop Head Unit found. Running install..."
    install_android_sdk
fi

desktop-head-unit --usb
