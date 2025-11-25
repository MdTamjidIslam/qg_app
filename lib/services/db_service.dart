import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class RuntimeConfig {
  static const _prefsKey = 'local_db_config_json';

  static Map<String, dynamic>? _cache;

  /// এখনকার config (in-memory)
  static Map<String, dynamic>? get current => _cache;

  /// ১) প্রথমবার:
  ///    - prefs এ কিছু না থাকলে assets/db.txt থেকে লোড করবে
  /// ২) পরেরবার:
  ///    - prefs এর ভেতরের JSON ব্যবহার করবে (মানে তুমি in-app এডিট করেছো)
  static Future<Map<String, dynamic>> load() async {
    if (_cache != null) return _cache!;

    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_prefsKey);

    if (raw == null || raw.trim().isEmpty) {
      // প্রথম ইনস্টল / প্রথম রান: assets থেকে নাও
      raw = await rootBundle.loadString('assets/db.txt');
      await prefs.setString(_prefsKey, raw);
    }

    final map = jsonDecode(raw) as Map<String, dynamic>;
    _cache = map;
    return map;
  }

  /// নতুন JSON (string) সেভ করা – Config Editor page থেকে কল করবে
  static Future<void> saveRaw(String jsonText) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonText);
    _cache = jsonDecode(jsonText) as Map<String, dynamic>;
  }
}
