import '../../../app/services/api_user_buildings.dart';
import '../model/user_building.dart';

class UserBuildingRepository {
  final _api = ApiUserBuilding();

  Future<List<UserBuildingModel>> getAll() => _api.getAll();

  Future<List<UserBuildingModel>> getByUser(int userId) => _api.getByUser(userId);

  Future<UserBuildingModel> create({
    required int userId,
    required int buildingTypeId,
    required int x,
    required int y,
    int currentLevel = 1,
    String state = 'placed',
    DateTime? placedAt,
    DateTime? lastUpgradeAt,
  }) =>
      _api.create(
        userId: userId,
        buildingTypeId: buildingTypeId,
        x: x,
        y: y,
        currentLevel: currentLevel,
        state: state,
        placedAt: placedAt,
        lastUpgradeAt: lastUpgradeAt,
      );

  Future<void> update(
      int idUserBuilding, {
        int? x,
        int? y,
        int? currentLevel,
        String? state,
        DateTime? placedAt,
        DateTime? lastUpgradeAt,
      }) =>
      _api.update(
        idUserBuilding,
        x: x,
        y: y,
        currentLevel: currentLevel,
        state: state,
        placedAt: placedAt,
        lastUpgradeAt: lastUpgradeAt,
      );

  Future<void> delete(int idUserBuilding) => _api.delete(idUserBuilding);
}
