import 'package:dio/dio.dart';

import '../../features/user_building_progress/model/user_building_progress_model.dart';
import 'api_service.dart';

class ApiUserBuildingProgress {
  final _dio = ApiClient.I.dio;
  static const _base = '/user-building-progress';

  // Сервер отдаёт вложенные объекты (join'ы): userBuilding, resourceIn, resourceOut.
  // Превратим их в плоскую структуру для нашей fromJson.
  Map<String, dynamic> _flatten(Map<String, dynamic> e) {
    final ub  = (e['userBuilding'] as Map<String, dynamic>?) ?? const {};
    final rin = (e['resourceIn'] as Map<String, dynamic>?) ?? const {};
    final rout= (e['resourceOut'] as Map<String, dynamic>?) ?? const {};

    return {
      'idProgress': e['idProgress'] ?? e['id'],

      'idUserBuilding': ub['idUserBuilding'] ?? e['idUserBuilding'],
      'idResourceIn': rin['idResource'] ?? e['idResourceIn'],
      'idResourceOut': rout['idResource'] ?? e['idResourceOut'],

      'cycleDurationSec': e['cycleDurationSec'],
      'inPerCycle': e['inPerCycle'],
      'outPerCycle': e['outPerCycle'],

      'totalToProcess': e['totalToProcess'],
      'processedCount': e['processedCount'],
      'readyOut': e['readyOut'],

      'startedAtClient': e['startedAtClient'],
      'startedAtServer': e['startedAtServer'],
      'updatedAt': e['updatedAt'],

      'state': e['state'],
    };
  }

  // GET /user-building-progress
  Future<List<UserBuildingProgressModel>> getAll() async {
    final r = await _dio.get(_base);
    final list = (r.data as List).cast<Map<String, dynamic>>();
    return list.map((e) => UserBuildingProgressModel.fromJson(_flatten(e))).toList();
  }

  // GET /user-building-progress/by-user/:idUser
  Future<List<UserBuildingProgressModel>> getByUser(int userId) async {
    try {
      final r = await _dio.get('$_base/by-user/$userId');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map((e) => UserBuildingProgressModel.fromJson(_flatten(e))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return <UserBuildingProgressModel>[];
      rethrow;
    }
  }

  // GET /user-building-progress/:idProgress
  Future<UserBuildingProgressModel?> getOne(int idProgress) async {
    try {
      final r = await _dio.get('$_base/$idProgress');
      final map = r.data as Map<String, dynamic>;
      return UserBuildingProgressModel.fromJson(_flatten(map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  // POST /user-building-progress
  Future<UserBuildingProgressModel> start({
    required int idUserBuilding,
    required int idResourceIn,
    required int idResourceOut,
    required int cycleDurationSec,
    required double inPerCycle,
    required double outPerCycle,
    required int totalToProcess,
    DateTime? startedAtClient, // если не передать — поставим сейчас
    int? processedCount, // можно не передавать
    double? readyOut, // можно не передавать
    String? state, // default 'running'
  }) async {
    final body = <String, dynamic>{
      'userBuilding': {'idUserBuilding': idUserBuilding},
      'resourceIn':   {'idResource': idResourceIn},
      'resourceOut':  {'idResource': idResourceOut},
      'cycleDurationSec': cycleDurationSec,
      'inPerCycle': inPerCycle,
      'outPerCycle': outPerCycle,
      'totalToProcess': totalToProcess,
      'startedAtClient': (startedAtClient ?? DateTime.now().toUtc()).toIso8601String(),
      if (processedCount != null) 'processedCount': processedCount,
      if (readyOut != null) 'readyOut': readyOut,
      if (state != null) 'state': state,
    };

    final r = await _dio.post(_base, data: body);
    return UserBuildingProgressModel.fromJson(_flatten(r.data as Map<String, dynamic>));
  }

  // PUT /user-building-progress/:idProgress
  // обноыляем только: processedCount, readyOut, state
  Future<void> update(
      int idProgress, {
        int? processedCount,
        double? readyOut,
        String? state,
      }) async {
    final body = <String, dynamic>{
      if (processedCount != null) 'processedCount': processedCount,
      if (readyOut != null) 'readyOut': readyOut,
      if (state != null) 'state': state,
    };
    await _dio.put('$_base/$idProgress', data: body);
  }

  // DELETE /user-building-progress/:idProgress
  Future<void> delete(int idProgress) async {
    await _dio.delete('$_base/$idProgress');
  }
}
