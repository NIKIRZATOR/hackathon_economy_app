import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../model/building_type_model.dart';

class MockBuildingTypeRepository {
  final String pathToFile;

  const MockBuildingTypeRepository({
    this.pathToFile = 'assets/mock_data/mock_building_type.json',
  });

  Future<List<BuildingType>> loadAll() async {
    final raw = await rootBundle.loadString(pathToFile);
    final list = json.decode(raw) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map((m) => BuildingType.fromMockJson(m))
        .toList();
  }
}
