import 'package:dio/dio.dart';
import 'api_service.dart';
import '../../features/building_types/model/building_type_input.dart';

class ApiBuildingTypeInput {
  final _dio = ApiClient.I.dio;
  static const _base = '/building-type-input';

  Map<String, dynamic> _flatten(Map<String, dynamic> e) {
    final bt = (e['buildingType'] as Map<String, dynamic>?) ?? const {};
    final res = (e['resource'] as Map<String, dynamic>?) ?? const {};
    return {
      'idBuildingTypeInput': e['idBuildingTypeInput'] ?? e['id'],
      'idBuildingType': bt['idBuildingType'] ?? e['idBuildingType'],
      'idResource': res['idResource'] ?? res['idItem'] ?? e['idResource'],
      'consumePerSec': e['consumePerSec'],
      'amountPerSec': e['amountPerSec'],
    };
  }

  Future<List<BuildingTypeInputModel>> getAll() async {
    final r = await _dio.get(_base);
    final list = (r.data as List).cast<Map<String, dynamic>>();
    return list.map((e) => BuildingTypeInputModel.fromJson(_flatten(e))).toList();
  }

  Future<List<BuildingTypeInputModel>> getByBuilding(int idBuilding) async {
    try {
      final r = await _dio.get('$_base/by-building/$idBuilding');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map((e) => BuildingTypeInputModel.fromJson(_flatten(e))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return <BuildingTypeInputModel>[];
      rethrow;
    }
  }

  Future<List<BuildingTypeInputModel>> getByResource(int idResource) async {
    try {
      final r = await _dio.get('$_base/by-resource/$idResource');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map((e) => BuildingTypeInputModel.fromJson(_flatten(e))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return <BuildingTypeInputModel>[];
      rethrow;
    }
  }
}
