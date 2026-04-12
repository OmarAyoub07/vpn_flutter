# Free Fast VPN — Flutter App

Cross-platform VPN client built with Flutter. Supports Android, Windows, and iOS.

## Prerequisites

- Flutter SDK `>=3.11.0`
- Backend API running and accessible

## Setup

```bash
flutter pub get
```

## Configuration

`BASE_URL` is the backend API address including the `/api` path. It is **required** and baked into the binary at compile time via `--dart-define`.

```
--dart-define=BASE_URL=http://your-server:8000/api
```

## Running in Development

```bash
flutter run --dart-define=BASE_URL=http://your-server:8000/api
```

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

Output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (~24 MB)

To include all architectures (arm, arm64, x64), remove `--split-per-abi` and `--target-platform`.

### Windows

**Requirements:**
- Windows 10/11
- Visual Studio 2022+ with **"Desktop development with C++"** workload (MSVC, CMake, Windows SDK)
- Developer Mode enabled (`Settings > Developer settings`)

#### 1. Build the app

```bash
flutter build windows --release \
  --dart-define=BASE_URL=http://your-server:8000/api
```

Output: `build/windows/x64/runner/Release/`

The executable is named `FreeFastVPN.exe` and requires administrator privileges (UAC prompt) for WireGuard VPN tunnel management.

#### 2. Create the installer

**Requirements:** [Inno Setup 6](https://jrsoftware.org/isdl.php)

```bash
# Install Inno Setup (one-time)
winget install JRSoftware.InnoSetup

# Build the installer
iscc windows/installer.iss
```

Output: `build/windows/installer/FreeFastVPN-Setup.exe`

The installer provides:
- One-click install with UAC elevation
- Desktop shortcut (optional)
- Start Menu entry
- Standard Add/Remove Programs uninstaller

#### Windows app features

- Frameless window with custom title bar (minimize, hide to tray, close)
- System tray icon with live VPN status, connect/disconnect, and right-click menu
- Portrait fixed-size window (420x780)
- Patched WireGuard service management (fresh tunnel config on each connection)

### iOS

**Requirements:** macOS, Xcode 15+, Apple Developer account, Go 1.22+ (for WireGuardKit). Must be built on macOS.

```bash
flutter build ipa --release \
  --export-options-plist=ios/ExportOptions.plist \
  --dart-define=BASE_URL=http://your-server:8000/api
```

Output: `build/ios/ipa/app.ipa`

#### iOS setup checklist

Before building for iOS:
1. Register two App IDs in Apple Developer portal:
   - `vpn.free.com` (main app) — enable Network Extensions + Personal VPN
   - `vpn.free.com.network-extension` (tunnel extension) — enable Network Extensions
2. Create provisioning profiles for both identifiers
3. Open `ios/Runner.xcworkspace` in Xcode and verify signing settings
4. Replace the test **GADApplicationIdentifier** in `ios/Runner/Info.plist` with your production AdMob App ID
5. Build with `flutter build ipa --release --export-options-plist=ios/ExportOptions.plist --dart-define=BASE_URL=...`

## Project Structure

```
lib/
  core/             App localizations, environment config
  controllers/      HomeController (VPN state, timers, rewards)
  models/           Data models (Server, VpnConfig, AppConfig, etc.)
  services/         API client, ad service, device service, etc.
  theme/            Light/dark themes, color constants
  views/
    screens/        Home, splash, consent, history, language, feedback, legal
    widgets/        Flag emoji, side menu, title bar, glass cards, pulse orb
plugins/
  wireguard_flutter/  Local patched copy of wireguard_flutter (Windows service fix)
ios/
  VPNExtension/     Packet Tunnel Provider for WireGuard VPN on iOS
windows/
  runner/           Native Windows code (frameless window, system tray, method channel)
  installer.iss     Inno Setup installer script
```

## Backend API

The app expects these backend endpoints:

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/config/` | GET | App config, ad unit IDs, store URLs, DNS |
| `/api/servers/` | GET | Server list with `flag_image_url` |
| `/api/servers/{id}/register/` | POST | Get WireGuard keys and client IP |
| `/api/servers/{id}/connect/` | POST | Log VPN connection start |
| `/api/servers/{id}/disconnect/` | POST | Log VPN disconnection |
| `/api/users/register-device/` | POST | Register device, apply referral code |
| `/api/users/{device_id}/history/` | GET | Connection history |
| `/api/users/{device_id}/reward/` | POST | Claim ad reward tier |
| `/api/users/{device_id}/sync-time/` | POST | Sync remaining VPN time |
| `/api/localization/languages/` | GET | Available languages with `flag_image_url` |
| `/api/localization/labels/{code}/` | GET | UI strings for a language |
| `/api/feedback/` | POST | Submit feedback |

Ad unit IDs in `/api/config/` are platform-specific: `android_rewarded_ad_unit_id`, `ios_rewarded_ad_unit_id`, etc.

## CI/CD

Three GitHub Actions workflows build and deploy automatically on push to release branches:

| Workflow | Branch | Output |
|----------|--------|--------|
| `android-build.yml` | `android/release` | APK artifacts |
| `ios-build.yml` | `ios/release` | IPA → App Store Connect |
| `windows-build.yml` | `windows/release` | Installer + portable build |

All Flutter development happens on `master`. To deploy, merge master into the target release branch.

## Notes

- Flag images are loaded from the backend (`flag_image_url`) with local caching via `cached_network_image`
- Ads use Google AdMob (Android/iOS only) — Windows skips ads gracefully
- The WireGuard plugin is a local patched copy under `plugins/` to fix Windows service management
- iOS VPN uses a Network Extension (Packet Tunnel Provider) with WireGuardKit
- The app uses `--dart-define-from-file` in CI for the API URL — there is no `.env` file at runtime
