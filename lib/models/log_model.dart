import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prj3/constant.dart';

class LogModel {
  final String type;
  final String timestamp;
  final String message;

  LogModel(
      {required this.type, required this.timestamp, required this.message});

  // Convert LogModel to JSON (Map<String, dynamic>)
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'message': message,
    };
  }

  // Convert JSON (Map<String, dynamic>) to LogModel
  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      type: json['type'],
      timestamp: json['timestamp'],
      message: json['message'],
    );
  }

  static Future<void> addLog(String logType, String message) async {
    // Get the directory for storing Hive data
    if (!Hive.isBoxOpen(AppConstants.unreadNotifications)) {
      var appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
    }
    var logBox = await Hive.openBox(AppConstants.logs);
    LogModel newLog = LogModel(
        type: logType, timestamp: DateTime.now().toString(), message: message);
    await logBox.add(newLog);
    await logBox.close();
  }
}
