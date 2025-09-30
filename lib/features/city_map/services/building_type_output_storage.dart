import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../building_types/model/building_type_output.dart';

class BuildingTypeOutputStorage {
  static const _key = 'building_type_outputs';

  Future<List<BuildingTypeOutputModel>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List data = jsonDecode(raw);
    return data.map((e) => BuildingTypeOutputModel.fromJson(e)).toList();
  }

  Future<void> saveAll(List<BuildingTypeOutputModel> items) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await sp.setString(_key, raw);
  }
}
