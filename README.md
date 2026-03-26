# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Flutter Native Splash

```bash
flutter pub add flutter_native_splash
```

```yml
flutter_native_splash:
  # Set the background color of the splash screen
  color: "#FFFFFF" # You can use any hex color here
  
  # Path to your logo
  image: assets/splash_logo.png
  
  # Ensure the splash screen is applied to both platforms
  android: true
  ios: true
  
  # Android 12+ requires a specific configuration for the background
  android_12:
    color: "#FFFFFF"
    image: assets/splash_logo.png
```

```bash
dart run flutter_native_splash:create
```


## To build optimized android apk
```bash
flutter build apk --release --split-per-abi --target-platform android-arm64   --split-debug-info=build/debug-info --obfuscate --tree-shake-icons
```