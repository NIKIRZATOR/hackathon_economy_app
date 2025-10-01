import 'package:flutter/material.dart';

import '../../city_map/models/building.dart';
import '../model/building_type_input.dart';
import '../model/building_type_output.dart';

class RecipeInventoryView extends StatelessWidget {
  const RecipeInventoryView({
    super.key,
    required this.b,
    required this.inputs,
    required this.outputs,
  });

  final Building b;
  final List<BuildingTypeInputModel> inputs;
  final List<BuildingTypeOutputModel> outputs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Уровень', b.level.toString()),
        const SizedBox(height: 8),
        const Text(
          'Входные ресурсы',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        ...inputs.map((i) {
          if (i.consumeMode == 'per_cycle' &&
              i.consumePerCycle != null &&
              i.cycleDuration != null) {
            return Text(
              '• Ресурс #${i.idResource}: -${i.consumePerCycle} за ${i.cycleDuration} сек'
              '${i.bufferForResource != null ? ' (буфер: ${i.bufferForResource})' : ''}',
            );
          }
          if (i.consumeMode == 'per_sec' && i.consumePerSec != null) {
            return Text(
              '• Ресурс #${i.idResource}: -${i.consumePerSec}/сек'
              '${i.amountPerSec != null ? ', +${i.amountPerSec}/сек' : ''}'
              '${i.bufferForResource != null ? ' (буфер: ${i.bufferForResource})' : ''}',
            );
          }
          if (i.consumePerSec != null || i.amountPerSec != null) {
            return Text(
              '• Ресурс #${i.idResource}: '
              '${i.consumePerSec != null ? '-${i.consumePerSec}/сек' : ''}'
              '${(i.consumePerSec != null && i.amountPerSec != null) ? ', ' : ''}'
              '${i.amountPerSec != null ? '+${i.amountPerSec}/сек' : ''}',
            );
          }
          return Text('• Ресурс #${i.idResource}');
        }),
        if (outputs.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Выход (по типу)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          ...outputs.map((o) {
            if (o.produceMode == 'per_sec' && o.producePerSec != null) {
              return Text(
                '• Ресурс #${o.idResource}: +${o.producePerSec}/сек'
                '${o.bufferForResource != null ? ' (буфер: ${o.bufferForResource})' : ''}',
              );
            }
            if (o.produceMode == 'per_cycle' &&
                o.amountPerCycle != null &&
                o.cycleDuration != null) {
              return Text(
                '• Ресурс #${o.idResource}: +${o.amountPerCycle} за ${o.cycleDuration} сек'
                '${o.bufferForResource != null ? ' (буфер: ${o.bufferForResource})' : ''}',
              );
            }
            return Text('• Ресурс #${o.idResource}');
          }),
        ],
        const SizedBox(height: 12),
        const Text('Инвентарь для закладки ресурсов будет здесь.'),
      ],
    );
  }

  // строка ключ-значение в диалоге
  Widget _infoRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(child: Text(v)),
      ],
    ),
  );
}
