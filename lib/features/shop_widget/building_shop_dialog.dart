import 'package:flutter/material.dart';
import '../building_types/model/building_type_model.dart';
import '../tasks/model/user_events.dart';
import 'shop_components/building_level_section.dart';

class BuildingShopDialog extends StatelessWidget {
  const BuildingShopDialog({
    super.key,
    required this.buildingTypes,
    required this.screenHeight,
    required this.screenWight,
    required this.playerLevel,        // стартовый уровень
    this.xpLevelStream,               // НОВОЕ: стрим текущего уровня
  });

  final List<BuildingType> buildingTypes;
  final double screenHeight;
  final double screenWight;
  final int playerLevel;
  final Stream<UserXpLevel>? xpLevelStream;

  @override
  Widget build(BuildContext context) {
    final levelsMap = <int, List<BuildingType>>{};
    for (final bt in buildingTypes) {
      levelsMap.putIfAbsent(bt.unlockLevel, () => []).add(bt);
    }
    final levels = levelsMap.keys.toList()..sort();

    Widget buildList(int lvlNow) {
      return SizedBox(
        height: screenHeight * 0.7 - 4,
        child: ListView.separated(
          itemCount: levels.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final lvl = levels[i];
            final items = [...levelsMap[lvl]!]..sort((a, b) => a.cost.compareTo(b.cost));
            final locked = lvlNow < lvl;

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

    // если стрима нет — рисуем по стартовому уровню
    if (xpLevelStream == null) return buildList(playerLevel);

    return StreamBuilder<UserXpLevel>(
      stream: xpLevelStream,
      initialData: UserXpLevel(playerLevel, 0, 0),
      builder: (context, snap) {
        final lvlNow = snap.data?.level ?? playerLevel;
        return buildList(lvlNow);
      },
    );
  }
}
