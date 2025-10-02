import 'dart:convert';
import 'package:hackathon_economy_app/features/tasks/service/read_local_storage.dart';

import '../model/task_model.dart';
import '../service/task_requirements.dart';

class TaskCompletionService {
  TaskCompletionService._();
  static final TaskCompletionService I = TaskCompletionService._();

  // Загрузка set выполненных id задач для игрока
  Future<Set<String>> loadDone(int userId) async {
    final raw = await LS.I.read(LsKeys.tasksDone(userId));
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> saveDone(int userId, Set<String> done) async {
    await LS.I.write(LsKeys.tasksDone(userId), jsonEncode(done.toList()));
  }

  Future<bool> canComplete(LevelTask t, int userId) async {
    switch (t.type) {
      case 'build': {
        // 1 - явное сопоставление по id задачи
        final explicit = TaskRequirements.buildTypeByTaskId[t.id];
        int? btId = explicit;

        // 2  если не нашло
        btId ??= int.tryParse(RegExp(r'(\d+)$').firstMatch(t.id)?.group(1) ?? '');

        if (btId == null) return false;

        final list = await LS.I.readJsonList(LsKeys.userCity(userId)) ?? const [];
        for (final it in list) {
          if (it is Map && (it['idBuildingType'] == btId)) {
            return true;
          }
        }
        return false;
      }

      case 'save_coins':
      case 'deposit':
      case 'loan': {
        // 1- требование если есть
        final explicit = TaskRequirements.coinsByTaskId[t.id];
        int need = explicit ?? 0;

        // 2
        if (need == 0) {
          need = int.tryParse(RegExp(r'\d+').firstMatch(t.title)?.group(0) ?? '') ?? 0;
        }

        final inv = await LS.I.readJsonList(LsKeys.userInventory(userId)) ?? const [];
        for (final it in inv) {
          if (it is Map && it['resource'] is Map) {
            final res = it['resource'] as Map;
            if (res['idResource'] == 1) {
              final amt = (it['amount'] is int) ? it['amount'] : int.tryParse('${it['amount']}') ?? 0;
              return amt >= need;
            }
          }
        }
        return false;
      }

      case 'upgrade':
      case 'almanac':
        return true;

      default:
        return true;
    }
  }
}
