import 'dart:async';
import '../../../app/services/api_user_buildings.dart';
import '../../city_map/services/user_city_storage.dart'; // твой стор
import '../model/user_building.dart';

class UserBuildingRepository {
  final _api = ApiUserBuilding();
  final _storage = UserCityStorage();

  Future<List<UserBuildingModel>> getAll() => _api.getAll();
  Future<List<UserBuildingModel>> getByUser(int userId) => _api.getByUser(userId);

  // получаем с сервера, если 404 — пусто; в любом случае сохраняем в кэш.
  Future<List<UserBuildingModel>> syncFromServerAndCache(int userId) async {
    try {
      final items = await _api.getByUser(userId);
      await _storage.saveAll(userId, items);
      return items;
    } catch (_) {
      // если нет сети - берём то, что было в кеше
      return _storage.load(userId);
    }
  }

  Future<List<UserBuildingModel>> loadFromCache(int userId) => _storage.load(userId);

  Future<UserBuildingModel> create({
    required int userId,
    required int buildingTypeId,
    required int x,
    required int y,
    required String clientId,
    int currentLevel = 1,
    String state = 'placed',
    DateTime? placedAt,
    DateTime? lastUpgradeAt,
  }) => _api.create(
    userId: userId,
    buildingTypeId: buildingTypeId,
    clientId: clientId,
    x: x, y: y,
    currentLevel: currentLevel,
    state: state,
    placedAt: placedAt,
    lastUpgradeAt: lastUpgradeAt,
  );

  Future<UserBuildingModel> update(int idUserBuilding, {
    int? x, int? y, int? currentLevel,
    String? state, DateTime? placedAt, DateTime? lastUpgradeAt,
  }) => _api.update(
    idUserBuilding,
    x: x, y: y, currentLevel: currentLevel, state: state,
    placedAt: placedAt, lastUpgradeAt: lastUpgradeAt,
  );

  Future<void> delete(int idUserBuilding) => _api.delete(idUserBuilding);
}
