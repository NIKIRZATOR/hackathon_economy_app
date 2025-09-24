import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/user_model.dart';

class MockUserModelRepository {
  final String pathToFile;

  const MockUserModelRepository({
    this.pathToFile = 'assets/mock_data/mock_user_model.json',
  });

  Future<UserModel?> loadCurrentUserById(int userId) async {
    final raw = await rootBundle.loadString(pathToFile);
    final List<dynamic> data = json.decode(raw);

    final userJson =
    data.cast<Map<String, dynamic>>().firstWhere((u) => u['user_id'] == userId,
        orElse: () => {});
    if (userJson.isEmpty) return null;

    return UserModel.fromJson(userJson);
  }
}
