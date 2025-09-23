import 'package:flutter/material.dart';
import '../building_types/model/building_type_model.dart';
import '../building_types/repo/mock_building_type_repository.dart';
import '../shop_widget/building_shop_dialog.dart';

void openTasks(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Открыть Задания')));
}

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

void openAlmanac(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Открыть Альманах')));
}
