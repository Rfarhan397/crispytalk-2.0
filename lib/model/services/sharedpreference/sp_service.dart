
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  static SharedPreferences? _preferences;

  static Future<SharedPreferencesService> getInstance() async {
    _instance ??= SharedPreferencesService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _preferences!.setDouble(key, value);
  }

  Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences!.setStringList(key, value);
  }

  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  double? getDouble(String key) {
    return _preferences!.getDouble(key);
  }

  String? getString(String key) {
    return _preferences!.getString(key);
  }

  List<String>? getStringList(String key) {
    return _preferences!.getStringList(key);
  }

  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }

  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  Future<bool> clear() async {
    return await _preferences!.clear();
  }
}
