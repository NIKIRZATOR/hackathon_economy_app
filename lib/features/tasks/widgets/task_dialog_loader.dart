import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html show window;

import '../../../app/models/user_model.dart';
import '../../../app/repository/auth_repository.dart';
import '../model/task_model.dart';
import '../repo/level_task_repository.dart';
import 'tasks_dialog.dart';

class TasksDialogLoader extends StatelessWidget {
  const TasksDialogLoader({super.key});

  static const _candidates = <String>[
    'flutter.auth_user_json',
    'auth_user_json',
  ];

  Future<_DialogVm> _prepare() async {
    final user = await _readUser();
    final levels = await loadLevels();
    final level = levels.byLevel(user?.userLvl ?? 1);
    return _DialogVm(user: user, level: level);
  }

  Future<UserModel?> _readUser() async {
    // 1 Web localStorage в приоритете
    if (kIsWeb) {
      for (final key in _candidates) {
        final raw = html.window.localStorage[key];
        final u = _parseUser(raw);
        if (u != null) return u;
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in _candidates) {
        final raw = prefs.getString(key);
        final u = _parseUser(raw);
        if (u != null) return u;
      }
    } catch (_) {}

    try {
      final auth = AuthRepository();
      final u = await auth.getSavedUser();
      if (u != null) return u;
    } catch (_) {}

    return null;
  }

  UserModel? _parseUser(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      dynamic v = jsonDecode(raw);
      if (v is String) v = jsonDecode(v);
      if (v is! Map<String, dynamic>) return null;

      final map = v as Map<String, dynamic>;
      final lvl = map['user_lvl'];
      final id  = map['user_id'];
      return UserModel(
        userId: id is int ? id : int.tryParse('$id'),
        username: '${map['username']}',
        cityTitle: map['cityTitle']?.toString(),
        userLvl: (lvl is int) ? lvl : int.tryParse('$lvl') ?? 1,
        userXp: (map['user_xp'] is int) ? map['user_xp'] : int.tryParse('${map['user_xp'] ?? 0}') ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DialogVm>(
      future: _prepare(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const SizedBox.shrink();
        }
        final vm = snap.data!;
        return TasksDialog(level: vm.level, user: vm.user);
      },
    );
  }
}

class _DialogVm {
  final UserModel? user;
  final LevelInfo level;
  const _DialogVm({required this.user, required this.level});
}
