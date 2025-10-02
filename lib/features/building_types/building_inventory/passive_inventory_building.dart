import 'package:flutter/material.dart';

import '../../city_map/models/building.dart';
import '../model/building_type_output.dart';

class PassiveInventoryView extends StatelessWidget {
  const PassiveInventoryView({
    super.key,
    required this.building,
    required this.outputs,
  });

  final Building building;
  final List<BuildingTypeOutputModel> outputs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Уровень', building.level.toString()),
        const SizedBox(height: 8),
        const Text(
          'Пассивный доход',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        if (outputs.isEmpty) const Text('— Нет данных по отдаче.'),
        ...outputs.map(_lineForOutput),
      ],
    );
  }

  // строка иконка ресурса + доход
  Widget _lineForOutput(BuildingTypeOutputModel o) {
    final Map<String, dynamic>? res = o.resource;

    final String? imagePath = res != null ? res['imagePath'] as String? : null;
    final String label = res != null
        ?
        (res['code'] as String?) ??
        'Ресурс #${o.idResource}'
        : 'Ресурс #${o.idResource}';

    String rightText = '';
    if (o.produceMode == 'per_sec' && o.producePerSec != null) {
      rightText = '+${_fmt(o.producePerSec)}/сек';
    } else if (o.produceMode == 'per_cycle' &&
        o.amountPerCycle != null &&
        o.cycleDuration != null) {
      rightText = '+${_fmt(o.amountPerCycle)} за ${o.cycleDuration} сек';
    }

    final String bufferText =
    (o.bufferForResource != null) ? ' (буфер: ${o.bufferForResource})' : '';

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('• '),

          // иконка + подпись ресурса
          _resourceChip(imagePath, label),

          if (rightText.isNotEmpty) const SizedBox(width: 6),
          if (rightText.isNotEmpty) Text(rightText),

          if (bufferText.isNotEmpty) Text(bufferText),
        ],
      ),
    );
  }

  // компактная иконка ресурса
  Widget _resourceChip(String? imagePath, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imagePath != null && imagePath.isNotEmpty)
          Image.asset(
            imagePath,
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(width: 18, height: 18),
          )
        else
          const SizedBox(width: 18, height: 18),
        const SizedBox(width: 6),
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

  // вывод числа без лишних .0
  String _fmt(num? n) {
    if (n == null) return '';
    if (n is int || n == n.roundToDouble()) return n.toInt().toString();
    return n.toString();
  }
}