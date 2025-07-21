// 运动数据模型
class RunningData {
  final DateTime time;
  final double distance; // 公里
  final Duration duration; // 耗时
  final String pace; // 配速 (分钟/公里)

  RunningData({
    required this.time,
    required this.distance,
    required this.duration,
    required this.pace,
  });

  // 计算配速的静态方法
  static String calculatePace(Duration duration, double distance) {
    if (distance <= 0) return "0'00\"";

    int totalSeconds = duration.inSeconds;
    int paceSeconds = (totalSeconds / distance).round();
    int minutes = paceSeconds ~/ 60;
    int seconds = paceSeconds % 60;

    return "${minutes}'${seconds.toString().padLeft(2, '0')}\"";
  }

  String get formattedTime {
    return "${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} "
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String get formattedDuration {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return "${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      return "${minutes}:${seconds.toString().padLeft(2, '0')}";
    }
  }
}
