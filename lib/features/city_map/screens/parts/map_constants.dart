part of '../city_map_screen.dart';

const int kMapRows = 32;
const int kMapCols = 32;

// масштаб клетки
double cellSizeMultiplier = 1.0;

int _coins = 0; //заглушка

int _requiredXpUi = 9999; // значение до загрузки уровней
int _playerLevel = 1;

const double kMapRotationRad = 3.141592653589793 / 4;