import 'package:hackathon_economy_app/features/city_map/services/user_city_storage.dart';
import 'package:hackathon_economy_app/features/city_map/services/user_inventory_storage.dart';
import 'package:hackathon_economy_app/features/user_buildings/model/user_building.dart';

class PurchaseResult {
  final bool ok;
  final String? error;
  final UserBuildingModel? building;
  final double? newCoins;

  const PurchaseResult._({
    required this.ok,
    this.error,
    this.building,
    this.newCoins,
  });

  factory PurchaseResult.ok({
    required UserBuildingModel building,
    required double newCoins,
  }) => PurchaseResult._(ok: true, building: building, newCoins: newCoins);

  factory PurchaseResult.fail(String message) => PurchaseResult._(ok: false, error: message);
}

class PurchaseService {
  final UserInventoryStorage inventory;
  final UserCityStorage city;

  PurchaseService({
    required this.inventory,
    required this.city,
  });

  // 1 - попытка списать монеты 'coin'
  // 2 - создаём локально здание со state 'preview' для режима размещения
  // 3 - если шаг 2 не сработал — откатываем монеты.
  Future<PurchaseResult> buyBuildingLocal({
    required int userId,
    required int buildingTypeId,
    required double costCoins,
  }) async {
    // 1
    final spent = await inventory.trySpendByCode(
      userId: userId,
      code: 'coins',
      cost: costCoins,
    );
    if (!spent) {
      return PurchaseResult.fail('Недостаточно монет.');
    }

    // 2
    try {
      final ub = await city.addLocalBuilding(
        userId: userId,
        buildingTypeId: buildingTypeId,
        state: 'preview',
        x: -1,
        y: -1,
        currentLevel: 1,
      );

      final newCoins = await inventory.getAmountByCodeSafe(userId, 'coins');
      return PurchaseResult.ok(building: ub, newCoins: newCoins);
    } catch (e) {
      // 3
      await inventory.addByCode(userId: userId, code: 'coins', delta: costCoins);
      return PurchaseResult.fail('Не удалось создать здание: $e');
    }
  }
}
