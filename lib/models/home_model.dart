import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';

import '../models/server.dart';
import '../models/vpn_config.dart';
import '../services/api_client.dart';
import '../services/server_service.dart';

enum VpnConnectionState { disconnected, connecting, connected, disconnecting }

class HomeModel {
  final ServerService _api = ServerService();
  final WireGuardFlutterInterface _wireguard = WireGuardFlutter.instance;
  final String? deviceId;
  final String dns;

  List<Server> servers = [];
  Server? selectedServer;
  VpnConfig? currentConfig;
  String? clientPublicKey;
  int? activeConnectionId;
  VpnConnectionState connectionState = VpnConnectionState.disconnected;
  String? lastError;
  bool _cancelled = false;

  HomeModel({this.deviceId, this.dns = '1.1.1.3, 1.0.0.3'});

  static bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Call early to trigger the VPN permission dialog on Android.
  Future<void> ensureVpnPermission() async {
    if (!_isMobile) return;
    try {
      await _wireguard.initialize(interfaceName: 'wg0');
    } catch (_) {}
  }

  Future<List<Server>> fetchServers({String? langCode}) async {
    lastError = null;
    try {
      final allServers = await _api.getServers(lang: langCode);
      servers = allServers.where((s) => s.isActive).toList();
      return servers;
    } on ApiException catch (e) {
      lastError = e.message;
      rethrow;
    }
  }

  Future<void> connectToServer(int serverId) async {
    lastError = null;
    connectionState = VpnConnectionState.connecting;

    try {
      // 1. Register — get keys and IP (backend is reachable, VPN is off)
      final config = await _api.register(serverId);
      currentConfig = config;
      clientPublicKey = config.serverPublicKey;

      // 2. POST /connect/ BEFORE starting VPN — backend is still reachable
      //    This creates the history record and returns its ID
      try {
        final connectResult = await _api.connect(
          serverId,
          clientPublicKey!,
          config.clientIp,
          deviceId: deviceId,
        );
        activeConnectionId = connectResult.connectionId;
      } catch (_) {
        // If this fails, continue — VPN can still work, just no history
        activeConnectionId = null;
      }

      // 3. Initialize WireGuard (triggers VPN permission dialog if needed)
      await _wireguard.initialize(interfaceName: 'wg0');

      // 4. Build WireGuard config
      final wgConfig = '''
[Interface]
PrivateKey = ${config.privateKey}
Address = ${config.clientIp}/32
DNS = $dns

[Peer]
PublicKey = ${config.serverPublicKey}
Endpoint = ${config.endpoint}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
''';

      // 5. Start VPN with retries for permission timing
      await _startVpnWithRetry(config, wgConfig);

      // 6. Wait up to 15 seconds for the tunnel to establish
      _cancelled = false;
      bool isConnected = false;
      for (int i = 0; i < 15; i++) {
        if (_cancelled) break;
        await Future.delayed(const Duration(seconds: 1));
        final stage = await _wireguard.stage();
        if (stage == VpnStage.connected) {
          isConnected = true;
          break;
        }
      }

      if (isConnected) {
        connectionState = VpnConnectionState.connected;
      } else {
        await _wireguard.stopVpn();
        connectionState = VpnConnectionState.disconnected;
        lastError = 'VPN tunnel failed to establish within timeout';
        throw Exception(lastError);
      }
    } on ApiException catch (e) {
      connectionState = VpnConnectionState.disconnected;
      lastError = e.message;
      rethrow;
    } catch (e) {
      connectionState = VpnConnectionState.disconnected;
      lastError = 'Connection failed: $e';
      rethrow;
    }
  }

  /// Try to start VPN up to 3 times, waiting between retries for the
  /// user to accept the system VPN permission dialog.
  Future<void> _startVpnWithRetry(VpnConfig config, String wgConfig) async {
    const maxAttempts = 3;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await _wireguard.startVpn(
          serverAddress: config.endpoint.split(':').first,
          wgQuickConfig: wgConfig,
          // iOS: must match the Network Extension target's bundle ID
          providerBundleIdentifier: 'com.app.vpn.network-extension',
        );
        return;
      } catch (e) {
        final isPermissionError =
            e.toString().toLowerCase().contains('permission');
        if (isPermissionError && attempt < maxAttempts) {
          await Future.delayed(const Duration(seconds: 3));
          await _wireguard.initialize(interfaceName: 'wg0');
          continue;
        }
        rethrow;
      }
    }
  }

  Future<void> disconnectFromServer(int serverId) async {
    lastError = null;
    _cancelled = true; // Cancel any in-progress connect loop
    connectionState = VpnConnectionState.disconnecting;

    try {
      // 1. Stop VPN first
      await _wireguard.stopVpn();

      // 2. Now backend is reachable again — send disconnect with connection_id
      if (clientPublicKey != null) {
        try {
          await _api
              .disconnect(
                serverId,
                clientPublicKey!,
                deviceId: deviceId,
                connectionId: activeConnectionId,
              )
              .timeout(const Duration(seconds: 10));
        } catch (_) {
          // Ignore — disconnect is done locally
        }
      }

      connectionState = VpnConnectionState.disconnected;
      currentConfig = null;
      clientPublicKey = null;
      activeConnectionId = null;
    } catch (e) {
      connectionState = VpnConnectionState.disconnected;
      currentConfig = null;
      clientPublicKey = null;
      activeConnectionId = null;
      lastError = 'Disconnect failed: $e';
      rethrow;
    }
  }

  void selectServer(Server? server) {
    selectedServer = server;
  }

  void dispose() {
    _api.dispose();
  }
}
