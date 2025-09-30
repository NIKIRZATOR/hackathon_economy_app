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

// ▼ туториал
import 'package:hackathon_economy_app/features/tutorial/widgets/tutorial_overlay.dart';
import 'package:hackathon_economy_app/features/tutorial/model/tutorial_step.dart';
import 'package:hackathon_economy_app/features/bottom_bar/bottom_bar_functions.dart';

import '../../../app/repository/auth_repository.dart';
import '../../building_types/model/building_type_model.dart';
import '../../building_types/repo/building_type_repository.dart';

import '../../../app/models/user_model.dart';
import '../../shop_widget/services/purchase_service.dart';
import '../../user_buildings/repository/user_building_repository.dart';
import '../../user_resource/model/user_resource_model.dart';
import '../../user_resource/repo/user_resource_repository.dart';
import '../models/building.dart';
import '../models/drag_preview.dart';
import '../../user_buildings/model/user_building.dart';

import '../painters/map_painter.dart';
import '../services/placement_rules.dart';
import '../services/static_city_layout.dart';
import '../services/user_city_storage.dart';
import '../services/user_inventory_storage.dart';

part 'parts/map_constants.dart';
part 'parts/map_user_init.dart';
part 'parts/map_types_catalog.dart';
part 'parts/map_persist.dart';
part 'parts/map_spawn_build_from_shop.dart';
part 'parts/map_state_init.dart';
part 'parts/map_helpers.dart';
part 'parts/map_dialogs.dart';
part 'parts/map_move_drag.dart';
part 'parts/map_widgets.dart';
part 'parts/open_build_from_map_dialog.dart';

class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key, this.incomingUser});

  final UserModel? incomingUser;

  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen>
    with WidgetsBindingObserver {
  void doSetState(VoidCallback fn) => setState(fn);

  final _purchase = PurchaseService(
    inventory: UserInventoryStorage(),
    city: UserCityStorage(),
  );

  static const int rows = 32;
  static const int cols = 32;

  late List<List<int>> terrain;
  final List<Building> buildings = [];
  final math.Random rng = math.Random(42);

  final TransformationController _tc = TransformationController();

  ui.Image? _roadTex;
  ui.Image? _grassTex;

  final Map<String, ui.Image> _imgCache = {};

  Future<ui.Image?> _getOrLoadBuildingImage(String? assetPath) async {
    if (assetPath == null) return null;
    final cached = _imgCache[assetPath];
    if (cached != null) return cached;
    try {
      final img = await _loadUiImage(assetPath);
      _imgCache[assetPath] = img;
      return img;
    } catch (_) {
      return null;
    }
  }

  final Map<int, BuildingType> _typesById = {};

  final _resRepo = UserResourceRepository();
  List<UserResource> _inventory = [];

  Future<void> _loadInventory(int userId) async {
    try {
      _inventory = await _resRepo.syncFromServerAndCache(userId);
    } catch (_) {
      _inventory = await _resRepo.loadFromCache(userId);
    }

    final coins = _inventory
        .firstWhere(
          (e) => e.resource.code == 'coins',
      orElse: () => UserResource(
        idUserResource: -1,
        userId: userId,
        amount: 0,
        resource: _inventory.isEmpty
            ? _inventory.first.resource
            : _inventory.first.resource,
      ),
    )
        .amount;

    if (mounted) setState(() => _coins = coins.toInt());
  }

  /// ───── Туториал ─────
  final GlobalKey _shopBtnKey = GlobalKey();
  final GlobalKey<TutorialOverlayState> _tutorialKey =
  GlobalKey<TutorialOverlayState>(); // ← ключ состояния
  bool _showTutorial = true;
  OverlayEntry? _tutorialEntry;
  TutorialOverlay? _tutorialWidget;
  List<TutorialStep> _steps = const [];
  Rect? _shopRect;

  void _startTutorial() {
    _steps = const [
      TutorialStep(
        id: 'hello',
        text: 'Привет! Я Миша. Добро пожаловать в Город Капитала!',
        mishaAsset: 'assets/images/Misha/Misha_smile.png',
      ),
      TutorialStep(
        id: 'open_shop',
        text: 'Давай начнём со строительства. Открой, пожалуйста, Магазин!',
        mishaAsset: 'assets/images/Misha/Misha_points.png',
        waitsUserTap: true,
        action: 'open_shop',
      ),
      TutorialStep(
        id: 'place_building',
        text:
        'Отлично! Выбери здание и поставь его на карту. Подтверди зелёной галочкой.',
        mishaAsset: 'assets/images/Misha/Misha_like.png',
        waitsUserTap: true,
        action: 'place_building',
      ),
      TutorialStep(
        id: 'done',
        text: 'Готово! Ты умеешь строить. Дальше разберёмся вместе!',
        mishaAsset: 'assets/images/Misha/Misha_happy.png',
      ),
    ];

    final rb = _shopBtnKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb != null) {
      final offset = rb.localToGlobal(Offset.zero);
      _shopRect =
          Rect.fromLTWH(offset.dx, offset.dy, rb.size.width, rb.size.height);
    }

    _showTutorialOverlay();
  }

  void _showTutorialOverlay() {
    _removeTutorialOverlay();

    _tutorialWidget = TutorialOverlay(
      key: _tutorialKey,
      steps: _steps,
      highlightRect: _shopRect, // оставляем подсветку
      onAction: (action) async {
      },
      onFinished: () {
        setState(() => _showTutorial = false);
        _removeTutorialOverlay();
      },
    );


    _tutorialEntry = OverlayEntry(builder: (_) => _tutorialWidget!);
    Overlay.of(context, rootOverlay: true).insert(_tutorialEntry!);
  }

  void _removeTutorialOverlay() {
    _tutorialEntry?.remove();
    _tutorialEntry = null;
  }

  /// инициализация экрана
  void mapInit() {
    terrain = buildStaticCityGrid();
    buildings.clear();
    _tc.addListener(() => setState(() {}));

    _loadUiImage('assets/images/road_gor.png').then((img) {
      if (mounted) setState(() => _roadTex = img);
    });

    _loadUiImage('assets/images/grass_32.png').then((img) {
      if (mounted) setState(() => _grassTex = img);
    });

    _loadTypesThenUserCity();
  }

  Future<void> _initUser() async {
    final cached = await _authRepo.getSavedUser();
    final incoming = widget.incomingUser;

    UserModel? effective;

    if (incoming == null) {
      effective = cached;
    } else {
      if (!_sameUserCore(cached, incoming)) {
        await _authRepo.saveUser(incoming);
        effective = await _authRepo.getSavedUser();
      } else {
        effective = cached ?? incoming;
      }
    }
    setState(() => _user = effective);

    final uid = _user?.userId;
    if (uid != null) {
      await _loadInventory(uid);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioManager().setMusicVolume(0.3);
    AudioManager().playMusic('background.mp3');
    mapInit();
    _initUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showTutorial) _startTutorial();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mapDispose();
    _removeTutorialOverlay();
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

    bool isMobile = false;
    final double targetW = isMobile ? media.size.width : kPhoneWidth;
    final double targetH = isMobile ? media.size.height : kPhoneHeight;

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
                user: _user,
                userId: userId,
                userLvl: userLvl,
                xpCount: xpCount,
                coinsCount: _coins,
                cityTitle: cityName,
                screenHeight: targetH,
                screenWidth: targetW,
              ),
              Expanded(child: buildMapCanvas()),
              CityMapBottomBar(
                height: targetH,
                wight: targetW,
                onBuyBuildingType: (type) {
                  _spawnFromTypeAndEnterMove(type);
                  // если диалог ещё не закрыт — на всякий случай продвинем (после выбора здания)
                  _tutorialKey.currentState?.completeCurrentAction();
                },
                shopButtonKey: _shopBtnKey,
                onShopPressed: () {
                  // как только игрок нажал на кнопку — закрываем диалог шага "open_shop"
                  _tutorialKey.currentState?.completeCurrentAction();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
