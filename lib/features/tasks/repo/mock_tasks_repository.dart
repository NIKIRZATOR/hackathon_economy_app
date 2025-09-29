import 'dart:async';
import '../model/task_model.dart';

/// Моковый репозиторий задач под НОВУЮ модель GameTask.
class MockTasksRepository {
  Future<List<GameTask>> loadAll() async {
    // имитация сети
    await Future.delayed(const Duration(milliseconds: 400));
    return <GameTask>[
      GameTask(
        id: 1,
        text: 'Построить мэрию',
        order: 1,
        unlockLevel: 1,
        xp: 50,
      ),
      GameTask(
        id: 2,
        text: 'Накопить 200 монет',
        order: 2,
        unlockLevel: 1,
        xp: 40,
      ),
      GameTask(
        id: 3,
        text: 'Выполнить тест № 1 в альманахе',
        order: 3,
        unlockLevel: 2,
        xp: 60,
      ),
    ];
  }
}
