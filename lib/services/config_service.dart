import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ConfigService {
  static Map<String, dynamic>? _config;

  static Future<void> loadConfig() async {
    final String jsonString = await rootBundle.loadString('assets/config/config.json');
    _config = jsonDecode(jsonString);
  }

  static String get apiBaseUrl => _config?["api_base_url"] ?? "https://default.api.com";
  static String get appName => _config?["app_name"] ?? "Flutter App";
  static String get version => _config?["version"] ?? "1.0.0";
  static List<dynamic> get documentTypes => _config?['document_type'] ?? <dynamic>[];
}
