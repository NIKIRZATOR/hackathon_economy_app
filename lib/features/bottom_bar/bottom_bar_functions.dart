import 'package:flutter/material.dart';

import '../building_types/model/building_type_model.dart';
import '../building_types/repo/mock_building_type_repository.dart';
import '../shop_widget/building_shop_dialog.dart';

// ▼ добавлено для окна "Задания"
import '../tasks/model/task_model.dart';
import '../tasks/repo/mock_tasks_repository.dart';
import '../tasks/widgets/tasks_dialog.dart';

/// Открыть диалог "Задания"
Future<void> openTasks(BuildContext context) async {
  // Показ простого лоадера, пока "грузим" список заданий
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Подтягиваем (пока что) мок-данные
    final repo = MockTasksRepository();
    final List<GameTask> tasks = await repo.loadAll();

    // Закрываем лоадер
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();

    // Показываем диалог с заданиями
    await showDialog<void>(
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

/// Открыть диалог "Магазин"
Future<BuildingType?> openShop(
    BuildContext context,
    double screenHeight,
    double screenWight,
    ) async {
  // Лоадер
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final repo = MockBuildingTypeRepository();
    final types = await repo.loadAll();

    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();

    // возвращаем Future из showDialog
    return showDialog<BuildingType>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BuildingShopDialog(
        buildingTypes: types,
        screenHeight: screenHeight,
        screenWight: screenWight,
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

/// Открыть "Альманах" (пока заглушка)
void openAlmanac(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Открыть Альманах')),
  );
}