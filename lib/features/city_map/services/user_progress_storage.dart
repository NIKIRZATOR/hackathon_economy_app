import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../user_building_progress/model/user_building_progress_model.dart';

class UserProgressStorage {
  static String _keyUser(int userId) => 'user_progress_$userId';

  Future<List<UserBuildingProgressModel>> loadByUser(int userId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_keyUser(userId));
    if (raw == null || raw.isEmpty) return [];
    final List data = jsonDecode(raw);
    return data
        .map(
          (e) =>
              UserBuildingProgressModel.fromJson((e as Map<String, dynamic>)),
        )
        .toList();
  }

  Future<void> saveAllForUser(
    int userId,
    List<UserBuildingProgressModel> items,
  ) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await sp.setString(_keyUser(userId), raw);
  }

  Future<void> upsertForUser(int userId, UserBuildingProgressModel p) async {
    final items = await loadByUser(userId);
    final idx = items.indexWhere((e) => e.idProgress == p.idProgress);
    if (idx >= 0) {
      items[idx] = p;
    } else {
      items.add(p);
    }
    await saveAllForUser(userId, items);
  }

  Future<void> removeForUser(int userId, int idProgress) async {
    final items = await loadByUser(userId);
    items.removeWhere((e) => e.idProgress == idProgress);
    await saveAllForUser(userId, items);
  }
}
