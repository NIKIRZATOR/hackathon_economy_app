import 'package:flutter/material.dart';

import '../building_types/model/building_type_model.dart';
import 'bottom_bar_functions.dart';

class CityMapBottomBar extends StatelessWidget {
  const CityMapBottomBar({
    super.key,
    required this.height,
    required this.wight,
    required this.onBuyBuildingType,
  });

  final double height;
  final double wight;
  final void Function(BuildingType) onBuyBuildingType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 0.07,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () => openTasks(context),
            child: const Text('Задания'),
          ),
          TextButton(
            onPressed: () async {
              final selected = await openShop(context, height, wight);
              if (selected != null) {
                onBuyBuildingType(selected);
              }
            },
            child: const Text('Магазин'),
          ),
          TextButton(
            onPressed: () => openAlmanac(context),
            child: const Text('Альманах'),
          ),
        ],
      ),
    );
  }
}
