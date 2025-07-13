import 'package:flutter/material.dart';
import 'package:runner_sync_app/models/user.dart';
import 'package:runner_sync_app/screens/tabbar_screen.dart';
import 'package:runner_sync_app/screens/login_screen.dart';
import 'package:runner_sync_app/utils/database_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StatefulWidget Demo',
      home: CounterPage(),
    );
  }
}

// 创建一个 StatefulWidget
class CounterPage extends StatefulWidget {
  @override
  _CounterPageState createState() => _CounterPageState();
}

// 对应的 State 类
class _CounterPageState extends State<CounterPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser(); // 调用异步函数
  }

  Future<void> _loadUser() async {
    final user = await DatabaseService().getUser();
    setState(() {
      _user = user;
      print('email: ${_user?.email}');

      if (_user == null) {
        // 未登录，显示登录页面
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        // 已登录，显示首页
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => TabbarScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('过渡页面'),
      ),
      body: const Text('过渡页面 ...'),
    );
  }
}
