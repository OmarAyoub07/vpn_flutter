import 'dart:io' show Platform;
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const _key = 'device_id';

  /// Returns a stable device identifier that survives app reinstalls.
  ///
  /// - Android: uses Settings.Secure.ANDROID_ID (persists across reinstalls
  ///   for the same signing key + device).
  /// - iOS: uses identifierForVendor (persists across reinstalls for same
  ///   vendor/team).
  /// - Other platforms: falls back to a UUID stored in SharedPreferences.
  static Future<String> getDeviceId() async {
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          // Settings.Secure.ANDROID_ID — stable across reinstalls
          final androidId = await const AndroidId().getId();
          if (androidId != null && androidId.isNotEmpty) {
            return _toUuid(androidId);
          }
        }

        if (Platform.isIOS) {
          final ios = await DeviceInfoPlugin().iosInfo;
          final vendorId = ios.identifierForVendor;
          if (vendorId != null && vendorId.isNotEmpty) {
            return vendorId;
          }
        }
      } catch (_) {
        // Fall through to SharedPreferences fallback
      }
    }

    // Fallback for desktop/web: UUID stored in prefs
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_key, id);
    }
    return id;
  }

  /// Generates a deterministic UUID v5 from a seed string.
  static String _toUuid(String seed) {
    return const Uuid().v5(Namespace.url.value, seed);
  }
}
