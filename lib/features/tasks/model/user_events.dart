import 'dart:async';

class UserXpLevel {
  final int level;
  final int xp;
  final int required;
  const UserXpLevel(this.level, this.xp, this.required);
}

class UserEvents {
  UserEvents._();
  static final UserEvents I = UserEvents._();

  final _xpLevelCtl = StreamController<UserXpLevel>.broadcast();
  Stream<UserXpLevel> get xpLevelStream => _xpLevelCtl.stream;
  void emitXpLevel(UserXpLevel v) => _xpLevelCtl.add(v);
}
