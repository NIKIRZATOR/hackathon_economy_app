import 'package:flutter/material.dart';

@immutable
class AlmanacAnswer {
  /// Правильный ответ на утверждение (true = «ПРАВДА», false = «ЛОЖЬ»).
  final bool correct;

  /// Пояснение к ответу (берём из Excel, столбец «Пояснение к ответу»).
  final String explanation;

  const AlmanacAnswer({
    required this.correct,
    required this.explanation,
  });
}
