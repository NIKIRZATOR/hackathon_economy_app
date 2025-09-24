import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hackathon_economy_app/features/user/model/user_model.dart';

import '../../building_types/model/building_type_model.dart';

class MockUserModelRepository {
  final String pathToFile;

  const MockUserModelRepository({
    this.pathToFile = 'assets/mock_data/mock_user_model.json',
  });

  Future<UserModel> loadCurrentUserById(int userId) async {
    final raw = await rootBundle.loadString(pathToFile);
    final user = json.decode(raw);
    return user; //TODO доделать вызов
  }
}