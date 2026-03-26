import 'dart:convert';

import 'api_client.dart';

class LocalizationService {
  final ApiClient _client;

  LocalizationService({ApiClient? client})
      : _client = client ?? ApiClient();

  Future<List<Map<String, dynamic>>> getLanguages() async {
    final response = await _client.get('/localization/languages/');
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, String>> getLabels(String languageCode) async {
    final response =
        await _client.get('/localization/labels/$languageCode/');
    final Map<String, dynamic> data = jsonDecode(response.body);
    final Map<String, dynamic> sections =
        data['labels'] as Map<String, dynamic>;
    final Map<String, String> flat = {};
    for (final section in sections.values) {
      if (section is Map<String, dynamic>) {
        for (final entry in section.entries) {
          flat[entry.key] = entry.value.toString();
        }
      }
    }
    return flat;
  }

  void dispose() => _client.dispose();
}
