import 'package:dio/dio.dart';

import '../../features/user_buildings/model/user_building.dart';
import 'api_service.dart';

class ApiUserBuilding {
  final _dio = ApiClient.I.dio;
  static const _base = '/user-building';

  // Собираем плоскую карту под твою fromJson (camelCase)
  Map<String, dynamic> _flatten(Map<String, dynamic> e) {
    final user = (e['user'] as Map<String, dynamic>?) ?? const {};
    final bt = (e['buildingType'] as Map<String, dynamic>?) ?? const {};

    return {
      'idUserBuilding': e['idUserBuilding'] ?? e['id'],
      'idUser': user['userId'] ?? e['idUser'],
      'idBuildingType': bt['idBuildingType'] ?? e['idBuildingType'],
      'x': e['x'],
      'y': e['y'],
      'currentLevel': e['currentLevel'],
      'state': e['state'],
      'placedAt': e['placedAt'],
      'lastUpgradeAt': e['lastUpgradeAt'],
      // оставляем как есть
      'client_id': e['client_id'],
    };
  }

  // GET /user-building
  Future<List<UserBuildingModel>> getAll() async {
    final r = await _dio.get(_base);
    final list = (r.data as List).cast<Map<String, dynamic>>();
    return list.map((e) => UserBuildingModel.fromJson(_flatten(e))).toList();
  }

  // GET /user-building/by-user/:idUser
  Future<List<UserBuildingModel>> getByUser(int userId) async {
    try {
      final r = await _dio.get('$_base/by-user/$userId');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map((e) => UserBuildingModel.fromJson(_flatten(e))).toList();
    } on DioException catch (e) {
      // нет построек у нового пользователя — это ок, не ошибка
      if (e.response?.statusCode == 404) return <UserBuildingModel>[];
      rethrow;
    }
  }

  // POST /user-building
  // Сервер ждёт вложенные объекты user/buildingType
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
  }) async {
    final body = <String, dynamic>{
      'user': {'userId': userId},
      'buildingType': {'idBuildingType': buildingTypeId},
      'x': x,
      'y': y,
      'clientId': clientId,
      'currentLevel': currentLevel,
      'state': state,
      if (placedAt != null) 'placedAt': placedAt.toUtc().toIso8601String(),
      if (lastUpgradeAt != null)
        'lastUpgradeAt': lastUpgradeAt.toUtc().toIso8601String(),
    };
    final r = await _dio.post(_base, data: body);
    return UserBuildingModel.fromJson(_flatten(r.data as Map<String, dynamic>));
  }

  // PUT /user-building/:idUserBuilding
  Future<UserBuildingModel> update(
    int idUserBuilding, {
    int? x,
    int? y,
    int? currentLevel,
    String? state,
    DateTime? placedAt,
    DateTime? lastUpgradeAt,
  }) async {
    final body = <String, dynamic>{
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (currentLevel != null) 'currentLevel': currentLevel,
      if (state != null) 'state': state,
      if (placedAt != null) 'placedAt': placedAt.toUtc().toIso8601String(),
      if (lastUpgradeAt != null)
        'lastUpgradeAt': lastUpgradeAt.toUtc().toIso8601String(),
    };
    final r = await _dio.put('$_base/$idUserBuilding', data: body);
    return UserBuildingModel.fromJson(_flatten(r.data as Map<String, dynamic>));
  }

  // DELETE /user-building/:idUserBuilding
  Future<void> delete(int idUserBuilding) async {
    await _dio.delete('$_base/$idUserBuilding');
  }
}
