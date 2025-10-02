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
      onPressed: () async {
        AudioManager().playSfx('destroy.mp3');
        await _removeBuildingEverywhere(b);
        if (ctx.mounted) Navigator.of(ctx).pop();
      },
      child: const Text('Снести', style: TextStyle(color: Colors.red)),
    ),
    TextButton(
      onPressed: () => Navigator.of(ctx).pop(),
      child: const Text('Закрыть'),
    ),
  ];

  /// распределение диалогов: если для building_type есть inputs — показываем рецепты, иначе — пассив.
  void _openBuildingDialog(Building building) async {
    debugPrint('[tap] building=${building.name} idType=${building.idBuildingType}');

    final inputsByType  = await BtCache.inputsByType();
    final outputsByType = await BtCache.outputsByType();

    final inputs  = inputsByType[building.idBuildingType]  ?? const <BuildingTypeInputModel>[];
    final outputs = outputsByType[building.idBuildingType] ?? const <BuildingTypeOutputModel>[];
    final isRecipe = inputs.isNotEmpty;

    await showDialogWithSound(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(building.name),
        content: isRecipe
            ? RecipeInventoryView(b: building, inputs: inputs, outputs: outputs)
            : PassiveInventoryView(building: building, outputs: outputs),
        actions: _commonActions(ctx, building),
      ),
    );
  }
}
