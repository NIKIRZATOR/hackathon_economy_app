import 'dart:async';
import '../model/task_model.dart';

class MockTasksRepository {
  Future<List<GameTask>> loadAll() async {
    // имитация сети
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      GameTask(id: 'build_city_hall', title: 'Построить мэрию', done: true),
      GameTask(id: 'save_200_coins', title: 'Накопить 200 монет'),
      GameTask(id: 'quiz_1', title: 'Выполнить тест № 1 в альманахе'),
    ];
  }
}