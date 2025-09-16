import 'package:flutter/material.dart';
import '../models/building.dart';

/// ==== Каталог типов зданий (словарь) ====
class BuildingDef {
  final String code; // уникальный код каталога
  final String title;
  final int w;
  final int h;
  final Color fill;
  final Color border;

  const BuildingDef({
    required this.code,
    required this.title,
    required this.w,
    required this.h,
    required this.fill,
    required this.border,
  });
}

/// Примерный каталог. Цвета — для наглядности, потом заменишь на фирменные.
const Map<String, BuildingDef> kBuildingCatalog = {
  'city_hall': BuildingDef(
    code: 'city_hall',
    title: 'Мэрия',
    w: 3, h: 3,
    fill: Color(0xFFFFE082), // янтарный
    border: Color(0xFF8D6E63),
  ),
  'residential_2x2': BuildingDef(
    code: 'residential_2x2',
    title: 'Жилой блок 2×2',
    w: 2, h: 2,
    fill: Color(0xFFB3E5FC),
    border: Color(0xFF0277BD),
  ),
  'mall_3x2': BuildingDef(
    code: 'mall_3x2',
    title: 'ТЦ 3×2',
    w: 3, h: 2,
    fill: Color(0xFFC5E1A5),
    border: Color(0xFF558B2F),
  ),
  'office_4x3': BuildingDef(
    code: 'office_4x3',
    title: 'Офисный центр 4×3',
    w: 4, h: 3,
    fill: Color(0xFFD1C4E9),
    border: Color(0xFF5E35B1),
  ),
  'warehouse_3x3': BuildingDef(
    code: 'warehouse_3x3',
    title: 'Склад 3×3',
    w: 3, h: 3,
    fill: Color(0xFFFFCCBC),
    border: Color(0xFFBF360C),
  ),
  'clinic_2x3': BuildingDef(
    code: 'clinic_2x3',
    title: 'Клиника 2×3',
    w: 2, h: 3,
    fill: Color(0xFFDCEDC8),
    border: Color(0xFF33691E),
  ),
  'school_4x2': BuildingDef(
    code: 'school_4x2',
    title: 'Школа 4×2',
    w: 4, h: 2,
    fill: Color(0xFFFFF59D),
    border: Color(0xFFF9A825),
  ),
  'parking_2x2': BuildingDef(
    code: 'parking_2x2',
    title: 'Паркинг 2×2',
    w: 2, h: 2,
    fill: Color(0xFFE0E0E0),
    border: Color(0xFF616161),
  ),
};

/// ==== Размещение на карте ====
class BuildingPlacement {
  final String defCode;
  final int x; // клетка (левая верхняя)
  final int y;
  const BuildingPlacement({required this.defCode, required this.x, required this.y});
}

/// Статические размещения (оставляем как есть). Центр — мэрия.
const List<BuildingPlacement> kStaticPlacements = [
  // Центр
  BuildingPlacement(defCode: 'city_hall', x: 14, y: 14), // 3×3 займёт [14..16]×[14..16]

  // Вдоль центральной горизонтали (дорога по y=15)
  BuildingPlacement(defCode: 'mall_3x2', x: 9,  y: 13),
  BuildingPlacement(defCode: 'residential_2x2', x: 7,  y: 12),
  BuildingPlacement(defCode: 'office_4x3', x: 20, y: 13),
  BuildingPlacement(defCode: 'parking_2x2', x: 25, y: 13),

  // Вдоль центральной вертикали (дорога по x=15)
  BuildingPlacement(defCode: 'clinic_2x3',  x: 13, y: 8),
  BuildingPlacement(defCode: 'school_4x2',  x: 17, y: 9),
  BuildingPlacement(defCode: 'warehouse_3x3', x: 12, y: 20),
  BuildingPlacement(defCode: 'residential_2x2', x: 17, y: 21),

  // Дополнительные кварталы у второстепенных дорог
  BuildingPlacement(defCode: 'residential_2x2', x: 4,  y: 6),
  BuildingPlacement(defCode: 'mall_3x2',       x: 5,  y: 18),
  BuildingPlacement(defCode: 'clinic_2x3',     x: 22, y: 6),
  BuildingPlacement(defCode: 'school_4x2',     x: 24, y: 19),
];

/// ==== Ручной статичный грид 32×32 ====
/// 0 — пусто, 1 — дорога, 2 — "занято зданием" (если решишь отмечать), 3 — вода.
/// Сейчас все нули — заполняй вручную цифрами 1/2/3.
List<List<int>> buildStaticCityGrid() {
  const raw = [
    "00000000000000000000000000000000", //  0
    "00000000000000000000000000000000", //  1
    "00000000000000000000000000000000", //  2
    "00000000000000000000000000000000", //  3
    "00000000000000000000000000000000", //  4
    "00000000000000000000000000000000", //  5
    "00000000000000000000000000000000", //  6
    "00000000000000000000000000000000", //  7
    "00000000000000000000000000000000", //  8
    "00000000000000000000000000000000", //  9
    "00000000000000000000000000000000", // 10
    "00000000000000000000000000000000", // 11
    "00000000000000000000000000000000", // 12
    "00000000000000000000000000000000", // 13
    "00000000000000000000000000000000", // 14
    "00000000000000000000000000000000", // 15
    "11110000000000000000000000001111", // 16
    "00000000000000000000000000000000", // 17
    "00000000000000000000000000000000", // 18
    "00000000000000000000000000000000", // 19
    "00000000000000000000000000000000", // 20
    "00000000000000000000000000000000", // 21
    "00000000000000000000000000000000", // 22
    "00000000000000000000000000000000", // 23
    "00000000000000000000000000000000", // 24
    "00000000000000000000000000000000", // 25
    "00000000000000000000000000000000", // 26
    "00000000000000000000000000000000", // 27
    "00000000000000000000000000000000", // 28
    "00000000000000000000000000000000", // 29
    "00000000000000000000000000000000", // 30
    "00000000000000000000000000000000", // 31
  ];

  return raw.map((line) => line.split('').map(int.parse).toList()).toList();
}

/// ==== Преобразование размещений в реальные Building для отрисовки ====
List<Building> initialBuildingsFromPlacements() {
  final List<Building> out = [];
  int counter = 1;
  for (final p in kStaticPlacements) {
    final def = kBuildingCatalog[p.defCode]!;
    out.add(
      Building(
        id: 'static_${p.defCode}_$counter',
        name: def.title,
        level: 1,
        x: p.x, y: p.y, w: def.w, h: def.h,
        fill: def.fill, border: def.border,
      ),
    );
    counter++;
  }
  // Центр — мэрия
  // final hall = kBuildingCatalog['city_hall']!;
  // out.add(
  //   Building(
  //     id: 'static_city_hall',
  //     name: hall.title,
  //     level: 1,
  //     x: 14, y: 14, w: hall.w, h: hall.h,
  //     fill: hall.fill, border: hall.border,
  //   ),
  // );
  return out;
}
