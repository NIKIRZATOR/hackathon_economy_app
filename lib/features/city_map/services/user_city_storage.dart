import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../user_buildings/model/user_building.dart';

class UserCityStorage {
  static String _key(int userId) => 'user_city_$userId';

  Future<List<UserBuildingModel>> load(int userId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key(userId));
    if (raw == null || raw.isEmpty) return [];
    final List data = jsonDecode(raw);
    return data.map((e) => UserBuildingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(int userId, List<UserBuildingModel> items) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await sp.setString(_key(userId), raw);
  }

  Future<int> nextLocalId(int userId) async {
    final items = await load(userId);
    if (items.isEmpty) return 1;
    final maxId = items.map((e) => e.idUserBuilding).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  Future<void> upsert(int userId, UserBuildingModel ub) async {
    final items = await load(userId);
    final idx = items.indexWhere((e) => e.idUserBuilding == ub.idUserBuilding);
    if (idx >= 0) {
      items[idx] = ub;
    } else {
      items.add(ub);
    }
    await saveAll(userId, items);
  }

  Future<void> updatePositionByClientId(int userId, String clientId, int x, int y) async {
    final items = await load(userId);
    final idx = items.indexWhere((e) => e.clientId == clientId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(x: x, y: y);
      await saveAll(userId, items);
    }
  }
}
