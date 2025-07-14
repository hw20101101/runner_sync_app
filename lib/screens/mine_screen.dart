import 'package:flutter/material.dart';
import 'package:runner_sync_app/models/user.dart';
import 'package:runner_sync_app/screens/login_screen.dart';
import 'package:runner_sync_app/utils/database_service.dart';

class MineScreen extends StatefulWidget {
  @override
  _MineScreenState createState() => _MineScreenState();
}

// 对应的 State 类
class _MineScreenState extends State<MineScreen> {
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
      // print('email: ${_user?.email}');
      _user ??= User(email: '未登录', token: '', userId: 0);
    });
  }

  void _logout(BuildContext context) {
    // 弹出退出登录确认框
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认退出登录？'),
          content: const Text('确认退出当前账号，返回登录页面。'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () {
                _logoutAction(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _logoutAction(BuildContext context) {
    //  在此处清除登录状态，例如清除 token、用户信息等
    DatabaseService().setUser(null);

    // 提示退出登录成功
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已退出登录')),
    );

    // 跳转登录页面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _user ??= User(email: '未登录', token: '', userId: 0);
    return Scaffold(
      appBar: AppBar(title: Text('我的')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 显示一个默认头像 icon
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.account_circle),
            ),

            SizedBox(height: 16),
            Text(_user!.email,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Divider(height: 32),
            Card(
              child: ListTile(
                leading: Icon(Icons.email),
                title: Text('邮箱'),
                subtitle: Text(_user!.email),
              ),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: Icon(Icons.logout),
              label: Text('退出登录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
