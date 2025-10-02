import 'package:flutter/material.dart';
import '../building_types/model/building_type_model.dart';
import 'shop_components/building_level_section.dart';

class BuildingShopDialog extends StatelessWidget {
  const BuildingShopDialog({
    super.key,
    required this.buildingTypes,
    required this.screenHeight,
    required this.screenWight,
    required this.playerLevel,
  });

  final List<BuildingType> buildingTypes;
  final double screenHeight;
  final double screenWight;
  final int playerLevel;

  @override
  Widget build(BuildContext context) {

    final levelsMap = <int, List<BuildingType>>{};
    for (final bt in buildingTypes) {
      levelsMap.putIfAbsent(bt.unlockLevel, () => []).add(bt);
    }
    final levels = levelsMap.keys.toList()..sort();
    return SizedBox(
      height: screenHeight * 0.7 - 4,
      child: ListView.separated(
        itemCount: levels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final lvl = levels[i];
          final items = [...levelsMap[lvl]!]..sort((a, b) => a.cost.compareTo(b.cost));
          final locked = playerLevel < lvl;

          return BuildingLevelSection(
            level: lvl,
            items: items,
            screenHeight: screenHeight,
            screenWight: screenWight,
            locked: locked,
          );
        },
      ),
    );
  }
}
