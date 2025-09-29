import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../user_resource/model/user_resource_model.dart';

class UserInventoryStorage {
  static String _key(int userId) => 'user_inventory_$userId';

  Future<List<UserResource>> load(int userId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key(userId));
    if (raw == null || raw.isEmpty) return [];
    final List data = jsonDecode(raw);
    return data.map((e) => UserResource.fromCacheJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(int userId, List<UserResource> items) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toCacheJson()).toList());
    await sp.setString(_key(userId), raw);
  }

  Future<void> upsertByPair({
    required int userId,
    required int resourceId,
    required double amount,
  }) async {
    final items = await load(userId);
    final idx = items.indexWhere((e) => e.resource.idResource == resourceId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(amount: amount);
    } else {
      return;
    }
    await saveAll(userId, items);
  }

  Future<double> getAmountByCode(int userId, String code) async {
    final items = await load(userId);
    final it = items.firstWhere((e) => e.resource.code == code, orElse: () =>
        UserResource(idUserResource: -1, userId: userId, amount: 0, resource: items.isEmpty ?
        throw StateError('Inventory empty') : items.first.resource));
    return it.amount;
  }
}
