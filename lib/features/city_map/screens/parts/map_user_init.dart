part of '../city_map_screen.dart';

UserModel? _user;
final _authRepo = AuthRepository();

int get _userId => _user?.userId ?? 0;
String get _username => _user?.username ?? '—';


// Сравнение важнейших полей (id, lvl, xp, cityTitle, username)
bool _sameUserCore(UserModel? a, UserModel b) {
  if (a == null) return false;
  return (a.userId == b.userId) &&
      (a.username == b.username) &&
      (a.userLvl == b.userLvl) &&
      (a.userXp == b.userXp) &&
      ((a.cityTitle ?? '') == (b.cityTitle ?? '')) &&
      _sameDateTime(a.lastClaimAt, b.lastClaimAt);
}

bool _sameDateTime(DateTime? x, DateTime? y) {
  if (x == null && y == null) return true;
  if (x == null || y == null) return false;
  return x.toUtc().millisecondsSinceEpoch == y.toUtc().millisecondsSinceEpoch;
}

// микрофункция, чтобы не ловить warning "unawaited futures"
void unawaited(Future<void> f) {}