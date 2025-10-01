import 'package:flutter/material.dart';
import '../../building_types/model/building_type_model.dart';
import 'building_type_card.dart';
import 'level_lock_overlay.dart';

class BuildingLevelSection extends StatefulWidget {
  const BuildingLevelSection({
    super.key,
    required this.level,
    required this.items,
    required this.screenHeight,
    required this.screenWight,
    this.locked = false,
  });

  final int level;
  final List<BuildingType> items;
  final double screenHeight;
  final double screenWight;
  final bool locked;

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

    final section = Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.background,
      ),
      child: Column(
        children: [
          Text(
            'Уровень ${widget.level}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            )
          ),          
          LayoutBuilder(
            builder: (context, c) {
              final cardW = (c.maxWidth * 0.28).clamp(130, 180).toDouble();
              final row = Row(
                children: [
                  for (final bt in widget.items) ...[
                    BuildingTypeCard(
                      bt: bt,
                      width: cardW,
                      screenHeight: widget.screenHeight,
                      screenWight: widget.screenWight,
                    ),
                  ],
                ],
              );

              return Scrollbar(
                controller: _hCtrl,
                thumbVisibility: true,
                trackVisibility: true,
                notificationPredicate: (_) => true,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                child: AbsorbPointer(
                  absorbing: widget.locked,
                  child: SingleChildScrollView(
                    controller: _hCtrl,
                    scrollDirection: Axis.horizontal,
                    child: row,
                    padding: const EdgeInsets.only(bottom: 10),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    return LevelLockOverlay(
      child: section,
      locked: widget.locked,
      requiredLevel: widget.level,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      onTapLocked: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Доступно с ${widget.level} уровня')),
        );
      },
    );
  }
}
