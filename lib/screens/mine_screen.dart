import 'package:flutter/material.dart';
import 'package:runner_sync_app/screens/login_screen.dart';

class MineScreen extends StatelessWidget {
  // final String avatarUrl = 'https://i.pravatar.cc/150?img=3';
  final String name = '张三';
  final String email = 'zhangsan@example.com';
  final String phone = '123-4567-8901';

  void _logout(BuildContext context) {
    // TODO: 在此处清除登录状态，例如清除 token、用户信息等

    // 模拟跳转到登录页（或欢迎页）
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已退出登录')),
    );

    // 示例跳转逻辑，可根据你的项目结构修改
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Text(name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Divider(height: 32),
            Card(
              child: ListTile(
                leading: Icon(Icons.email),
                title: Text('邮箱'),
                subtitle: Text(email),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text('电话'),
                subtitle: Text(phone),
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
