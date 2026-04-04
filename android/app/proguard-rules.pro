# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.**

# WireGuard
-keep class com.wireguard.** { *; }
-keep class com.beust.klaxon.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}

# Aggressive optimizations
-optimizationpasses 5
-allowaccessmodification
-repackageclasses ''
