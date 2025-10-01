part of '../city_map_screen.dart';

extension _OpenBuildCardFromMapDialog on _CityMapScreenState {
  List<Widget> _commonActions(BuildContext ctx, Building b) => [
    TextButton(
      onPressed: () {
        Navigator.of(ctx).pop();
        doSetState(() {
          _moveMode = true;
          _moveRequestedId = b.id;
        });
        _toast('Режим переноса');
      },
      child: const Text('Переместить'),
    ),
    TextButton(
      onPressed: () {
        AudioManager().playSfx('destroy.mp3');
        doSetState(() {
          buildings.removeWhere((e) => e.id == b.id);
          _paintVersion++;
        });
        Navigator.of(ctx).pop();
      },
      child: const Text('Снести', style: TextStyle(color: Colors.red)),
    ),
    TextButton(
      onPressed: () => Navigator.of(ctx).pop(),
      child: const Text('Закрыть'),
    ),
  ];

  /// распределение диалогов: если для building_type есть inputs — показываем рецепты, иначе — пассив.
  void _openBuildingDialog(Building b) async {
    debugPrint('[tap] building=${b.name} idType=${b.idBuildingType}');

    final inputsByType  = await BtCache.inputsByType();
    final outputsByType = await BtCache.outputsByType();

    final inputs  = inputsByType[b.idBuildingType]  ?? const <BuildingTypeInputModel>[];
    final outputs = outputsByType[b.idBuildingType] ?? const <BuildingTypeOutputModel>[];
    final isRecipe = inputs.isNotEmpty;

    await showDialogWithSound(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(b.name),
        content: isRecipe
            ? RecipeInventoryView(b: b, inputs: inputs, outputs: outputs)
            : PassiveInventoryView(b: b, outputs: outputs),
        actions: _commonActions(ctx, b),
      ),
    );
  }
}
