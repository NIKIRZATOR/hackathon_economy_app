/// Модель игрового задания.
/// Поля из ТЗ:
/// - id (int)
/// - текст задания (text)
/// - порядковый номер (order)
/// - на каком уровне доступно (unlockLevel)
/// - количество опыта (xp)
class GameTask {
  final int id;
  final String text;
  final int order;
  final int unlockLevel;
  final int xp;

  const GameTask({
    required this.id,
    required this.text,
    required this.order,
    required this.unlockLevel,
    required this.xp,
  });

  /// Основное соответствие snake_case-ключам от сервера.
  factory GameTask.fromJson(Map<String, dynamic> json) => GameTask(
    id: json['id_task'] ?? json['id'] ?? 0,
    text: json['text'] ?? '',
    order: json['order'] ?? json['order_num'] ?? 0,
    unlockLevel: json['unlock_level'] ?? 1,
    xp: json['xp'] ?? json['experience'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id_task': id,
    'text': text,
    'order': order,
    'unlock_level': unlockLevel,
    'xp': xp,
  };

  /// Фабрика под возможные мок-ключи (если отличаются).
  factory GameTask.fromMockJson(Map<String, dynamic> json) => GameTask(
    id: json['id'] ?? json['task_id'] ?? 0,
    text: json['text'] ?? json['title'] ?? '',
    order: json['order'] ?? json['index'] ?? 0,
    unlockLevel: json['unlock_level'] ?? json['level'] ?? 1,
    xp: json['xp'] ?? json['reward_xp'] ?? 0,
  );
}
