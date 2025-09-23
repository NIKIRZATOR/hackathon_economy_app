import 'package:flutter/material.dart';

import '../../building_types/model/building_type_model.dart';
import 'building_type_details_dialog.dart';

class BuildingTypeCard extends StatelessWidget {
  const BuildingTypeCard({
    super.key,
    required this.bt,
    this.width = 140,
    required this.screenHeight,
    required this.screenWight,
  });

  final BuildingType bt;
  final double width;
  final double screenHeight;
  final double screenWight;

  void _openDetails(BuildContext context) async {
    final selected = await showDialog<BuildingType>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BuildingTypeDetailsDialog(bt: bt, screenHeight:screenHeight, screenWight: screenWight,),
    );

    if (selected != null) {
      // закрыть диалог магазина и поднять выбранный тип выше
      Navigator.of(context).pop<BuildingType>(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _openDetails(context),
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black.withValues(alpha: .15)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // заглушка картинки (временно)
                AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Icon(Icons.apartment, size: 36)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bt.titleBuildingType,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Размер: ${bt.wSize}×${bt.hSize}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  '${bt.cost} р',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
