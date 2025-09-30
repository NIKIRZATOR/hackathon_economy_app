import 'package:flutter/material.dart';
import '../building_types/model/building_type_model.dart';
import 'shop_components/building_level_section.dart';

class BuildingShopDialog extends StatelessWidget {
  const BuildingShopDialog({
    super.key,
    required this.buildingTypes,
    required this.screenHeight,
    required this.screenWight, required this.playerLevel,
  });

  final List<BuildingType> buildingTypes;
  final double screenHeight;
  final double screenWight;
  final int playerLevel;

  @override
  Widget build(BuildContext context) {
    // группировка элементов по unlockLevel

    final levelsMap = <int, List<BuildingType>>{};
    for (final bt in buildingTypes) {
      levelsMap.putIfAbsent(bt.unlockLevel, () => []).add(bt);
    }
    final levels = levelsMap.keys.toList()..sort();

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWight * 0.1,
        vertical: screenHeight * 0.1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: screenWight * 0.9,
        height: screenHeight * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Магазин',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // тело виджета магазин
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  itemCount: levels.length,
                  itemBuilder: (context, i) {
                    final lvl = levels[i];
                    final items = levelsMap[lvl]!
                      ..sort((a, b) => a.cost.compareTo(b.cost));
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
