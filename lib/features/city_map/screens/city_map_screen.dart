// lib/features/city_map/screens/city_map_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_math/vector_math_64.dart' as v_math;

import 'package:hackathon_economy_app/features/top_bar/city_top_bar.dart';
import 'package:hackathon_economy_app/features/bottom_bar/bottom_bar_container.dart';

import '../../building_types/model/building_type_model.dart';
import '../../building_types/repo/mock_building_type_repository.dart';

import '../models/building.dart';
import '../models/drag_preview.dart';
import '../models/user_building.dart';

import '../painters/map_painter.dart';
import '../services/placement_rules.dart';
import '../services/static_city_layout.dart';
import '../services/user_city_storage.dart';

import '../widgets/confirm_button_overlay.dart';

part 'parts/map_state_init.dart';   // init/dispose, загрузка текстур, тосты
part 'parts/map_helpers.dart';      // конвертация координат, утилиты (учёт поворота)
part 'parts/map_dialogs.dart';      // диалог инфо о здании
part 'parts/map_move_drag.dart';    // перенос/drag&drop здания
part 'parts/map_widgets.dart';      // UI: холст карты, кнопка подтверждения

const int kMapRows = 32;
const int kMapCols = 32;

// угол визуального поворота карты: 45° по часовой
const double kMapRotationRad = 3.141592653589793 / 4;

class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key});

  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen> {
  void doSetState(VoidCallback fn) => setState(fn);

  // размеры карты (логические ячейки)
  static const int rows = 32;
  static const int cols = 32;

  // рамка смартфона для web-тестов
  static const double kPhoneWidth = 414;
  static const double kPhoneHeight = 660;

  // состояние карты и зданий
  late List<List<int>> terrain;
  final List<Building> buildings = [];
  final math.Random rng = math.Random(42);

  // масштаб клетки
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

  // текстуры (пример: дорога)
  ui.Image? _roadTex;

  // последний рассчитанный размер клетки (px)
  double? _lastCellSize;

  // ====== Локальное сохранение прогресса пользователя ======
  final _storage = UserCityStorage();
  int _currentUserId = 1; // берём из мока/топ-бара
  String _currentUsername = "alice"; // из mock_user_model.json

  // каталог типов по id (после загрузки из репо)
  final Map<int, BuildingType> _typesById = {};

  // при покупке из магазина — помним «клиентское» id и тип
  // чтобы при подтверждении понять: новая постройка vs перенос существующей
  String? _pendingNewBuildingId;
  BuildingType? _pendingNewBuildingType;

  /// инициализация экрана
  void mapInit() {
    terrain = buildStaticCityGrid(); // статичный 32×32 (0/1/2/3)
    buildings.clear();               // пустая карта (без initialBuildingsFromPlacements)
    _tc.addListener(() => setState(() {}));

    // загрузка примерной текстуры дороги (по желанию)
    _loadUiImage('assets/images/road_gor.png').then((img) {
      if (mounted) setState(() => _roadTex = img);
    });

    // 1) грузим каталог типов → 2) поднимаем сохранённые здания
    _loadTypesThenUserCity();
  }

  Future<void> _loadTypesThenUserCity() async {
    final repo = MockBuildingTypeRepository();
    final types = await repo.loadAll();
    _typesById.clear();
    for (final t in types) {
      _typesById[t.idBuildingType] = t;
    }
    await _loadUserCityFromStorage();

  }

  @override
  void initState() {
    super.initState();
    mapInit();
  }

  @override
  void dispose() {
    mapDispose();
    super.dispose();
  }

  // ====== Persist helpers ======

  // загрузка сохранённых построек
  Future<void> _loadUserCityFromStorage() async {
    final saved = await _storage.load(_currentUserId);
    setState(() {
      for (final ub in saved.where((e) => e.state == 'active')) {
        final bt = _typesById[ub.idBuildingType];
        final w = bt?.wSize ?? 2;
        final h = bt?.hSize ?? 2;
        final name = bt?.titleBuildingType ?? 'Здание #${ub.idUserBuilding}';
        buildings.add(
          Building(
            id: ub.clientId ?? 'ub_${ub.idUserBuilding}',
            name: name,
            level: ub.currentLevel,
            x: ub.x,
            y: ub.y,
            w: w,
            h: h,
            fill: Colors.blue.withValues(alpha: .65),
            border: Colors.blueGrey,
          ),
        );
      }
      _paintVersion++;
    });
  }

  // сохранение новой постройки (после первого подтверждения размещения)
  Future<void> _persistNewBuilding(Building b, BuildingType bt) async {
    final newId = await _storage.nextLocalId(_currentUserId);
    final ub = UserBuilding(
      idUserBuilding: newId,
      idUser: _currentUserId,
      idBuildingType: bt.idBuildingType,
      x: b.x,
      y: b.y,
      currentLevel: b.level,
      state: 'active',
      placedAt: DateTime.now().toUtc(),
      lastUpgradeAt: null,
      clientId: b.id, // связь с отрисованным Building
    );
    await _storage.upsert(_currentUserId, ub);
    print(
        "[$_currentUsername] купил здание "
            "(idType=${bt.idBuildingType}, title=${bt.titleBuildingType}) "
            "по координатам (x=${b.x}, y=${b.y}), lvl=${b.level}"
    );
  }

  // обновление позиции существующего здания
  Future<void> _persistUpdateBuildingPosition(Building b) async {
    await _storage.updatePositionByClientId(_currentUserId, b.id, b.x, b.y);
    print(
        "[$_currentUsername] переместил здание "
            "(clientId=${b.id}, title=${b.name}) "
            "на новые координаты (x=${b.x}, y=${b.y})"
    );
  }

  // ====== Публичный спавн из магазина ======

  void _spawnFromTypeAndEnterMove(BuildingType bt) {
    // размеры из типа
    final int w = bt.wSize.clamp(1, kMapCols);
    final int h = bt.hSize.clamp(1, kMapRows);

    // центр карты (в ячейках)
    final int startX = ((kMapCols - w) / 2).floor().clamp(0, kMapCols - w);
    final int startY = ((kMapRows - h) / 2).floor().clamp(0, kMapRows - h);

    final fill = Colors.blue.withValues(alpha: .65);
    final border = Colors.blueGrey;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final b = Building(
      id: id,
      name: bt.titleBuildingType,
      level: 1,
      x: startX,
      y: startY,
      w: w,
      h: h,
      fill: fill,
      border: border,
    );

    doSetState(() {
      buildings.add(b);
      _paintVersion++;

      _moveMode = true;
      _moveRequestedId = id;

      // помечаем как «новая покупка»
      _pendingNewBuildingId = id;
      _pendingNewBuildingType = bt;

      if (_lastCellSize != null) {
        final cell = _lastCellSize!;
        _dragging = null; // пусть panStart отработает
        _preview = DragPreview(
          Rect.fromLTWH(b.x.toDouble(), b.y.toDouble(), b.w.toDouble(), b.h.toDouble()),
          canPlaceAt(
            terrain: terrain,
            buildings: buildings,
            x: b.x,
            y: b.y,
            w: b.w,
            h: b.h,
            cols: kMapCols,
            rows: kMapRows,
            exceptId: b.id,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // true = реальный телефон, false = web-рамка
    bool isMobile = false;
    final double targetW = isMobile ? media.size.width : kPhoneWidth;
    final double targetH = isMobile ? media.size.height : kPhoneHeight;

    return Center(
      child: SizedBox(
        width: targetW,
        height: targetH,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
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
              CityTopBar(
                userId: _currentUserId,
                userLvl: 2,
                xpCount: 25,
                coinsCount: 100,
                screenHeight: targetH,
                screenWidth: targetW,
              ),

              // холст карты (панорамирование/перенос, overlay)
              Expanded(child: buildMapCanvas()),

              // нижняя панель, магазин возвращает BuildingType => спавним
              CityMapBottomBar(
                height: targetH,
                wight: targetW,
                onBuyBuildingType: _spawnFromTypeAndEnterMove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
