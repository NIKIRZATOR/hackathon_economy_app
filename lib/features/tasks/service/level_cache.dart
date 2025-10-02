import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../model/task_model.dart';

class LevelsCache {
  LevelsCache._();
  static final LevelsCache I = LevelsCache._();

  LevelsData? _data;

  Future<void> ensureLoaded() async {
    if (_data != null) return;
    final raw = await rootBundle.loadString('assets/mock_data/levels_tasks.json');
    _data = LevelsData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<int> requiredXpFor(int level) async {
    await ensureLoaded();
    final d = _data!;
    return d.byLevel(level).requiredXp;
  }

  Future<LevelInfo> levelInfo(int level) async {
    await ensureLoaded();
    return _data!.byLevel(level);
  }
}
