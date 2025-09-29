/// Прогресс игрока по заданиям.
/// Поля из ТЗ:
/// - id (int)
/// - внешний ключ на пользователя (userId)
/// - внешний ключ на задание (taskId)
/// - выполнено / не выполнено (completed)
class TaskProgress {
  final int id;
  final int userId;
  final int taskId;
  final bool completed;

  const TaskProgress({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.completed,
  });

  factory TaskProgress.fromJson(Map<String, dynamic> json) => TaskProgress(
    id: json['id_task_progress'] ?? json['id'] ?? 0,
    userId: json['user_id'] ?? json['id_user'] ?? 0,
    taskId: json['task_id'] ?? json['id_task'] ?? 0,
    completed: (json['completed'] ?? json['is_completed'] ?? false) == true,
  );

  Map<String, dynamic> toJson() => {
    'id_task_progress': id,
    'user_id': userId,
    'task_id': taskId,
    'completed': completed,
  };

  /// Удобный копи-метод, если нужно менять флаг completed.
  TaskProgress copyWith({
    int? id,
    int? userId,
    int? taskId,
    bool? completed,
  }) =>
      TaskProgress(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        taskId: taskId ?? this.taskId,
        completed: completed ?? this.completed,
      );
}
