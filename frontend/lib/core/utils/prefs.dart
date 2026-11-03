import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_coach_new/features/auth/login/data/models/user_model.dart';

@lazySingleton
class Prefs {
  final SharedPreferences prefs;

  static const String userIdKey = 'userId';
  static const String tokenKey = 'token';
  static const String userDataKey = 'user_data';

  Prefs(this.prefs);

  Future<void> putInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  int? getIntWithNull(String key) {
    return prefs.getInt(key);
  }

  Future<void> putBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> putString(String key, String value) async {
    await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<void> saveToken(String token) async {
    await prefs.setString(tokenKey, token);
  }

  String? get token => prefs.getString(tokenKey);

  Future<void> saveUser(UserModel user) async {
    await prefs.setString(userDataKey, jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final jsonString = prefs.getString(userDataKey);
    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  int? get userId => getUser()?.userId;

  Future<void> clear() async {
    await prefs.clear();
  }
}
