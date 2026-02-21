# Android Emulator Portable

This repository provides scripts to install and run the Android Emulator and Android Auto Desktop Head Unit (DHU) without needing a full Android Studio installation. Everything is kept local to the project directory, so it won't interfere with any global Android SDKs you might already have.

## How it works

The scripts automate the setup process by downloading the minimum required SDK components directly into the `opt/android/` folder. They also configure the AVD (Android Virtual Device) to live entirely within this project directory.

Here is a breakdown of what the scripts do:

1. **Install dependencies:** Runs `apt` to install system packages required by the Android Emulator locally (like `libxkbcommon`, `xvfb`, etc).
2. **Download Command Line Tools:** Fetches the Android command-line tools zip from Google and extracts it into `opt/android/`.
3. **Install SDK packages:** Uses `sdkmanager` to install necessary packages depending on the script:
   - Emulator (`android_emu.sh`): installs `system-images`, `platforms`, `build-tools`, and `emulator`.
   - DHU (`android_dhu.sh`): installs `platform-tools` and `extras;google;auto`.
4. **Create the device:** Uses `avdmanager` to set up a new AVD. The default configuration is a Pixel 6 Pro running API 35. The AVD files are placed in `.android/avd/`.
5. **Run:** Launches either the emulator or DHU. The emulator can be started normally or in headless mode.

## Directory structure

After running the setup, your directory will look like this:

```text
android_emu_portable/
├── android_emu.sh       # script for Android Emulator
├── android_dhu.sh       # script for Android Auto DHU
├── README.md
├── commandlinetools-linux-..._latest.zip
├── opt/                 
│   └── android/         # Local SDK root
│       ├── cmdline-tools/
│       ├── emulator/
│       ├── platform-tools/
│       ├── build-tools/
│       └── system-images/
└── .android/
    └── avd/             # Local AVD storage
```

## Configuration

You can override the default emulator configuration by creating a `.env` file in the project root. You can copy the provided `.env_example` as a starting point.

**Supported options:**
- `ARCH` (default: `x86_64`)
- `TARGET` (default: `default`)
- `API_LEVEL` (default: `35`)
- `EMULATOR_NAME` (default: `Portable_Pixel_6_Pro`)
- `DEVICE_NAME` (default: `pixel_6_pro`)

## Scripts

### `android_emu.sh`

Starts the Android emulator. 

By default, the script creates a `pixel_6_pro` device targeting API 35 named `Portable_Pixel_6_Pro`. You can override these defaults using a `.env` file (see Configuration above).

**Options:**
- `-i`: Installs the Android SDK, downloads system images, creates the AVD, and installs dependencies.
- `-n`: Runs the emulator in headless mode (`-no-window -gpu off -no-audio`).
- `-h`: Show help.

If you just run `./android_emu.sh` without flags, it will simply start the emulator. If the emulator is not found, it runs the install step automatically.

### `android_dhu.sh`

Starts the Android Auto Desktop Head Unit (DHU). See the [official documentation](https://developer.android.com/training/cars/testing/dhu) for more details. 

**Options:**
- `-i`: Installs the required SDK components (`extras;google;auto`) and dependencies.
- `-h`: Show help.

Running `./android_dhu.sh` without flags will run `desktop-head-unit --usb`. If it is not found, the script will install it automatically.

## Environment isolation

To keep things portable, the scripts temporarily set these environment variables when they run:

- `ANDROID_SDK_ROOT="$SCRIPT_DIR/opt/android"`
- `ANDROID_AVD_HOME="$SCRIPT_DIR/.android/avd"`

This guarantees that the scripts will not read from or write to your global `~/.android` or `~/Android/Sdk` folders.
