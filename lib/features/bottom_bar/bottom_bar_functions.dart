import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/utils/show_dialog_with_sound.dart';

import '../building_types/model/building_type_model.dart';
import '../building_types/repo/building_type_repository.dart';
import '../shop_widget/building_shop_dialog.dart';

import '../tasks/model/task_model.dart';
import '../tasks/repo/mock_tasks_repository.dart';
import '../tasks/widgets/tasks_dialog.dart';

// открыть диалог "Задания"
Future<void> openTasks(BuildContext context) async {
  // показ лоадера, пока загружается список заданий
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Подтягиваем (пока что) мок-данные
    final repo = MockTasksRepository();
    final List<GameTask> tasks = await repo.loadAll();

    // закрываем лоадер
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();

    // Показываем диалог с заданиями
    await showDialogWithSound<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => TasksDialog(tasks: tasks),
    );
  } catch (e) {
    // На всякий случай закрыть лоадер, если он открыт
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();

    // Сообщение об ошибке
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Не удалось открыть задания: $e')),
    );
  }
}

// Открыть диалог "Магазин"
Future<BuildingType?> openShop(
    BuildContext context,
    double screenHeight,
    double screenWight,
    int userLevel,
    ) async {
  // Лоадер
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final repo = BuildingTypeRepository();
    final types = await repo.getAll();

    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();

    // возвращаем Future из showDialog
    return showDialogWithSound<BuildingType>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BuildingShopDialog(
        buildingTypes: types,
        screenHeight: screenHeight,
        screenWight: screenWight,
        playerLevel: userLevel,
      ),
    );
  } catch (e) {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Не удалось загрузить магазин: $e')),
    );
    return null;
  }
}

// Открыть "Альманах" (пока заглушка)
void openAlmanac(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Открыть Альманах')),
  );
}