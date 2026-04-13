import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../core/env.dart';

class FeedbackService {
  Future<bool> submitFeedback({
    required String? deviceId,
    required List<String> selectedFeatures,
    required String description,
    required List<String> selectedImprovements,
    required String finalThoughts,
    required List<XFile> attachments,
  }) async {
    try {
      final uri = Uri.parse('${Env.baseUrl}/feedback/');

      if (attachments.isEmpty) {
        final body = <String, dynamic>{
          'selected_features': selectedFeatures,
          'description': description,
          'selected_improvements': selectedImprovements,
          'final_thoughts': finalThoughts,
        };
        if (deviceId != null) body['device_id'] = deviceId;

        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));

        debugPrint('Feedback JSON: ${response.statusCode}');
        return response.statusCode == 201;
      }

      // Two-step: 1) create feedback via JSON, 2) upload images separately
      final body = <String, dynamic>{
        'selected_features': selectedFeatures,
        'description': description,
        'selected_improvements': selectedImprovements,
        'final_thoughts': finalThoughts,
      };
      if (deviceId != null) body['device_id'] = deviceId;

      final createResponse = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      debugPrint('Feedback create: ${createResponse.statusCode}');
      if (createResponse.statusCode != 201) return false;

      final feedbackId = jsonDecode(createResponse.body)['id'] as int?;
      if (feedbackId == null) return false;

      // Upload attachments to separate endpoint
      final uploadUri = Uri.parse('${Env.baseUrl}/feedback/$feedbackId/attachments/');
      final request = http.MultipartRequest('POST', uploadUri);

      for (final file in attachments) {
        final bytes = await file.readAsBytes();
        final ext = file.name.split('.').last.toLowerCase();
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: file.name,
            contentType: _mimeType(ext),
          ),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final uploadResponse = await http.Response.fromStream(streamed);
      debugPrint('Feedback attachments: ${uploadResponse.statusCode}');

      return true;
    } catch (e) {
      debugPrint('Feedback submit error: $e');
      return false;
    }
  }

  static MediaType _mimeType(String ext) {
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
