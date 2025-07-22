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
    add_running();
  }

  @override
  void initState() {
    super.initState();
    //查询历史运动数据
    query_running();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Running',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 统计卡片概览
          _buildStatisticsCard(),
          // 运动数据列表
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

  // 统计卡片概览
  Widget _buildStatisticsCard() {
    if (runningRecords.isEmpty) return Container();

    double totalDistance =
        runningRecords.fold(0, (sum, data) => sum + data.distance);
    Duration totalTime =
        runningRecords.fold(Duration.zero, (sum, data) => sum + data.duration);
    double avgDistance = totalDistance / runningRecords.length;
    String avgPace = RunningData.calculatePace(totalTime, totalDistance);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '统计概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                    '总次数', '${runningRecords.length}次', Icons.directions_run),
              ),
              Expanded(
                child: _buildStatItem('总距离',
                    '${totalDistance.toStringAsFixed(1)}km', Icons.straighten),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('平均距离',
                    '${avgDistance.toStringAsFixed(1)}km', Icons.timeline),
              ),
              Expanded(
                child: _buildStatItem('平均配速', '$avgPace/km', Icons.speed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue[600]),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 运动数据列表-item
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

  //添加运动数据
  Future<void> add_running() async {
    final url = Uri.parse('http://127.0.0.1:80/runner/add_running.php');

    // 运动时长、距离、卡路里、平均速度、开始时间、结束时间、运动类型、用户id、用户名、密码
    var duration = 23;
    var distance = 3;
    var calories = 80;
    var avg_speed = 6.5;
    //获取当前时间
    var now = DateTime.now();
    var start_time = now.toString();
    var end_time = now.add(Duration(minutes: duration)).toString();
    var type = "running";

    var jsonData = {
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
        body: jsonEncode(jsonData),
      );

      if (response.statusCode == 200) {
        Map result = jsonDecode(response.body);
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('恭喜，添加运动数据成功...')),
          );

          // 刷新列表
          query_running();
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

  // 分钟转Duration
  Duration minutesToDuration(int minutes) {
    return Duration(minutes: minutes);
  }
}
