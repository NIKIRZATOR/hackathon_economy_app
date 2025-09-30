import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../building_types/model/building_type_input.dart';

class BuildingTypeInputStorage {
  static const _key = 'building_type_inputs';

  Future<List<BuildingTypeInputModel>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List data = jsonDecode(raw);
    return data.map((e) => BuildingTypeInputModel.fromJson(e)).toList();
  }

  Future<void> saveAll(List<BuildingTypeInputModel> items) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await sp.setString(_key, raw);
  }
}
