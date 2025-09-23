import 'package:flutter/material.dart';
import '../../building_types/model/building_type_model.dart';
import 'building_type_card.dart';

class BuildingLevelSection extends StatefulWidget {
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
  State<BuildingLevelSection> createState() => _BuildingLevelSectionState();
}

class _BuildingLevelSectionState extends State<BuildingLevelSection> {
  late final ScrollController _hCtrl;

  @override
  void initState() {
    super.initState();
    _hCtrl = ScrollController();
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    super.dispose();
  }

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
          Text('Уровень ${widget.level}', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),

          // Горизонтальный скролл с видимым ползунком
          LayoutBuilder(
            builder: (context, c) {
              final cardW = (c.maxWidth * 0.28).clamp(130, 180).toDouble();

              return Scrollbar(
                controller: _hCtrl,
                thumbVisibility: true, // ползунок
                trackVisibility: true, // дорожка
                notificationPredicate: (_) => true, // флаг чтобы уведомления не проходили
                child: SingleChildScrollView(
                  controller: _hCtrl,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final bt in widget.items) ...[
                        BuildingTypeCard(
                          bt: bt,
                          width: cardW,
                          screenHeight: widget.screenHeight,
                          screenWight: widget.screenWight,
                        ),
                        const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}