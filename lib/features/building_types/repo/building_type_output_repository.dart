import '../../../app/services/api_building_type_outputs.dart';
import '../../city_map/services/building_type_output_storage.dart';
import '../model/building_type_output.dart';

class BuildingTypeOutputRepository {
  final _api = ApiBuildingTypeOutput();
  final _storage = BuildingTypeOutputStorage();

  Future<List<BuildingTypeOutputModel>> syncFromServerAndCache() async {
    try {
      final items = await _api.getAll();
      await _storage.saveAll(items);
      return items;
    } catch (_) {
      return _storage.load();
    }
  }

  Future<List<BuildingTypeOutputModel>> loadFromCache() => _storage.load();
}
