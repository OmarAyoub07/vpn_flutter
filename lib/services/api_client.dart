import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/env.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> get(String path) => _request('GET', path);

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) =>
      _request('POST', path, body: body);

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${Env.baseUrl}$path');
    final headers = {'Content-Type': 'application/json'};

    late http.Response response;
    try {
      if (method == 'GET') {
        response = await _client.get(uri, headers: headers).timeout(_timeout);
      } else {
        response = await _client.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(_timeout);
      }
    } catch (e) {
      throw ApiException(0, 'Network error: $e');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    final errorBody = _tryDecodeError(response.body);

    switch (response.statusCode) {
      case 404:
        throw ApiException(404, errorBody ?? 'Not found');
      case 429:
        throw ApiException(429, errorBody ?? 'Too many requests');
      case 500:
        throw ApiException(500, errorBody ?? 'Server error');
      case 502:
        throw ApiException(502, errorBody ?? 'Server unreachable');
      case 503:
        throw ApiException(503, errorBody ?? 'Service unavailable');
      default:
        throw ApiException(
            response.statusCode, errorBody ?? 'Request failed');
    }
  }

  String? _tryDecodeError(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data['error'] as String? ??
            data['message'] as String? ??
            data['detail'] as String?;
      }
    } catch (_) {}
    return null;
  }

  void dispose() => _client.close();
}
