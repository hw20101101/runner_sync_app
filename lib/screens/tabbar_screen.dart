import 'package:flutter/material.dart';
import 'package:runner_sync_app/screens/home_screen.dart';
import 'package:runner_sync_app/screens/mine_screen.dart';

// 底部 Tab 示例

class TabbarScreen extends StatefulWidget {
  @override
  _TabbarScreenState createState() => _TabbarScreenState();
}

class _TabbarScreenState extends State<TabbarScreen> {
  int _currentIndex = 0;

  // tab 页面内容
  final List<Widget> _pages = [
    const HomeScreen(), // 首页页面
    const Center(child: Text('↩︎ 历史记录')),
    MineScreen() // 我的页面
  ];

  final List<BottomNavigationBarItem> _tabItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '首页',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: '历史',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '我的',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Tab 示例')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _tabItems),
    );
  }
}
