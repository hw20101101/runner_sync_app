import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  //点击 + 按钮
  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    //添加运动数据
    add_running();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('主页...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //添加运动数据
  Future<void> add_running() async {
    final url = Uri.parse('http://127.0.0.1:80/runner/add_running.php');

    // 运动时长、距离、卡路里、平均速度、开始时间、结束时间、运动类型、用户id、用户名、密码
    var duration = 100;
    var distance = 1000;
    var calories = 1000;
    var avg_speed = 10;
    var start_time = "2022-01-01 12:00:00";
    var end_time = "2022-01-01 12:10:00";
    var type = "running";

    var json_data = {
      "username": "test",
      "password": "pwd",
      "user_id": "8",
      "duration": duration,
      "distance": distance,
      "calories": calories,
      "avg_speed": avg_speed,
      "start_time": start_time,
      "end_time": end_time,
      "type": type,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(json_data),
      );

      if (response.statusCode == 200) {
        Map result = jsonDecode(response.body);
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('恭喜，添加运动数据成功...')),
          );
        } else {
          var msg = result['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加运动数据失败：$msg')),
          );
        }
      } else {
        print('添加数据失败-错误：HTTP ${response.body}， code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加运动数据失败')),
        );
      }
    } on Exception catch (e) {
      print('添加数据失败-错误2：$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加数据失败-错误2')),
      );
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }
}
