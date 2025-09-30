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
    
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final t = tasks[index];
          final done = _completed[t.id] ?? false;

          return Container (
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 22, child: Text('${index + 1}.')),
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
            ),
          );
        },
      ),
    );
  }
}
