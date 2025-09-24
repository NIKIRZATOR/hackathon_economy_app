part of '../city_map_screen.dart';

extension _OpenBuildCardFromMapDialog on _CityMapScreenState {

  /// Диалог сведений о здании + действия: Повернуть/Переместить/Убрать
  void _openBuildingDialog(Building b) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(b.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Уровень', b.level.toString()),
              _infoRow('Размер', '${b.w} × ${b.h}'),
              _infoRow('Позиция', 'x:${b.x}, y:${b.y}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(width: 20, height: 20, color: b.fill),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: b.border),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final origW = b.w, origH = b.h;
                b.rotateTranspose();
                final ok = canPlaceAt(
                  terrain: terrain,
                  buildings: buildings,
                  x: b.x,
                  y: b.y,
                  w: b.w,
                  h: b.h,
                  cols: _CityMapScreenState.cols,
                  rows: _CityMapScreenState.rows,
                  exceptId: b.id,
                );
                if (ok) {
                  doSetState(() => _paintVersion++);
                } else {
                  b.w = origW;
                  b.h = origH;
                  _toast('После поворота не помещается.');
                }
              },
              child: const Text('Повернуть'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                doSetState(() {
                  _moveMode = true;
                  _moveRequestedId = b.id;
                });
                _toast('Режим переноса: перетащите здание и нажмите ✅.');
              },
              child: const Text('Переместить'),
            ),
            TextButton(
              onPressed: () {
                doSetState(() {
                  buildings.removeWhere((e) => e.id == b.id);
                  _paintVersion++;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Убрать', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
}
