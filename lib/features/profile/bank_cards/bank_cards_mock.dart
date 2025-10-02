import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/theme/colors.dart';

class BankCardInfo {
  final int id;
  final int requiredLevel;
  final String title;
  final double cashbackRate;
  final Color backgroundColor;
  final Color textColor;
  final Color infoColor;
  final List<String> features;
  final String resourceIcon;
  final String? bgIcon;

  const BankCardInfo({
    required this.id,
    required this.requiredLevel,
    required this.title,
    required this.cashbackRate,
    required this.backgroundColor,
    required this.textColor,
    required this.infoColor,
    required this.features,
    required this.resourceIcon,
    this.bgIcon,
  });
}

final List<BankCardInfo> mockCards = [
  BankCardInfo(
    id: 1,
    requiredLevel: 1,
    title: 'Умная дебетовая карта Мир',
    cashbackRate: 5,
    backgroundColor: AppColors.violet,
    textColor: AppColors.white,
    infoColor: AppColors.orange,
    resourceIcon: 'assets/images/resources/product.png',
    bgIcon: 'assets/images/svg/mir_car_bg.svg',
    features: [
      'Переводы без комиссии',
      'Бесплатное снятие наличных',
      'До 20% кэшбэк у партнеров',
      'Оплата смартфоном с Gazprom Pay',
      'Оплата услуг ЖКХ без комиссии',
      'Сервис «Антиспам»',
    ],
  ),
  BankCardInfo(
    id: 2,
    requiredLevel: 2,
    title: 'Карта для автолюбителей Газпромбанк—Газпромнефть',
    cashbackRate: 10,
    backgroundColor: AppColors.white,
    textColor: AppColors.violet,
    infoColor: AppColors.violet,
    resourceIcon: 'assets/images/resources/fuel.png',
    bgIcon: 'assets/images/svg/gazpromneft_card_bg.svg',
    features: [
      'Бонусы за каждые 100 ₽: 5 бонусов на АЗС «Газпромнефть» и 1,5 вне АЗС',
      'Золотой статус «Нам по пути»',
      '+100 бонусов при первой заправке и +50 каждые 3 мес. при 50 л/мес.',
    ],
  ),
  BankCardInfo(
    id: 3,
    requiredLevel: 3,
    title: 'Премиальная карта Mir Supreme',
    cashbackRate: 15,
    backgroundColor: AppColors.black,
    textColor: AppColors.white,
    infoColor: AppColors.mint,
    resourceIcon: 'assets/images/resources/coffee_beans.png',
    bgIcon: 'assets/images/svg/sumpere_card_bg.svg',
    features: [
      '2 программы привилегий: Спорт, Путешествия',
      'Бесплатное обслуживание',
      'Бесплатное снятие наличных',
      'Скидки и предложения от ПС «Мир»',
      'Счета в валюте без комиссии',
      'Кэшбэк 10% за первые 3 поездки Ultima (Яндекс Go)',
      'Кэшбэк 5% за билеты на vamprivet.ru',
      'Кэшбэк 7% в ресторанах-партнёрах',
      'Кэшбэк до 30% от партнёров',
      'Платёжный стикер',
    ],
  ),
];