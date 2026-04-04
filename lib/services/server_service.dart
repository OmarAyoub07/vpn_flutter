import 'dart:convert';

import '../models/server.dart';
import '../models/vpn_config.dart';
import '../models/connection_status.dart';
import 'api_client.dart';

class ServerService {
  final ApiClient _client;

  ServerService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<Server>> getServers({String? lang}) async {
    final path = lang != null ? '/servers/?lang=$lang' : '/servers/';
    final response = await _client.get(path);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Server.fromJson(json)).toList();
  }

  Future<VpnConfig> register(int serverId) async {
    final response = await _client.post('/servers/$serverId/register/');
    return VpnConfig.fromJson(jsonDecode(response.body));
  }

  Future<ConnectionStatus> connect(
    int serverId,
    String clientPublicKey,
    String assignedIp, {
    String? deviceId,
  }) async {
    final body = <String, dynamic>{
      'client_public_key': clientPublicKey,
      'assigned_ip': assignedIp,
    };
    if (deviceId != null) body['device_id'] = deviceId;

    final response = await _client.post(
      '/servers/$serverId/connect/',
      body: body,
    );
    return ConnectionStatus.fromJson(jsonDecode(response.body));
  }

  Future<ConnectionStatus> disconnect(
    int serverId,
    String clientPublicKey, {
    String? deviceId,
    int? connectionId,
  }) async {
    final body = <String, dynamic>{
      'client_public_key': clientPublicKey,
    };
    if (deviceId != null) body['device_id'] = deviceId;
    if (connectionId != null) body['connection_id'] = connectionId;

    final response = await _client.post(
      '/servers/$serverId/disconnect/',
      body: body,
    );
    return ConnectionStatus.fromJson(jsonDecode(response.body));
  }

  void dispose() => _client.dispose();
}
