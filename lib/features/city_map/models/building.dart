import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Building {
  String id; // внутренний id для рендера/поиска на карте
  String name;
  int level;
  int x, y; // позиция в ячейках
  int w, h; // размер в ячейках
  Color fill;
  Color border;

  // путь к PNG ассету (assets/images/buildings/bank.png)
  String? imageAsset;

  // декодированная картинка для Canvas
  ui.Image? image;

  int? idUserBuilding; // id из UserCityStorage
  final int? idBuildingType; // тип из BuildingType.idBuildingType
  String? clientId; // UserBuildingModel.clientId

  Building({
    required this.id,
    required this.name,
    required this.level,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.fill,
    required this.border,
    this.imageAsset,
    this.image,
    this.idUserBuilding,
    this.idBuildingType,
    this.clientId,
  });

  // поворот: меняем w/h местами
  void rotateTranspose() {
    final int tmp = w;
    w = h;
    h = tmp;
  }
}
