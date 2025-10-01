import 'dart:convert';
import 'package:hackathon_economy_app/features/resource/model/resource_model.dart';
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

  // без исключений: если нет кода — вернём 0.
  Future<double> getAmountByCodeSafe(int userId, String code) async {
    final items = await load(userId);
    final it = items.where((e) => e.resource.code == code).toList();
    if (it.isEmpty) return 0;
    return it.first.amount;
  }

  // Установить количество ресурса по code из localstorage
  Future<void> setAmountByCode({
    required int userId,
    required String code,
    required double amount,
  }) async {
    final items = await load(userId);
    final idx = items.indexWhere((e) => e.resource.code == code);
    if (idx < 0) {
      // локально не создаём новую запись
      return;
    }
    items[idx] = items[idx].copyWith(amount: amount);
    await saveAll(userId, items);
  }

  // попытка списания стоимость по коду ресурса
  Future<bool> trySpendByCode({
    required int userId,
    required String code,
    required double cost,
  }) async {
    if (cost <= 0) return true;
    final curr = await getAmountByCodeSafe(userId, code);
    if (curr + 1e-9 < cost) return false;
    await setAmountByCode(userId: userId, code: code, amount: curr - cost);
    return true;
  }

  // начисление по коду ресурса
  Future<void> addByCode({
    required int userId,
    required String code,
    required double delta,
  }) async {
    if (delta == 0) return;
    final curr = await getAmountByCodeSafe(userId, code);
    await setAmountByCode(userId: userId, code: code, amount: curr + delta);
  }

  // создать/обновить по коду ресурса
  Future<void> upsertByCode({
    required int userId,
    required String code,
    required double amount,
    required ResourceItem Function(String code) resourceFactory,
  }) async {
    final items = await load(userId);
    final idx = items.indexWhere((e) => e.resource.code == code);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(amount: amount);
    } else {
      final res = resourceFactory(code);
      items.add(UserResource(
        idUserResource: -1, // локальный временный id
        userId: userId,
        amount: amount,
        resource: res,
      ));
    }
    await saveAll(userId, items);
  }

// безопасная установка по коду (создаёт при отсутствии)
  Future<void> setAmountByCodeSafe({
    required int userId,
    required String code,
    required double amount,
    required ResourceItem Function(String code) resourceFactory,
  }) => upsertByCode(userId: userId, code: code, amount: amount, resourceFactory: resourceFactory);

// начисление по коду (создаёт при отсутствии)
  Future<void> addByCodeSafe({
    required int userId,
    required String code,
    required double delta,
    required ResourceItem Function(String code) resourceFactory,
  }) async {
    if (delta == 0) return;
    final curr = await getAmountByCodeSafe(userId, code);
    await setAmountByCodeSafe(userId: userId, code: code, amount: curr + delta, resourceFactory: resourceFactory);
  }
}
