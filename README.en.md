# Shi

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

Shi is a free, open-source keyboard and screen cleaning assistant for macOS. Cleaning mode temporarily blocks keyboard input, blocks trackpad and mouse clicks by default, and dims your displays to reduce accidental actions while wiping. Hold an exit shortcut when you are done to resume using your Mac.

[Download the latest release](https://github.com/JTXYH/shi/releases/latest) · [Report an issue](https://github.com/JTXYH/shi/issues) · [MIT license](LICENSE)

## Features

- **Pause input while cleaning**: block keyboard input, with optional blocking of trackpad and mouse clicks.
- **Three cleaning appearances**: Wipe, White, and Night Clock, with cleaning overlays across multiple displays.
- **Display dimming and restoration**: dim displays during cleaning and restore them on exit; results depend on display and macOS support.
- **Quick start and exit**: while Shi is running, press `Control + Option + Command + C` to start; hold both `Shift` keys or `Shift + Esc` to exit.
- **Adjustable session timing**: choose the exit hold duration and an automatic timeout to end a cleaning session.
- **Six interface languages**: Simplified Chinese, Traditional Chinese, English, Japanese, Korean, and Spanish.
- **In-app updates**: check for updates and verify update signatures with Sparkle.

## Screenshots

<p align="center">
  <img src="docs/images/screenshots/main-window.png" alt="Shi main window" width="560">
</p>

<p align="center">
  <img src="docs/images/screenshots/cleaning-wipe.png" alt="Wipe cleaning appearance" width="31%">
  <img src="docs/images/screenshots/cleaning-white.png" alt="White cleaning appearance" width="31%">
  <img src="docs/images/screenshots/cleaning-night-clock.png" alt="Night Clock cleaning appearance" width="31%">
</p>

<p align="center"><sub>Wipe · White · Night Clock</sub></p>

## Requirements

- macOS 14 Sonoma or later.
- An Apple Silicon or Intel Mac; the build produces a Universal 2 app.
- macOS Accessibility permission for cleaning mode.

## Installation

1. Download the application ZIP from [GitHub Releases](https://github.com/JTXYH/shi/releases/latest).
2. Extract it and move `Shi.app` to the Applications folder.
3. Open the app and follow the usage steps below.

The default distribution currently uses ad-hoc signing and is not notarized by Apple. If the first launch reports an unidentified developer or says Apple cannot check for malicious software, confirm that the file came from this repository and has not been altered, then follow [Apple's instructions for opening the app](https://support.apple.com/en-us/102445). Do not override an explicit malware detection.

## Usage

1. Open Shi, choose a cleaning appearance, and click **Start Cleaning**. You can also press `Control + Option + Command + C` while the app is running.
2. On first use, follow the prompt to **System Settings › Privacy & Security › Accessibility** and enable Shi. If it is missing, add `Shi.app` with the `+` button. **Cleaning starts automatically once permission is granted.**
3. When you are done, hold both the left and right `Shift` keys, or hold `Shift + Esc`. The default hold time is **1.5 seconds**, after which input and display brightness are restored.

The following options are available in Settings:

| Setting | Default | Options |
| --- | --- | --- |
| Exit hold duration | 1.5 seconds | 1, 1.5, or 2 seconds |
| Maximum cleaning time | 10 minutes | 5 minutes, 10 minutes, or no automatic timeout |
| Block trackpad and mouse clicks | On | On or off |

On first launch, Shi uses the first preferred macOS language, falling back to English if it is unsupported. A manually selected language is saved locally.

The power button and Touch ID cannot be blocked. Use the macOS lock screen when you step away.

## Permissions, privacy, and updates

- Accessibility permission enables keyboard interception during cleaning mode. Shi does not record keystrokes or collect usage analytics; preferences are stored locally.
- Cleaning works offline and requires no account. Update checks and update downloads require a network connection.
- Release builds fetch update information over HTTPS and verify the appcast and update archive with Sparkle's Ed25519 signatures. You can check for updates in Settings; debug builds disable update checks.
- After an ad-hoc signed app is updated or rebuilt, macOS may require Accessibility permission again. If cleaning will not start, re-enable Shi in the Accessibility list.

Report vulnerabilities privately by following the [security policy](SECURITY.md).

## Build from source

Development requires macOS and Xcode 16 or later, with the command-line tools set to that Xcode installation. The project uses Swift, SwiftUI, and AppKit, with [Sparkle](https://github.com/sparkle-project/Sparkle) supplied through Swift Package Manager and currently pinned to 2.9.2. The first build needs a network connection to fetch dependencies.

```sh
git clone https://github.com/JTXYH/shi.git
cd shi
./scripts/build-app.sh debug
open dist/Shi.app
```

The script produces `dist/Shi.app` containing both `arm64` and `x86_64` architectures. It uses ad-hoc signing by default, so a local build does not require a Developer ID certificate. You can also open `Shi.xcodeproj` in Xcode and select the `Shi` scheme for development and debugging.

Run the existing language-selection checks from the repository root:

```sh
./scripts/test-language-selection.sh
```

These checks cover system-language resolution and saved-language precedence. Cleaning, permissions, and display behavior still need testing on a real Mac.

## Contributing

Bug reports, improvements, and translations are welcome through [Issues](https://github.com/JTXYH/shi/issues) and [Pull Requests](https://github.com/JTXYH/shi/pulls).

- For bug reports, include the app version, macOS version, Mac model, reproduction steps, and expected result. Include your display setup for visual issues.
- Explain the reason for your change and how you verified it. Include screenshots for interface changes; test input blocking, exit behavior, and brightness changes on a real Mac.
- Keep all six READMEs in sync when updating feature descriptions or translations. In-app text lives in [Shi/Localization.swift](Shi/Localization.swift).

## License

Maintained by [JTXYH](https://github.com/JTXYH) and released under the [MIT license](LICENSE). Third-party dependencies retain their respective licenses.
