import 'package:flutter/material.dart';

/// Открыть экран/диалог уровня (пока заглушка)
void openLevelInfo(BuildContext context, {required int userId, required int level}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Открыть уровень: userId=$userId, lvl=$level')),
  );
}

/// Открыть настройки (пока заглушка)
void openSettings(BuildContext context, {required int userId}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Открыть настройки для userId=$userId')),
  );
}