import 'package:flutter/material.dart';
import '../../building_types/model/building_type_model.dart';
import 'building_type_card.dart';

class BuildingLevelSection extends StatelessWidget {
  const BuildingLevelSection({
    super.key,
    required this.level,
    required this.items,
    required this.screenHeight,
    required this.screenWight,
  });

  final int level;
  final List<BuildingType> items;
  final double screenHeight;
  final double screenWight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Уровень $level', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, c) {
              // карточки занимают 28% ширины, диапазон (от 130 до 180)
              final cardW = (c.maxWidth * 0.28).clamp(130, 180).toDouble();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final bt in items) ...[
                      BuildingTypeCard(
                        bt: bt,
                        width: cardW,
                        screenHeight: screenHeight,
                        screenWight: screenWight,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
