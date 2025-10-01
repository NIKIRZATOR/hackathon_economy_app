import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../features/city_map/services/user_city_storage.dart';
import '../../features/city_map/services/user_inventory_storage.dart';
import '../../features/user_buildings/model/user_building.dart';
import '../../features/user_resource/model/user_resource_model.dart';

import '../services/api_user.dart';
import '../services/api_user_buildings.dart';
import '../services/api_user_resource.dart';

enum SyncStatus { idle, syncing, error }

// периодический пуш локального состояния на сервер
// каждые 15 сек
class SyncService {
  SyncService._();

  static final SyncService I = SyncService._();

  final _inventoryStorage = UserInventoryStorage();
  final _cityStorage = UserCityStorage();

  final _apiUser = ApiUser();
  final _api = ApiUserResource();
  final _apiUserRes = ApiUserResource();
  final _apiUserBuilding = ApiUserBuilding();

  final ValueNotifier<SyncStatus> status = ValueNotifier(SyncStatus.idle);
  final ValueNotifier<DateTime?> lastSyncAt = ValueNotifier<DateTime?>(null);

  Timer? _timer;
  bool _busy = false;
  int? _userId;

  Duration period = const Duration(seconds: 30);

  void start({required int userId}) {
    _userId = userId;
    _timer?.cancel();
    // первый прогон сразу
    tick();
    _timer = Timer.periodic(period, (_) => tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _userId = null;
  }

  Future<void> tick() async {
    if (_busy || _userId == null) return;
    _busy = true;
    status.value = SyncStatus.syncing;            // жёлтый индикатор

    try {
      final online = await Connectivity().checkConnectivity();
      if (online == ConnectivityResult.none) {
        // офлайн — считаем, что синхрона нет
        status.value = SyncStatus.idle;
        return;
      }

      final uid = _userId!;
      await Future.wait([
        _syncInventory(uid),
        _syncBuildings(uid),
      ], eagerError: false);

      lastSyncAt.value = DateTime.now();
      status.value = SyncStatus.idle; // зелёный = успешно или ожидание
    } catch (_) {
      status.value = SyncStatus.error;            // ← красный при сбое
    } finally {
      _busy = false;
    }
  }

  // Синхрон инвентаря - читает локально и шлёт PUT /user-resource по каждой паре (userId, resourceId).
  Future<void> _syncInventory(int userId) async {
    List<UserResource> items;
    try {
      items = await _inventoryStorage.load(userId);
    } catch (_) {
      return;
    }
    if (items.isEmpty) return;

    for (final it in items) {
      try {
        await _apiUserRes.updateByPair(
          userId: userId,
          resourceId: it.resource.idResource,
          amount: it.amount,
        );
      } catch (_) {}
    }

    // перечитываем сервер и кладём в кэш
    try {
      final fresh = await _api.getByUser(userId);
      await _inventoryStorage.saveAll(userId, fresh);
    } catch (_) {}
  }

  // Синхон зданий: читает локально и шлёт PUT /user-building/:idUserBuilding
  Future<void> _syncBuildings(int userId) async {
    List<UserBuildingModel> items;
    try {
      items = await _cityStorage.load(userId);
    } catch (_) {
      return;
    }
    if (items.isEmpty) return;

    for (final b in items) {
      if ((b.state ?? '') == 'preview') continue;

      final hasServerId = b.idUserBuilding != null && b.idUserBuilding > 0;

      try {
        if (!hasServerId) {
          // первый раз на сервер — только POST c clientId
          final created = await _apiUserBuilding.create(
            userId: b.idUser,
            buildingTypeId: b.idBuildingType,
            clientId: b.clientId ?? 'local_${b.idUserBuilding}',
            x: b.x, y: b.y,
            currentLevel: b.currentLevel,
            state: b.state,
            placedAt: b.placedAt,
            lastUpgradeAt: b.lastUpgradeAt,
          );

          await _cityStorage.upsertSmart(userId, created); // склейка по clientId
          continue;
        }

        // Обновление существующего
        final updated = await _apiUserBuilding.update(
          b.idUserBuilding,
          x: b.x,
          y: b.y,
          currentLevel: b.currentLevel,
          state: b.state,
          placedAt: b.placedAt,
          lastUpgradeAt: b.lastUpgradeAt,
        );

        // update() теперь возвращает объект — положим в локалку
        await _cityStorage.upsertSmart(userId, updated);
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        if (code == 404 || code == 400 || code == 409) {
          // не нашли/конфликт — пробуем идемпотентный POST
          try {
            final created = await _apiUserBuilding.create(
              userId: b.idUser,
              buildingTypeId: b.idBuildingType,
              clientId: b.clientId ?? 'local_${b.idUserBuilding}',
              x: b.x, y: b.y,
              currentLevel: b.currentLevel,
              state: b.state,
              placedAt: b.placedAt,
              lastUpgradeAt: b.lastUpgradeAt,
            );
            await _cityStorage.upsertSmart(userId, created);
          } catch (_) {}
        }
      } catch (_) {}
    }
  }

  //пример апдейта пользователя, при локальном изменении XP/LVL.
  Future<void> syncUserStats({
    required int userId,
    int? userLvl,
    int? userXp,
    DateTime? lastClaimAt,
  }) async {
    try {
      await _apiUser.updateUser(
        id: userId,
        userLvl: userLvl,
        userXp: userXp,
        lastClaimAt: lastClaimAt,
      );
    } catch (_) {}
  }


}
// TODO ПРИ ВЫХОДЕ ОТКЛЮЧАТЬ
// await _repo.signOutActive();
// SyncService.I.stop();
