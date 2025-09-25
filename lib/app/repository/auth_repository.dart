import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_user.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _api = ApiUser();
  static const _kUserKey = 'auth_user_json';

  // сетевые методы
  Future<UserModel> signIn(String username, String password) async {
    final u = await _api.login(username, password);
    await saveUser(u);
    return u;
  }

  Future<UserModel> signUp(String username, String password, String cityTitle) async {
    final u = await _api.register(username: username, password: password, cityTitle: cityTitle);
    await saveUser(u);
    return u;
  }

  // локальное
  Future<UserModel?> getSavedUser() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromCacheJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await sp.remove(_kUserKey);
      return null;
    }
  }

  Future<void> saveUser(UserModel u) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kUserKey, jsonEncode(u.toCacheJson()));
  }
  Future<void> signOut(UserModel _) => signOutActive();

  Future<void> signOutActive() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kUserKey);
  }
}
