import 'package:flutter/material.dart';

import '../../city_map/models/building.dart';
import '../model/building_type_output.dart';

class PassiveInventoryView extends StatelessWidget {
  const PassiveInventoryView({
    super.key,
    required this.b,
    required this.outputs,
  });

  final Building b;
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
          'Пассивный доход',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        if (outputs.isEmpty) const Text('— Нет данных по отдаче.'),
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
