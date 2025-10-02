import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/utils/show_dialog_with_sound.dart';
import 'package:hackathon_economy_app/core/ui/DialogWithCross.dart';

import '../building_types/model/building_type_model.dart';
import '../building_types/repo/building_type_repository.dart';
import '../shop_widget/building_shop_dialog.dart';

import '../tasks/widgets/task_dialog_loader.dart';
import 'package:hackathon_economy_app/features/almanac/widgets/almanac_dialog.dart';

import 'package:hackathon_economy_app/core/layout/app_view_size.dart';

// открыть диалог "Задания"
Future<void> openTasks(
  BuildContext context,
  double height,
  double width,
) async {
  try {
    await showDialogWithSound<void>(
      context: context,
      builder: (_) {
        return DialogWithCross(
          screenHeight: height,
          screenWidth: width,
          title: 'Задания',
          content: TasksDialogLoader(key: UniqueKey()),
        );
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Не удалось открыть задания: $e')));
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

    return showDialogWithSound<BuildingType>(
      context: context,
      builder: (context) {
        return DialogWithCross(
          screenHeight: screenHeight,
          screenWidth: screenWight,
          title: 'Магазин',
          content: BuildingShopDialog(
            buildingTypes: types,
            screenHeight: screenHeight,
            screenWight: screenWight,
            playerLevel: userLevel,
          ),
        );
      },
    );
  } catch (e) {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Не удалось загрузить магазин: $e')));
    return null;
  }
}

Future<void> openAlmanac(BuildContext context) async {
  final app = AppViewSize.of(context);

  final targetW = (app.targetW - 12) + 20;
  final targetH = app.targetH;

  await showDialogWithSound<void>(
    context: context,
    builder: (ctx) => DialogWithCross(
      screenHeight: targetH,
      screenWidth: targetW,
      title: 'Альманах',
      content: AlmanacDialog(targetH: targetH, targetW: targetW),
    ),
  );
}
