import 'dart:async';

import '../../../app/services/api_user_building_progress.dart';
import '../../city_map/services/user_progress_storage.dart';
import '../model/user_building_progress_model.dart';

class UserBuildingProgressRepository {
  final _api = ApiUserBuildingProgress();
  final _storage = UserProgressStorage();

  /// Тянем все прогрессы пользователя с сервера и кладём в локальный кэш.
  /// Если сеть/сервер недоступны — вернём то, что лежит в кеше.
  Future<List<UserBuildingProgressModel>> syncFromServerAndCache(
    int userId,
  ) async {
    try {
      final items = await _api.getByUser(userId);
      await _storage.saveAllForUser(userId, items);
      return items;
    } catch (_) {
      return _storage.loadByUser(userId);
    }
  }

  /// Чтение только из кэша (например, для мгновенного UI перед синком).
  Future<List<UserBuildingProgressModel>> loadFromCache(int userId) =>
      _storage.loadByUser(userId);

  /// Старт рецепта (создание прогресса на сервере) + апдейт кэша.
  Future<UserBuildingProgressModel> start({
    required int userId, // нужен только для кэша
    required int idUserBuilding,
    required int idResourceIn,
    required int idResourceOut,
    required int cycleDurationSec,
    required double inPerCycle,
    required double outPerCycle,
    required int totalToProcess,
    DateTime? startedAtClient,
    int? processedCount,
    double? readyOut,
    String? state,
  }) async {
    final created = await _api.start(
      idUserBuilding: idUserBuilding,
      idResourceIn: idResourceIn,
      idResourceOut: idResourceOut,
      cycleDurationSec: cycleDurationSec,
      inPerCycle: inPerCycle,
      outPerCycle: outPerCycle,
      totalToProcess: totalToProcess,
      startedAtClient: startedAtClient,
      processedCount: processedCount,
      readyOut: readyOut,
      state: state,
    );
    await _storage.upsertForUser(userId, created);
    return created;
  }

  /// Обновление состояния прогресса (processedCount / readyOut / state) + кэш.
  Future<void> update(
    int userId,
    int idProgress, {
    int? processedCount,
    double? readyOut,
    String? state,
  }) async {
    await _api.update(
      idProgress,
      processedCount: processedCount,
      readyOut: readyOut,
      state: state,
    );

    // Обновим копию в кеше: подтянем одну запись либо локально подправим.
    final cached = await _storage.loadByUser(userId);
    final idx = cached.indexWhere((e) => e.idProgress == idProgress);
    if (idx >= 0) {
      final updated = cached[idx].copyWith(
        processedCount: processedCount,
        readyOut: readyOut,
        state: state,
        updatedAt: DateTime.now().toUtc(),
      );
      cached[idx] = updated;
      await _storage.saveAllForUser(userId, cached);
    } else {
      // Если в кеше нет — запросим с сервера одну запись (не обязательно, но полезно).
      final one = await _api.getOne(idProgress);
      if (one != null) {
        await _storage.upsertForUser(userId, one);
      }
    }
  }

  /// Удаление прогресса на сервере + из кэша.
  Future<void> delete(int userId, int idProgress) async {
    await _api.delete(idProgress);
    await _storage.removeForUser(userId, idProgress);
  }
}
