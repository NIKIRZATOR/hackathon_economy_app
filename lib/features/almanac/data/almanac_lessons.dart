import 'package:flutter/material.dart';

/// Модель одного урока альманаха (строка с кнопкой "Читать")
class AlmanacLesson {
  final String title;
  final String imageAsset; // пока у всех одна картинка

  const AlmanacLesson({
    required this.title,
    this.imageAsset = 'assets/images/almanac/card_mir.png',
  });
}

/// Карта: ГЛАВА (ЛВЛ) -> список уроков
/// Взято из Excel (“Продукт”, “ЛВЛ”) — лист «ФЛ».
const Map<int, List<AlmanacLesson>> kAlmanacLessonsByLevel = {
  1: [
    AlmanacLesson(title: 'Умная дебетовая карта "Мир"'),
    AlmanacLesson(title: 'Премиальная карта Mir Supreme'),
    AlmanacLesson(title: 'Простая кредитная карта'),
  ],
  2: [
    AlmanacLesson(title: 'Дебетовая карта с кэшбэком для самозанятых'),
    AlmanacLesson(title: 'Умная дебетовая карта + мобильная связь со скидкой до 50%'),
    AlmanacLesson(title: 'Кредитная карта с льготным периодом до 120 дней'),
    AlmanacLesson(title: 'Кредитная карта 90 дней'),
  ],
  3: [
    AlmanacLesson(title: 'Кредитная карта 180 дней Премиум'),
  ],
  4: [
    AlmanacLesson(title: 'Дебетовая Пенсионная карта'),
    AlmanacLesson(title: 'Пакет услуг «ГАЗФОНД пенсионные накопления»'),
    AlmanacLesson(title: 'Пенсионная карта Газпромбанка и АО «НПФ ГАЗФОНД»'),
  ],
  5: [
    AlmanacLesson(title: 'Виртуальная дебетовая карта ГПБ&ФК «Зенит»'),
    AlmanacLesson(title: 'Дебетовая карта «Газпромбанк – ФК «Зенит»'),
    AlmanacLesson(title: 'Дебетовая карта хоккейного клуба СКА'),
    AlmanacLesson(title: 'Кредитная карта для самозанятых'),
  ],
  6: [
    AlmanacLesson(title: 'Карта для автолюбителей «Газпромбанк—Газпромнефть»'),
  ],
  7: [
    AlmanacLesson(title: 'Лучшая премиальная карта с программой лояльности «Аэрофлот Бонус»'),
  ],
};

/// Упорядоченный список глав (на всякий случай, если потребуется другая сортировка)
const List<int> kAlmanacLevelsOrder = [1, 2, 3, 4, 5, 6, 7];
