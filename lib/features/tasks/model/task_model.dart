class LevelTask {
  final String id;
  final String title;
  final String type; // build | save_coins | deposit | upgrade | loan | almanac
  final int xp;

  LevelTask({
    required this.id,
    required this.title,
    required this.type,
    required this.xp,
  });

  factory LevelTask.fromJson(Map<String, dynamic> j) =>
      LevelTask(id: j['id'], title: j['title'], type: j['type'], xp: j['xp']);
}

class LevelInfo {
  final int level;
  final int requiredXp;
  final int rewardCoins;
  final List<LevelTask> tasks;

  LevelInfo({
    required this.level,
    required this.requiredXp,
    required this.rewardCoins,
    required this.tasks,
  });

  factory LevelInfo.fromJson(Map<String, dynamic> j) => LevelInfo(
    level: j['level'],
    requiredXp: j['requiredXp'],
    rewardCoins: (j['reward']?['coins'] ?? 0) as int,
    tasks: (j['tasks'] as List).map((t) => LevelTask.fromJson(t)).toList(),
  );
}

class LevelsData {
  final List<LevelInfo> levels;
  LevelsData(this.levels);

  factory LevelsData.fromJson(Map<String, dynamic> j) =>
      LevelsData((j['levels'] as List).map((l) => LevelInfo.fromJson(l)).toList());

  LevelInfo byLevel(int n) =>
      levels.firstWhere((l) => l.level == n, orElse: () => levels.first);
}