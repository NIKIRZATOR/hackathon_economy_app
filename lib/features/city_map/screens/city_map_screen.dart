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
import 'package:hackathon_economy_app/core/utils/show_dialog_with_sound.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';

import '../../../app/repository/auth_repository.dart';
import '../../building_types/model/building_type_model.dart';
import '../../building_types/repo/mock_building_type_repository.dart';

import '../../../app/models/user_model.dart';
import '../models/building.dart';
import '../models/drag_preview.dart';
import '../models/user_building.dart';

import '../painters/map_painter.dart';
import '../services/placement_rules.dart';
import '../services/static_city_layout.dart';
import '../services/user_city_storage.dart';

part 'parts/map_constants.dart';
part 'parts/map_user_init.dart';
part 'parts/map_types_catalog.dart'; // каталог типов
part 'parts/map_persist.dart'; // загрузка/сохранение/обновление
part 'parts/map_spawn_build_from_shop.dart'; // спавн здания из магазина и предпросмотр
part 'parts/map_state_init.dart'; // init/dispose, _toast, _loadUiImage, listen камеры
part 'parts/map_helpers.dart'; // координаты, confirm button pos, публичный spawn
part 'parts/map_dialogs.dart'; // диалог инфо по зданию
part 'parts/map_move_drag.dart'; // перенос/drag&drop
part 'parts/map_widgets.dart'; // UI холста карты и overlay
part 'parts/open_build_from_map_dialog.dart'; // диалог интерфейса здания на карте

class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key, this.incomingUser});

  final UserModel? incomingUser;

  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen>
    with WidgetsBindingObserver {
  void doSetState(VoidCallback fn) => setState(fn);

  // размеры карты (логические ячейки)
  static const int rows = 32;
  static const int cols = 32;

  // состояние карты и зданий
  late List<List<int>> terrain;
  final List<Building> buildings = [];
  final math.Random rng = math.Random(42);

  // камера
  final TransformationController _tc = TransformationController();

  // текстуры (пример: дорога)
  ui.Image? _roadTex;

  // кэш ui.Image по asset path
  final Map<String, ui.Image> _imgCache = {};

  // загрузить ui.Image из ассета с кэшем
  Future<ui.Image?> _getOrLoadBuildingImage(String? assetPath) async {
    if (assetPath == null) return null;
    final cached = _imgCache[assetPath];
    if (cached != null) return cached;
    try {
      final img = await _loadUiImage(assetPath); // из map_state_init.dart
      _imgCache[assetPath] = img;
      return img;
    } catch (_) {
      return null;
    }
  }

  // каталог типов по id (после загрузки из репо)
  final Map<int, BuildingType> _typesById = {};

  /// инициализация экрана
  void mapInit() {
    terrain = buildStaticCityGrid(); // статичный 32×32 (0/1/2/3)
    buildings.clear();
    _tc.addListener(() => setState(() {}));

    // пример текстуры дороги
    _loadUiImage('assets/images/road_gor.png').then((img) {
      if (mounted) setState(() => _roadTex = img);
    });

    // 1-грузим каталог типов 2-поднимаем сохранённые здания
    _loadTypesThenUserCity();
  }

  Future<void> _initUser() async {
    final cached = await _authRepo.getSavedUser();
    final incoming = widget.incomingUser;

    UserModel? effective;

    if (incoming == null) {
      // нет авторизованного — используем кеш, если есть
      effective = cached;
    } else {
      if (!_sameUserCore(cached, incoming)) {
        // Отличается — перезапишем кеш актуальными данными
        await _authRepo.saveUser(incoming);
        effective = await _authRepo.getSavedUser();
      } else {
        // Совпадает — оставляем кеш
        effective = cached ?? incoming;
      }
    }
    setState(() => _user = effective);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioManager().setMusicVolume(0.3);
    AudioManager().playMusic('background.mp3');
    mapInit();
    _initUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mapDispose(); // в part: слушатели, чистка
    AudioManager().stopMusic();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioManager().pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      AudioManager().resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // true = реальный телефон, false = web-рамка
    bool isMobile = false;
    final double targetW = isMobile ? media.size.width : kPhoneWidth;
    final double targetH = isMobile ? media.size.height : kPhoneHeight;

    // значения для топ-бара из local_storage
    // если его ещё нет — подставим безопасные дефолты
    final userId = _user?.userId ?? 0;
    final userLvl = _user?.userLvl ?? 1;
    final xpCount = _user?.userXp ?? 0;
    final cityName = _user?.cityTitle ?? '—';

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
                userId: userId,
                userLvl: userLvl,
                xpCount: xpCount,
                coinsCount: _coins,
                cityTitle: cityName,
                screenHeight: targetH,
                screenWidth: targetW,
              ),
              // карта
              Expanded(child: buildMapCanvas()),
              // магазин | возвращает BuildingType -> строим здание
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
