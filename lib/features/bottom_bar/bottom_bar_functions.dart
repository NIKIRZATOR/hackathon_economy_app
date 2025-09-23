import 'package:flutter/material.dart';
import '../building_types/repo/mock_building_type_repository.dart';
import '../shop_widget/building_shop_dialog.dart';

void openTasks(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Открыть Задания')));
}

Future<void> openShop(BuildContext context, screenHeight, screenWight) async {
  final repo = MockBuildingTypeRepository();
  try {
    // лоадер
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final types = await repo.loadAll();

    Navigator.of(context).pop();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => BuildingShopDialog(buildingTypes: types, screenHeight:screenHeight, screenWight: screenWight,),
    );
  } catch (e) {
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Не удалось загрузить магазин: $e')),
    );
  }
}

void openAlmanac(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Открыть Альманах')));
}
