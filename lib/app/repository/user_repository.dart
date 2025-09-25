import '../services/api_user.dart';
import '../models/user_model.dart';

class UserRepository {
  final _api = ApiUser();

  Future<List<UserModel>> getAllUsers() => _api.getAllUsers();

  Future<UserModel> getUserById(int id) => _api.getUserById(id);

  Future<void> updateUser({
    required int id,
    int? userLvl,
    int? userXp,
    DateTime? lastClaimAt,
  }) => _api.updateUser(
    id: id,
    userLvl: userLvl,
    userXp: userXp,
    lastClaimAt: lastClaimAt,
  );
}
