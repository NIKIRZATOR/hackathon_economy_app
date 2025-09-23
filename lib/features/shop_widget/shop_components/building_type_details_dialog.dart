import 'package:flutter/material.dart';

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
    final w = (screenWight * 0.6).clamp(360, 720).toDouble();
    final h = (screenHeight * 0.5).clamp(280, 560).toDouble();

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: (screenWight - w) / 2,
        vertical: (screenHeight - h) / 2,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: w,
        height: h,
        child: Column(
          children: [
            // заголовок
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      bt.titleBuildingType,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
            // контент
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // слева картинка-заглушка
                    Expanded(
                      flex: 3,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: .1),
                            ),
                          ),
                          child: const Center(child: Text('PNG здания')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // справа описание + кнопка
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: DefaultTextStyle(
                                style: Theme.of(context).textTheme.bodyMedium!,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((bt.description ?? '').isNotEmpty)
                                      Text(bt.description!)
                                    else
                                      Text(
                                        'Размер: ${bt.wSize}×${bt.hSize}\n'
                                        'Макс. апгрейд: ${bt.maxUpgradeLvl}\n'
                                        'Открывается на уровне: ${bt.unlockLevel}\n'
                                        'Стоимость: ${bt.cost} р',
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 40,
                            child: FilledButton(
                              onPressed: () {
                                // позже сюда вставите логику покупки/постройки
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Купить «${bt.titleBuildingType}» за ${bt.cost} р',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Купить'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
