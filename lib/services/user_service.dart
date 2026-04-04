import 'dart:convert';

import '../models/app_config.dart';
import '../models/app_user.dart';
import '../models/connection_history.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _client;

  UserService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<AppConfigResponse> getConfig() async {
    final response = await _client.get('/config/');
    return AppConfigResponse.fromJson(jsonDecode(response.body));
  }

  Future<AppUser> registerDevice(String deviceId, {String? referralCode}) async {
    final body = <String, dynamic>{'device_id': deviceId};
    if (referralCode != null && referralCode.isNotEmpty) {
      body['referral_code'] = referralCode;
    }
    final response = await _client.post(
      '/users/register-device/',
      body: body,
    );
    return AppUser.fromJson(jsonDecode(response.body));
  }

  Future<List<ConnectionHistory>> getHistory(String deviceId) async {
    final response = await _client.get('/users/$deviceId/history/');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => ConnectionHistory.fromJson(json)).toList();
  }

  Future<AppUser> claimReward(String deviceId, int tierId) async {
    final response = await _client.post(
      '/users/$deviceId/reward/',
      body: {'tier_id': tierId},
    );
    return AppUser.fromJson(jsonDecode(response.body));
  }

  Future<void> syncTime(String deviceId, int remainingSeconds) async {
    await _client.post(
      '/users/$deviceId/sync-time/',
      body: {'remaining_seconds': remainingSeconds},
    );
  }

  void dispose() => _client.dispose();
}
