part of '../city_map_screen.dart';

extension _CityMapStateInit on _CityMapScreenState {

  // сброс кэша
  void mapDispose() {
    _tc.dispose();
  }

  /// быстрый snackBar
  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// загрузка PNG в ui.Image
  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image?> _getOrLoadBuildingImage(String? assetPath) async {
    if (assetPath == null) return null;
    if (_imgCache.containsKey(assetPath)) return _imgCache[assetPath];
    try {
      final img = await _loadUiImage(assetPath);
      _imgCache[assetPath] = img;
      return img;
    } catch (_) {
      return null;
    }
  }
}
