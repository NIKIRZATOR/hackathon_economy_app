import 'package:hackathon_economy_app/features/city_map/services/user_city_storage.dart';
import 'package:hackathon_economy_app/features/city_map/services/user_inventory_storage.dart';
import 'package:hackathon_economy_app/features/user_buildings/model/user_building.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';

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
    UserBuildingModel? building,
    required double newCoins,
  }) =>
      PurchaseResult._(ok: true, building: building, newCoins: newCoins);

  factory PurchaseResult.fail(String message) =>
      PurchaseResult._(ok: false, error: message);
}

class PurchaseService {
  final UserInventoryStorage inventory;
  final UserCityStorage city;

  PurchaseService({
    required this.inventory,
    required this.city,
  });

  // СТАРЫЙ сценарий: сразу создаёт preview-здание в SP.
  Future<PurchaseResult> buyBuildingLocal({
    required int userId,
    required int buildingTypeId,
    required double costCoins,
  }) async {
    final spent = await inventory.trySpendByCode(
      userId: userId,
      code: 'coins',
      cost: costCoins,
    );
    if (!spent) {
      return PurchaseResult.fail('Недостаточно монет.');
    } else {
      AudioManager().playSfx('cash_register.mp3');
    }

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
      // откат монет при неудаче создания записи
      await inventory.addByCode(userId: userId, code: 'coins', delta: costCoins);
      return PurchaseResult.fail('Не удалось создать здание: $e');
    }
  }

  // только списываем монеты, здание в localStorage еще не пишем
  Future<PurchaseResult> buyBuildingPreview({
    required int userId,
    required int buildingTypeId,
    required double costCoins,
  }) async {
    final spent = await inventory.trySpendByCode(
      userId: userId,
      code: 'coins',
      cost: costCoins,
    );

    if (!spent) {
      return PurchaseResult.fail('Недостаточно монет.');
    }

    AudioManager().playSfx('cash_register.mp3');

    final newCoins = await inventory.getAmountByCodeSafe(userId, 'coins');
    return PurchaseResult.ok(newCoins: newCoins);
  }
}
