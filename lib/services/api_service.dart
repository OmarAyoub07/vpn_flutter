import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/server.dart';
import '../models/vpn_config.dart';
import '../models/connection_status.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const String baseUrl = 'http://174.138.28.110:8000/api';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Server>> getServers() async {
    final response = await _request('GET', '/servers/');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Server.fromJson(json)).toList();
  }

  Future<VpnConfig> register(int serverId) async {
    final response = await _request('POST', '/servers/$serverId/register/');
    return VpnConfig.fromJson(jsonDecode(response.body));
  }

  Future<ConnectionStatus> connect(
    int serverId,
    String clientPublicKey,
    String assignedIp,
  ) async {
    final response = await _request(
      'POST',
      '/servers/$serverId/connect/',
      body: {
        'client_public_key': clientPublicKey,
        'assigned_ip': assignedIp,
      },
    );
    return ConnectionStatus.fromJson(jsonDecode(response.body));
  }

  Future<ConnectionStatus> disconnect(
    int serverId,
    String clientPublicKey,
  ) async {
    final response = await _request(
      'POST',
      '/servers/$serverId/disconnect/',
      body: {'client_public_key': clientPublicKey},
    );
    return ConnectionStatus.fromJson(jsonDecode(response.body));
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};

    late http.Response response;
    try {
      if (method == 'GET') {
        response = await _client.get(uri, headers: headers);
      } else {
        response = await _client.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    } catch (e) {
      throw ApiException(0, 'Network error: $e');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    switch (response.statusCode) {
      case 404:
        throw ApiException(404, 'Not found');
      case 500:
        throw ApiException(500, 'Server error — key generation failed');
      case 502:
        throw ApiException(502, 'Server unreachable');
      case 503:
        throw ApiException(503, 'No IPs available');
      default:
        throw ApiException(response.statusCode, 'Request failed');
    }
  }

  void dispose() => _client.close();
}
