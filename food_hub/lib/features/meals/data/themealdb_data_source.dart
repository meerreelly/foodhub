import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../../core/errors/app_error.dart';

class TheMealDbDataSource {
  TheMealDbDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> get(String path, Map<String, String> query) async {
    final uri = Uri.parse('${Env.mealDbBaseUrl}/$path').replace(queryParameters: query);
    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MealApiException(AppErrorType.requestFailed, statusCode: response.statusCode);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class MealApiException extends AppException {
  const MealApiException(super.type, {super.statusCode});
}
