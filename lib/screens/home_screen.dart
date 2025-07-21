import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:runner_sync_app/models/RunningData.dart';
import 'package:runner_sync_app/utils/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  List<RunningData> runningRecords = [];

  //点击 + 按钮
  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    //添加运动数据
    // add_running();
    query_running();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('主页...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 统计卡片
          // _buildStatisticsCard(),
          // 列表
          Expanded(
            child: ListView.builder(
              itemCount: runningRecords.length,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                return _buildRunningCard(runningRecords[index], index);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildRunningCard(RunningData data, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 顶部：序号和时间
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                Text(
                  data.formattedTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 数据行
            Row(
              children: [
                Expanded(
                  child: _buildDataItem(
                      '距离',
                      '${data.distance.toStringAsFixed(2)} km',
                      Icons.straighten,
                      Colors.green),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildDataItem(
                      '耗时', data.formattedDuration, Icons.timer, Colors.orange),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildDataItem(
                      '配速', '${data.pace}/km', Icons.speed, Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  //查询历史运动数据
  Future<void> query_running() async {
    final url = Uri.parse('http://127.0.0.1:80/runner/running_history.php');

    // 获取用户id 和密码
    final user = await DatabaseService().getUser();

    var jsonData = {
      "username": user?.email,
      "password": user?.token,
      "user_id": user?.userId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonData),
      );

      if (response.statusCode == 200) {
        Map result = jsonDecode(response.body);
        List<RunningData> dataList = [];

        if (result['success'] == true) {
          print(result['data']);
          final list = result['data'];
          for (var json in list) {
            // string to datetime
            final startTime = DateTime.parse(json['start_time']);
            // sting to double
            final distance = double.parse(json['distance']);
            // string to duration
            final duration = minutesToDuration(json['duration']);

            final runningData = RunningData(
              time: startTime,
              distance: distance,
              duration: duration!,
              pace: json['avg_speed'],
            );
            dataList.add(runningData);
          }

          setState(() {
            runningRecords = dataList;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('恭喜，查询历史运动数据成功...')),
          );
        } else {
          var msg = result['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('查询历史运动数据失败：$msg')),
          );
        }
      } else {
        print(
            '查询历史运动数据失败-错误：HTTP ${response.body}， code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('查询历史运动运动数据失败')),
        );
      }
    } on Exception catch (e) {
      print('查询历史运动数据失败-错误2：$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('查询历史运动数据失败-错误2')),
      );
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  // 分钟转Duration
  Duration minutesToDuration(int minutes) {
    return Duration(minutes: minutes);
  }
}
