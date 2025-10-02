import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/task_model.dart';

Future<LevelsData> loadLevels() async {
  final raw = await rootBundle.loadString('assets/mock_data/levels_tasks.json');
  return LevelsData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

class NoScrollbar extends ScrollBehavior {
  const NoScrollbar();
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}

String taskTitleForUi(LevelTask t) {
  if (t.type == 'almanac') {
    final digits = RegExp(r'\d+').firstMatch(t.title)?.group(0) ?? '';
    return 'Выполнить тест № $digits в альманахе';
  }
  return t.title;
}