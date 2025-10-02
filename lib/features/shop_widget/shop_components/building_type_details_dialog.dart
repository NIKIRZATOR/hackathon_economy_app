import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';
import 'package:hackathon_economy_app/core/ui/DialogWithCross.dart';
import 'package:hackathon_economy_app/core/ui/MainTextButton.dart';
import '../../building_types/model/building_type_model.dart';

class BuildingTypeDetailsDialog extends StatelessWidget {
  const BuildingTypeDetailsDialog({
    super.key,
    required this.bt,
    required this.screenHeight,
    required this.screenWight,
  });

  final BuildingType bt;
  final double screenHeight;
  final double screenWight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DialogWithCross(
      screenHeight: screenHeight * 0.9,
      screenWidth: screenWight,
      title: bt.titleBuildingType,
      content: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(6, 20, 9, 9),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              children: [
                bt.imageAsset != null
                    ? ClipRect(
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            width: 135,
                            bt.imageAsset!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const Center(child: Icon(Icons.apartment, size: 36)),
                Text(
                  'Размер: ${bt.wSize}×${bt.hSize}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.surface,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 50),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(7),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Производит:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Image.asset(
                              'assets/images/resources/coin.png',
                              width: 50,
                              height: 50,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '35/мин.',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 95),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(7),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Расходует:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Image.asset(
                              'assets/images/resources/product.png',
                              width: 50,
                              height: 50,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '10/час',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: SizedBox(
                    width: 185,
                    child: Text(
                      bt.description!,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.surface,
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
                  child: MainTextButton(
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/resources/coin.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${bt.cost}',
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop<BuildingType>(bt);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
