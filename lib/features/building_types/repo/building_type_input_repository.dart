import '../../../app/services/api_building_type_inputs.dart';
import '../../city_map/services/building_type_input_storage.dart';
import '../model/building_type_input.dart';

class BuildingTypeInputRepository {
  final _api = ApiBuildingTypeInput();
  final _storage = BuildingTypeInputStorage();

  Future<List<BuildingTypeInputModel>> syncFromServerAndCache() async {
    try {
      final items = await _api.getAll();
      await _storage.saveAll(items);
      return items;
    } catch (_) {
      return _storage.load();
    }
  }

  Future<List<BuildingTypeInputModel>> loadFromCache() => _storage.load();
}
