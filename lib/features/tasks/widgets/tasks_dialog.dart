import 'package:flutter/material.dart';
import '../model/task_model.dart';
import '../model/task_progress_model.dart';

class TasksDialog extends StatefulWidget {
  final List<GameTask> tasks;
  final List<TaskProgress>? progress; // опционально, если есть реальный прогресс

  const TasksDialog({
    super.key,
    required this.tasks,
    this.progress,
  });

  @override
  State<TasksDialog> createState() => _TasksDialogState();
}

class _TasksDialogState extends State<TasksDialog> {
  /// Локальная карта выполненности (taskId -> completed),
  /// чтобы заменить прежнее поле `done` в старой модели.
  late final Map<int, bool> _completed;

  @override
  void initState() {
    super.initState();
    _completed = <int, bool>{};

    // если пришёл прогресс — подставим его
    if (widget.progress != null) {
      for (final p in widget.progress!) {
        _completed[p.taskId] = p.completed;
      }
    }
    // по умолчанию все false
    for (final t in widget.tasks) {
      _completed.putIfAbsent(t.id, () => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = [...widget.tasks]..sort((a, b) => a.order.compareTo(b.order));

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 480),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: Text(
                      'Задания',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(0.35)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 340),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final t = tasks[index];
                          final done = _completed[t.id] ?? false;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 22, child: Text('${index + 1}.')),
                              // ТЕКСТ ЗАДАНИЯ (было: t.title)
                              Expanded(
                                child: Text(
                                  t.text,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: done
                                        ? theme.colorScheme.onSurface.withOpacity(0.6)
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: Checkbox(
                                  value: done,
                                  onChanged: (v) {
                                    setState(() => _completed[t.id] = v ?? false);
                                    // здесь позже можно вызвать репозиторий, чтобы сохранить TaskProgress
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Закрыть',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
