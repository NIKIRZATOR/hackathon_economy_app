import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/building_type_input.dart';
import '../model/building_type_output.dart';

class BtCache {
  static Future<Map<int, List<BuildingTypeInputModel>>> inputsByType() async {
    final sp = await SharedPreferences.getInstance();
    String? raw =
        sp.getString('flutter.building_type_inputs') ??
        sp.getString('building_type_inputs') ??
        sp.getString('bt_inputs');
    if (raw == null || raw.trim().isEmpty) {
      debugPrint('[bt_inputs] empty/null');
      return {};
    }
    late final List data;
    try {
      data = jsonDecode(raw) as List;
    } catch (e) {
      debugPrint('[bt_inputs] JSON decode error: $e');
      return {};
    }
    final list = <BuildingTypeInputModel>[];
    for (final e in data) {
      if (e is Map<String, dynamic>) {
        final m = Map<String, dynamic>.from(e);
        if (m['idBuildingType'] is String) {
          m['idBuildingType'] =
              int.tryParse(m['idBuildingType']) ?? m['idBuildingType'];
        }
        if (m['idResource'] is String) {
          m['idResource'] = int.tryParse(m['idResource']) ?? m['idResource'];
        }
        list.add(BuildingTypeInputModel.fromJson(m));
      }
    }
    final map = <int, List<BuildingTypeInputModel>>{};
    for (final it in list) {
      map.putIfAbsent(it.idBuildingType, () => []).add(it);
    }
    debugPrint(
      '[bt_inputs] loaded types: ${map.map((k, v) => MapEntry(k, v.length))}',
    );
    return map;
  }

  static Future<Map<int, List<BuildingTypeOutputModel>>> outputsByType() async {
    final sp = await SharedPreferences.getInstance();
    String? raw =
        sp.getString('flutter.building_type_outputs') ??
        sp.getString('building_type_outputs') ??
        sp.getString('bt_outputs');
    if (raw == null || raw.trim().isEmpty) {
      debugPrint('[bt_outputs] empty/null');
      return {};
    }
    late final List data;
    try {
      data = jsonDecode(raw) as List;
    } catch (e) {
      debugPrint('[bt_outputs] JSON decode error: $e');
      return {};
    }
    final list = <BuildingTypeOutputModel>[];
    for (final e in data) {
      if (e is Map<String, dynamic>) {
        final m = Map<String, dynamic>.from(e);
        if (m['idBuildingType'] is String) {
          m['idBuildingType'] =
              int.tryParse(m['idBuildingType']) ?? m['idBuildingType'];
        }
        if (m['idResource'] is String) {
          m['idResource'] = int.tryParse(m['idResource']) ?? m['idResource'];
        }
        list.add(BuildingTypeOutputModel.fromJson(m));
      }
    }
    final map = <int, List<BuildingTypeOutputModel>>{};
    for (final it in list) {
      map.putIfAbsent(it.idBuildingType, () => []).add(it);
    }
    debugPrint(
      '[bt_outputs] loaded types: ${map.map((k, v) => MapEntry(k, v.length))}',
    );
    return map;
  }
}
