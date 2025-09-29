part of '../city_map_screen.dart';

const int kMapRows = 32;
const int kMapCols = 32;

// рамка смартфона для web-тестов
const double kPhoneWidth = 414;
const double kPhoneHeight = 660;

// масштаб клетки
double cellSizeMultiplier = 1.0;

int _coins = 0; //заглушка

const double kMapRotationRad = 3.141592653589793 / 4;