import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_model.dart';

class SettingsStorage {
  static const _key = 'exassist.settings.v1';

  Future<AppSettings> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(s.toJson()));
  }
}