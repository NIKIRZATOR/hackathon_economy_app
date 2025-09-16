import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_math/vector_math_64.dart' as v_math;

import '../models/building.dart';
import '../models/drag_preview.dart';
import '../painters/map_painter.dart';
import '../services/placement_rules.dart';
import '../services/static_city_layout.dart';
import '../widgets/confirm_button_overlay.dart';



// ==== подкл. частей (parts) — см. соседние файлы ====
part 'parts/map_state_init.dart';     // init/dispose, загрузка текстур, тосты
part 'parts/map_helpers.dart';        // конвертация координат, утилиты
part 'parts/map_buildings.dart';      // создание/поиск зданий
part 'parts/map_dialogs.dart';        // диалог инфо о здании
part 'parts/map_move_drag.dart';      // перенос/drag&drop здания
part 'parts/map_widgets.dart';        // кусочки UI: тулбар, холст карты, кнопка ✅ и т.д.


const int kMapRows = 32;
const int kMapCols = 32;

/// Экран единой карты 32×32
class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key});
  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen> {

  /// Безопасный прокси, чтобы не ловить warning 'setState is protected' в extensions
  void doSetState(VoidCallback fn) => setState(fn);

  // --- размеры карты ---
  static const int rows = 32;
  static const int cols = 32;

  // --- состояние карты и зданий ---
  late List<List<int>> terrain;
  final List<Building> buildings = [];
  final Random rng = Random(42);

  // --- камера/зум ---
  double cellScale = 1.0;
  final TransformationController _tc = TransformationController();

  // --- режим переноса ---
  bool _moveMode = false;
  String? _moveRequestedId;

  // --- drag ---
  Building? _dragging;
  late int _dragOffsetInCellsX;
  late int _dragOffsetInCellsY;
  late int _origX, _origY;
  DragPreview? _preview;

  // --- перерисовка ---
  int _paintVersion = 0;

  // --- текстуры (пример: дорога) ---
  ui.Image? _roadTex;

  /// Инициализация экрана: грузим карту/здания/текстуры, подписываемся на трансформации
  void mapInit() {
    terrain = buildStaticCityGrid();                    // статичный 32×32 (0/1/2/3)
    buildings.addAll(initialBuildingsFromPlacements()); // словарь → размещения
    _tc.addListener(() => setState(() {}));

    // Загрузка текстуры дороги (путь из pubspec.yaml)
    _loadUiImage('assets/images/road_gor.png').then((img) {
      if (mounted) setState(() => _roadTex = img);
    });
  }

  @override
  void initState() {
    super.initState();
    mapInit(); // см. part: map_state_init.dart
  }

  @override
  void dispose() {
    mapDispose(); // см. part
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // размеры «холста» (контейнер 80% высоты экрана)
    final screen = MediaQuery.of(context).size;
    final mapHeightTarget = screen.height * 0.8;
    final baseCell = min(screen.width / cols, mapHeightTarget / rows);
    final cellSize = baseCell * cellScale;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Единая карта 32×32 — drag & pan'),
        actions: [
          if (_moveMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text('Режим переноса',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          buildTopToolbar(cellSize),           // см. part: map_widgets.dart
          Expanded(child: buildMapCanvas(cellSize)), // см. part
        ],
      ),
    );
  }
}
