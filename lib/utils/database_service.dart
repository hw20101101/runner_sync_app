import 'package:runner_sync_app/models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  User? _user;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  static setUser(User user) {
    _instance._user = user;
  }

  static User? getUser() {
    return _instance._user;
  }
}
