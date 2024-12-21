import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prj3/constant.dart';

class LogModel {
  final String type;
  final String timestamp;
  final String message;

  LogModel({
    required this.type,
    required this.timestamp,
    required this.message,
  });

  // Convert LogModel to JSON (Map<String, dynamic>)
  Map<String, dynamic> toJson() {
    return {
      'type': type,
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
    if (!Hive.isBoxOpen(AppConstants.logs)) {
      var appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
    }

    // Open the box and store logs as a Map
    var logBox = await Hive.openBox<Map<String, dynamic>>(AppConstants.logs);

    // Create the new log entry as a map
    Map<String, dynamic> newLog = {
      'type': logType,
      'timestamp': DateTime.now().toString(),
      'message': message,
    };

    // Add the log entry to the box
    await logBox.add(newLog);

    // Optionally, close the box
    await logBox.close();
  }

  static Future<void> logError(String message) async {
    await addLog(AppConstants.logError, message);
  }

  static Future<void> logInfo(String message) async {
    await addLog(AppConstants.logInfo, message);
  }
}
