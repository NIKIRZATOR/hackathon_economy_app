
import '../../../app/services/api_user_resource.dart';
import '../../city_map/services/user_inventory_storage.dart';
import '../model/user_resource_model.dart';

class UserResourceRepository {
  final _api = ApiUserResource();
  final _storage = UserInventoryStorage();

  Future<List<UserResource>> syncFromServerAndCache(int userId) async {
    final items = await _api.getByUser(userId);
    await _storage.saveAll(userId, items);
    return items;
  }

  Future<List<UserResource>> loadFromCache(int userId) => _storage.load(userId);

  // Обновление количества (идемпотентно) + синхронизируем кэш.
  Future<void> setAmount({
    required int userId,
    required int resourceId,
    required double amount,
  }) async {
    await _api.updateByPair(userId: userId, resourceId: resourceId, amount: amount);
    await _storage.upsertByPair(userId: userId, resourceId: resourceId, amount: amount);
  }

  // На основе кода ресурса.
  Future<double> getAmountByCode(int userId, String code) async {
    final items = await _storage.load(userId);
    final it = items.firstWhere((e) => e.resource.code == code, orElse: () =>
    throw StateError('Resource code "$code" not found in cache'));
    return it.amount;
  }
}
