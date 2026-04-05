# Free Fast VPN — Flutter App

## Prerequisites

- Flutter SDK `>=3.11.0`
- The backend API running and accessible

## Setup

```bash
flutter pub get
```

## Running in Development

```bash
flutter run --dart-define=BASE_URL=http://your-server:8000/api
```

`BASE_URL` is the backend API address including the `/api` path. It is required and baked into the binary at compile time.

## Building for Release

### Android APK

**Requirements:** Android SDK, Java 17+

```bash
flutter build apk --release \
  --split-per-abi \
  --target-platform android-arm64 \
  --split-debug-info=build/debug-info \
  --obfuscate \
  --tree-shake-icons \
  --dart-define=BASE_URL=http://your-server:8000/api
```

Output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

To include all architectures, remove `--split-per-abi` and `--target-platform`.

### Windows

**Requirements:** Windows 10/11, Visual Studio 2022+ with "Desktop development with C++" workload, Developer Mode enabled.

#### Build the app

```bash
flutter build windows --release \
  --dart-define=BASE_URL=http://your-server:8000/api
```

Output: `build/windows/x64/runner/Release/`

The app runs as administrator (required for WireGuard VPN tunnels).

#### Create the installer

**Requirements:** [Inno Setup 6](https://jrsoftware.org/isdl.php)

```bash
# Install Inno Setup (if not installed)
winget install JRSoftware.InnoSetup

# Build the installer
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\windows_setup.iss
```

Output: `build/installer/FreeFastVPN_Setup.exe`

The installer provides:
- Desktop shortcut (optional)
- Start with Windows (optional)
- Start Menu entry
- Standard uninstaller

### iOS

**Requirements:** macOS, Xcode 15+, Apple Developer account. Must be run on macOS.

```bash
flutter build ipa --release \
  --dart-define=BASE_URL=http://your-server:8000/api
```

Output: `build/ios/ipa/app.ipa`

Code signing must be configured in Xcode before building.
