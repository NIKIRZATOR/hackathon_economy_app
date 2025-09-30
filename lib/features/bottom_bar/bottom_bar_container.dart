import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/ui/MainIconButton.dart';

import '../building_types/model/building_type_model.dart';
import 'bottom_bar_functions.dart';

class CityMapBottomBar extends StatelessWidget {
  const CityMapBottomBar({
    super.key,
    required this.height,
    required this.wight,
    required this.onBuyBuildingType,
    required this.userLevel,
  });

  final double height;
  final double wight;
  final int userLevel;
  final void Function(BuildingType) onBuyBuildingType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
    padding: const EdgeInsets.only(bottom: 35, left: 60, right: 60),
      child: SizedBox(
        height: height * 0.09,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MainIconButton(
              icon: Icons.assignment,
              onPressed: () => openTasks(context, height, wight),
            ),
            MainIconButton(
              icon: Icons.shopping_cart,
              onPressed: () async {
                final selected = await openShop(context, height, wight, userLevel);
                if (selected != null) {
                  onBuyBuildingType(selected);
                }
              },
            ),
            MainIconButton(
              icon: Icons.menu_book,
              onPressed: () => openAlmanac(context),
            ),
          ],
        ),
      ),
    );
  }
}
