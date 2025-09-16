part of '../city_map_screen.dart';

extension _CityMapStateInit on _CityMapScreenState {

  /// Освобождение ресурсов
  void mapDispose() {
    _tc.dispose();
  }

  /// Утилита: короткий Toast/SnackBar
  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Загрузка PNG в ui.Image
  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final c = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (img) => c.complete(img));
    return c.future;
  }
}
