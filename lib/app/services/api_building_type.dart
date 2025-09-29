import 'api_service.dart';
import '../../features/building_types/model/building_type_model.dart';

class ApiBuildingType {
  final _dio = ApiClient.I.dio;

  static const _base = '/building-type';

  Future<List<BuildingType>> getAll() async {
    final r = await _dio.get(_base);
    final list = (r.data as List).cast<Map<String, dynamic>>();
    return list.map(BuildingType.fromJson).toList();
  }

  Future<BuildingType> getById(int id) async {
    final r = await _dio.get('$_base/$id');
    return BuildingType.fromJson(r.data as Map<String, dynamic>);
  }
}
