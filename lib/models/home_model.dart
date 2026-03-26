import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:wireguard_flutter/wireguard_flutter_platform_interface.dart';

import '../models/server.dart';
import '../models/vpn_config.dart';
import '../services/api_service.dart';

enum VpnConnectionState { disconnected, connecting, connected, disconnecting }

class HomeModel {
  final ApiService _api = ApiService();
  final WireGuardFlutterInterface _wireguard = WireGuardFlutter.instance;

  List<Server> servers = [];
  Server? selectedServer;
  VpnConfig? currentConfig;
  String? clientPublicKey;
  VpnConnectionState connectionState = VpnConnectionState.disconnected;
  String? lastError;

  Future<List<Server>> fetchServers() async {
    lastError = null;
    try {
      final allServers = await _api.getServers();
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
      final config = await _api.register(serverId);
      currentConfig = config;

      await _wireguard.initialize(interfaceName: 'wg0');

      final wgConfig = '''
[Interface]
PrivateKey = ${config.privateKey}
Address = ${config.clientIp}/32
DNS = 1.1.1.3, 1.0.0.3

[Peer]
PublicKey = ${config.serverPublicKey}
Endpoint = ${config.endpoint}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
''';

      await _wireguard.startVpn(
        serverAddress: config.endpoint.split(':').first,
        wgQuickConfig: wgConfig,
        providerBundleIdentifier: 'com.app.vpn',
      );

      // Wait up to 10 seconds for the tunnel to establish
      bool isConnected = false;
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 1));
        final stage = await _wireguard.stage();
        if (stage == VpnStage.connected) {
          isConnected = true;
          break;
        }
      }

      if (isConnected) {
        clientPublicKey = config.serverPublicKey;
        await _api.connect(serverId, clientPublicKey!, config.clientIp);
        connectionState = VpnConnectionState.connected;
      } else {
        await _wireguard.stopVpn(); // Ensure cleanup
        connectionState = VpnConnectionState.disconnected;
        lastError = 'WireGuard tunnel failed to establish within timeout';
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

  Future<void> disconnectFromServer(int serverId) async {
    lastError = null;
    connectionState = VpnConnectionState.disconnecting;

    try {
      await _wireguard.stopVpn();

      if (clientPublicKey != null) {
        await _api.disconnect(serverId, clientPublicKey!);
      }

      connectionState = VpnConnectionState.disconnected;
      currentConfig = null;
      clientPublicKey = null;
    } on ApiException catch (e) {
      connectionState = VpnConnectionState.disconnected;
      currentConfig = null;
      clientPublicKey = null;
      lastError = e.message;
      rethrow;
    } catch (e) {
      connectionState = VpnConnectionState.disconnected;
      currentConfig = null;
      clientPublicKey = null;
      lastError = 'Disconnect failed: $e';
      rethrow;
    }
  }

  void selectServer(Server server) {
    selectedServer = server;
  }

  void dispose() {
    _api.dispose();
  }
}
