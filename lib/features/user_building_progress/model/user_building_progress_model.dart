class UserBuildingProgressModel {
  final int idProgress;

  final int idUserBuilding; // p.userBuilding.idUserBuilding
  final int idResourceIn;   // p.resourceIn.idResource
  final int idResourceOut;  // p.resourceOut.idResource

  final int cycleDurationSec; // длительность цикла (сек)
  final double inPerCycle;    // вход за цикл
  final double outPerCycle;   // выход за цикл

  final int totalToProcess; // сколько положили на старте (в циклах)
  final int processedCount; // сколько циклов клиент завершил (сервер клампит)

  final double readyOut;    // накопленный результат
  final DateTime startedAtClient;
  final DateTime startedAtServer;
  final DateTime updatedAt;

  final String state; // running | ready | collected | cancelled

  UserBuildingProgressModel({
    required this.idProgress,
    required this.idUserBuilding,
    required this.idResourceIn,
    required this.idResourceOut,
    required this.cycleDurationSec,
    required this.inPerCycle,
    required this.outPerCycle,
    required this.totalToProcess,
    required this.processedCount,
    required this.readyOut,
    required this.startedAtClient,
    required this.startedAtServer,
    required this.updatedAt,
    required this.state,
  });

  factory UserBuildingProgressModel.fromJson(Map<String, dynamic> json) {
    return UserBuildingProgressModel(
      idProgress: json['idProgress'] ?? json['id'],

      idUserBuilding: json['idUserBuilding'],
      idResourceIn: json['idResourceIn'],
      idResourceOut: json['idResourceOut'],

      cycleDurationSec: json['cycleDurationSec'],
      inPerCycle: (json['inPerCycle'] as num).toDouble(),
      outPerCycle: (json['outPerCycle'] as num).toDouble(),

      totalToProcess: json['totalToProcess'],
      processedCount: json['processedCount'],
      readyOut: (json['readyOut'] as num).toDouble(),

      startedAtClient: DateTime.parse(json['startedAtClient']).toUtc(),
      startedAtServer: DateTime.parse(json['startedAtServer']).toUtc(),
      updatedAt: DateTime.parse(json['updatedAt']).toUtc(),

      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idProgress': idProgress,
    'idUserBuilding': idUserBuilding,
    'idResourceIn': idResourceIn,
    'idResourceOut': idResourceOut,
    'cycleDurationSec': cycleDurationSec,
    'inPerCycle': inPerCycle,
    'outPerCycle': outPerCycle,
    'totalToProcess': totalToProcess,
    'processedCount': processedCount,
    'readyOut': readyOut,
    'startedAtClient': startedAtClient.toUtc().toIso8601String(),
    'startedAtServer': startedAtServer.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'state': state,
  };

  UserBuildingProgressModel copyWith({
    int? processedCount,
    double? readyOut,
    String? state,
    DateTime? updatedAt,
  }) =>
      UserBuildingProgressModel(
        idProgress: idProgress,
        idUserBuilding: idUserBuilding,
        idResourceIn: idResourceIn,
        idResourceOut: idResourceOut,
        cycleDurationSec: cycleDurationSec,
        inPerCycle: inPerCycle,
        outPerCycle: outPerCycle,
        totalToProcess: totalToProcess,
        processedCount: processedCount ?? this.processedCount,
        readyOut: readyOut ?? this.readyOut,
        startedAtClient: startedAtClient,
        startedAtServer: startedAtServer,
        updatedAt: updatedAt ?? this.updatedAt,
        state: state ?? this.state,
      );

  // --- Вспомогательные вычисления для UI ---

  /// Сколько сек прошло от server-start до [nowUtc].
  int elapsedSec(DateTime nowUtc) =>
      nowUtc.difference(startedAtServer).inSeconds.clamp(0, 1 << 31);

  /// Теоретически завершено циклов по времени (без учёта processedCount/totalToProcess).
  int cyclesByTime(DateTime nowUtc) =>
      (elapsedSec(nowUtc) / cycleDurationSec).floor();

  /// Максимально возможные завершённые циклы сейчас (учёт total, времени и уже обработанных).
  int maxProcessableNow(DateTime nowUtc) {
    final byTime = cyclesByTime(nowUtc);
    return (byTime).clamp(0, totalToProcess);
  }

  /// Сколько осталось циклов до полного завершения.
  int remainingCycles(DateTime nowUtc) =>
      (totalToProcess - maxProcessableNow(nowUtc)).clamp(0, totalToProcess);

  /// Прогресс 0..1 для прогрессбара по времени (без учёта ручных сабмитов).
  double timeProgress01(DateTime nowUtc) =>
      (cyclesByTime(nowUtc) / totalToProcess).clamp(0.0, 1.0);

  /// Время в сек до окончания следующего цикла (для таймера).
  int secToNextTick(DateTime nowUtc) {
    final passed = elapsedSec(nowUtc);
    final mod = passed % cycleDurationSec;
    return mod == 0 ? cycleDurationSec : (cycleDurationSec - mod);
  }
}
