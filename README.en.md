# Shi

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

Shi is a macOS keyboard and screen cleaning assistant. Cleaning mode temporarily blocks keyboard input and pointer clicks, dims the displays, and provides an explicit exit shortcut to prevent accidental actions while cleaning.

## Features

- Six interface languages: Simplified Chinese, Traditional Chinese, English, Japanese, Korean, and Spanish
- Uses the first macOS preferred language on initial launch; a language selected in Settings is remembered
- Three cleaning appearances: Wipe, White, and Night Clock
- Hold both Shift keys, or hold Shift + Esc, to safely leave cleaning mode
- Configurable exit hold duration, maximum cleaning time, and pointer-click blocking
- Signed update checks and installation with Sparkle 2
- Universal 2 build for Apple Silicon and Intel Macs

## Requirements

- macOS 14 or later
- Cleaning mode requires access under System Settings › Privacy & Security › Accessibility

Accessibility access is used only to block input during cleaning mode. Shi does not record keystrokes or upload usage data. It makes no network requests except HTTPS software-update checks.

## Download

[⬇️ Download the latest release from GitHub](https://github.com/JTXYH/shi/releases/latest)

Extract the ZIP and move `Shi.app` to Applications.

### If macOS blocks the first launch

The current package is ad-hoc signed and has not been notarized by Apple. If macOS says it cannot check the app for malicious software or cannot verify the developer, first confirm that the app came from this repository's [GitHub Releases](https://github.com/JTXYH/shi/releases), then use either method:

1. Open Applications in Finder, Control-click or right-click `Shi.app`, choose Open, and confirm Open again.
2. Or try to launch it once, then go to System Settings › Privacy & Security and choose Open Anyway in the Security section.

Do not disable Gatekeeper or run untrusted Terminal commands to bypass protection. If macOS explicitly reports malware, delete the file and download it again from the official Release.

After the first approval, Sparkle verifies and installs later updates using Ed25519 signatures. Because ad-hoc signatures have no stable Team ID, macOS may ask you to enable Accessibility again after an update.

## Build from source

Xcode 16 or later is required. The project pins Sparkle 2.9.2; Xcode resolves the Swift Package dependency during the first build.

```sh
./scripts/build-app.sh debug
```

The result is written to `dist/Shi.app`. Builds use ad-hoc signing by default and re-sign the host app and every embedded Sparkle executable.

## Release

The current distribution model matches Codex Meter: ad-hoc code signing plus Sparkle Ed25519 signatures for the update archive and appcast. The release script builds a Universal 2 app, verifies nested signatures, and generates a ZIP, SHA-256 checksum, and appcast.

```sh
./scripts/package-release.sh
```

Create a GitHub Release named `vX.Y.Z` and upload the generated ZIP, SHA-256 file, and `appcast.xml`. If a Developer ID becomes available later, the same script can enable Developer ID signing and Apple notarization through environment variables.

See [docs/releasing.md](docs/releasing.md) for the complete release procedure.

## Security design

- Current public builds are ad-hoc signed and not Apple-notarized, so Gatekeeper displays a warning on first launch. Ad-hoc builds omit Library Validation so the Sparkle framework can load without a Team ID.
- The Sparkle feed uses HTTPS and requires a signed appcast and Ed25519 archive signatures.
- Packaging verifies the signatures of the update framework and every embedded executable.
- App Sandbox is disabled because global input interception requires Accessibility access outside the sandbox. The app explains this access before it is requested.
- Diagnostics use macOS Unified Logging and never write to a predictable `/tmp` file.
- Display brightness prefers public system interfaces. Some Macs fall back to Apple's private DisplayServices interface and therefore require regression testing on target macOS versions.

See [SECURITY.md](SECURITY.md) to report a security issue.

## License

[MIT](LICENSE)
