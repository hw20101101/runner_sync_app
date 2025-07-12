import 'package:runner_sync_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static User? _user;
  static SharedPreferences? _prefs;

  // 私有构造函数
  DatabaseService._internal();

  // 静态私有实例
  static final DatabaseService _instance = DatabaseService._internal();

  // 公共工厂构造函数返回单例
  factory DatabaseService() {
    return _instance;
  }

  // 初始化SharedPreferences
  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  setUser(User user) {
    _user = user;
    initSharedPreferences();
    // 存储用户数据到本地
    _prefs!.setBool('isLogin', true);
    _prefs!.setString('email', user.email);
    _prefs!.setString('token', user.token);
    _prefs!.setInt('userId', user.userId);
  }

  Future<User?> getUser() async {
    await initSharedPreferences();
    // 获取本地的用户数据
    final isLogin = _prefs!.getBool('isLogin') ?? false;
    final email = _prefs!.getString('email') ?? '';
    final token = _prefs!.getString('token') ?? '';
    final userId = _prefs!.getInt('userId') ?? 0;

    if (isLogin) {
      _user = User(email: email, token: token, userId: userId);
    }

    return _user;
  }
}
