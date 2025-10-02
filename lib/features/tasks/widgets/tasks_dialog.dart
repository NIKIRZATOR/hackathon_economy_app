import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/features/tasks/widgets/task_dialog_loader.dart';

import '../../../app/models/user_model.dart';
import '../model/task_model.dart';
import '../repo/level_task_repository.dart';

import '../repo/read_write_user_level_xp.dart';
import '../repo/task_completion_service.dart';

Future<void> showTasksDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const TasksDialogLoader(),
  );
}

class TasksDialog extends StatefulWidget {
  final LevelInfo level;
  final UserModel? user;

  const TasksDialog({super.key, required this.level, required this.user});

  @override
  State<TasksDialog> createState() => _TasksDialogState();
}

class _TasksDialogState extends State<TasksDialog> {
  Map<String, bool> _completed = {};

  @override
  void initState() {
    super.initState();
    _completed = { for (final t in widget.level.tasks) t.id: false };
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // уже выполненные задачи
    final uLite = await UserService.I.readUserLite();
    if (uLite != null) {
      final done = await TaskCompletionService.I.loadDone(uLite.id);
      setState(() {
        for (final t in widget.level.tasks) {
          _completed[t.id] = done.contains(t.id);
        }
      });
    }

    // пинг в топбар (актуальные level/xp/requiredXp подтянутся из levels_tasks.json)
    await UserService.I.pingXpLevel();
  }

  Future<void> _toggleTask(LevelTask t, bool? value) async {
    // задачи одноразовые — запрещаем снимать галку
    if (value != true) return;

    final uLite = await UserService.I.readUserLite();
    if (uLite == null) return;

    // бизнес-валидация (build/coins и т.д.)
    final ok = await TaskCompletionService.I.canComplete(t, uLite.id);
    if (!ok) {
      // тут можно показать Snackbar/Toast "условие не выполнено"
      return;
    }

    // не начисляем XP повторно
    final done = await TaskCompletionService.I.loadDone(uLite.id);
    if (done.contains(t.id)) {
      setState(() => _completed[t.id] = true);
      return;
    }

    // фиксируем выполнение
    done.add(t.id);
    await TaskCompletionService.I.saveDone(uLite.id, done);
    setState(() => _completed[t.id] = true);

    // начисляем XP (+возможный ап уровня). requiredXp сервис возьмёт сам из levels_tasks.json
    await UserService.I.addXpAndMaybeLevelUp(t.xp);
    // топбар обновится через стрим событий
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.level.tasks;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF76A9F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE4F0FF),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: ScrollConfiguration(
                behavior: const NoScrollbar(),
                child: ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = tasks[index];
                    final done = _completed[t.id] ?? false;
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF9EC1FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${index + 1}.',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              taskTitleForUi(t),
                              style: TextStyle(
                                color: Colors.white,
                                decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 26,
                            height: 26,
                            child: Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: done,
                                onChanged: done ? null : (v) => _toggleTask(t, v),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                side: const BorderSide(color: Colors.white, width: 1.6),
                                checkColor: Colors.white,
                                activeColor: const Color(0xFF6CC070),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Text(
                  'Уровень: ${widget.level.level}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Награда',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              '${widget.level.rewardCoins}',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Image.asset('assets/images/resources/coin.png', width: 16, height: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
