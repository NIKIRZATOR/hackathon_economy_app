import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hackathon_economy_app/features/bottom_bar/bottom_bar_container.dart';
import 'package:vector_math/vector_math_64.dart' as v_math;

import '../models/building.dart';
import '../models/drag_preview.dart';
import '../painters/map_painter.dart';
import '../services/placement_rules.dart';
import '../services/static_city_layout.dart';
import '../widgets/confirm_button_overlay.dart';

part 'parts/map_state_init.dart'; // init/dispose, загрузка текстур, тосты
part 'parts/map_helpers.dart'; // конвертация координат, утилиты
part 'parts/map_buildings.dart'; // создание/поиск зданий
part 'parts/map_dialogs.dart'; // диалог инфо о здании
part 'parts/map_move_drag.dart'; // перенос/drag&drop здания
part 'parts/map_widgets.dart'; // кусочки UI: тулбар, холст карты, кнопка и т.д.

const int kMapRows = 32;
const int kMapCols = 32;

class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key});

  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen> {
  void doSetState(VoidCallback fn) => setState(fn);

  // размеры карты
  static const int rows = 32;
  static const int cols = 32;

  // рамка смартфона для web-тестов
  static const double kPhoneWidth = 414;
  static const double kPhoneHeight = 660;

  // состояние карты и зданий
  late List<List<int>> terrain;
  final List<Building> buildings = [];
  final Random rng = Random(42);

  //  множитель клетки
  double cellSizeMultiplier = 1.0;

  // камера
  final TransformationController _tc = TransformationController();

  // режим переноса
  bool _moveMode = false;
  String? _moveRequestedId;

  // drag
  Building? _dragging;
  late int _dragOffsetInCellsX;
  late int _dragOffsetInCellsY;
  late int _origX, _origY;
  DragPreview? _preview;

  // перерисовка
  int _paintVersion = 0;

  // текстуры (пока что дорога)
  ui.Image? _roadTex;

  /// инициализация экрана: грузим карту/здания/текстуры, подписываемся на трансформации
  void mapInit() {
    terrain = buildStaticCityGrid(); // статичный 32×32 (0/1/2/3)
    buildings.addAll(initialBuildingsFromPlacements());
    _tc.addListener(() => setState(() {}));

    // загрузка текстуры дороги
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
    final media = MediaQuery.of(context);

    bool isMobile = false; // true = реальный телефон, false = web-рамка
    final double targetW = isMobile ? media.size.width : kPhoneWidth;
    final double targetH = isMobile ? media.size.height : kPhoneHeight;

    return Center(
      child: SizedBox(
        width: targetW,
        height: targetH,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Город Капитала'),
            actions: [
              if (_moveMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Text(
                      'Перенос',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              buildTopToolbar(),
              Expanded(child: buildMapCanvas()),
              CityMapBottomBar(height: targetH, wight: targetW,),
            ],
          ),
        ),
      ),
    );
  }
}
