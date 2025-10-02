import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html show window;

class LS {
  LS._();
  static final LS I = LS._();

  Future<String?> read(String key) async {
    if (kIsWeb) {
      return html.window.localStorage[key];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    if (kIsWeb) {
      html.window.localStorage[key] = value;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      dynamic v = jsonDecode(raw);
      if (v is String) v = jsonDecode(v);
      return (v is Map<String, dynamic>) ? v : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>?> readJsonList(String key) async {
    final raw = await read(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      dynamic v = jsonDecode(raw);
      if (v is String) v = jsonDecode(v);
      return (v is List) ? v : null;
    } catch (_) {
      return null;
    }
  }
}

// Ключи и шаблоны
class LsKeys {
  static const authCandidates = <String>[
    'flutter.auth_user_json',
    'auth_user_json',
  ];

  static String userCity(int userId) => 'flutter.user_city_$userId';
  static String userInventory(int userId) => 'flutter.user_inventory_$userId';

  // Список id завершённых задач по пользователю
  static String tasksDone(int userId) => 'flutter.level_tasks_done_$userId';
}
