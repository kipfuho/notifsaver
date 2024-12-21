import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prj3/constant.dart';
import 'package:prj3/google_service.dart';
import 'package:prj3/models/log_model.dart';
import 'package:workmanager/workmanager.dart';
import 'package:prj3/platform_channel.dart';
import 'dart:convert';

Future<void> saveNotification() async {
  // Call Android to retrieve unprocessed notifications
  final List<dynamic> unprocessedNotifications =
      await PlatformChannels.getUnprocessedNotificationsFromTempStorage();

  // Get the directory for storing Hive data
  if (!Hive.isBoxOpen(AppConstants.getHiveBoxName())) {
    var appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
  }
  var notificationBox = await Hive.openBox(AppConstants.getHiveBoxName());
  for (String notificationJson in unprocessedNotifications) {
    var notification = jsonDecode(notificationJson);
    await notificationBox.put(notification['notificationId'], notification);

    // Call Android to remove notification from temp storage after saving
    await PlatformChannels.removeNotificationFromTempStorage(
        notification['notificationId']);
  }
}

dynamic _convertToEncodable(dynamic value) {
  if (value is Map) {
    return value.map((key, value) => MapEntry(key, _convertToEncodable(value)));
  } else if (value is List) {
    return value.map((item) => _convertToEncodable(item)).toList();
  } else if (value is DateTime) {
    return value.toIso8601String();
  } else if (value is Duration) {
    return value.inMilliseconds;
  } else {
    return value;
  }
}

Future<void> backupToDrive() async {
  if (!Hive.isBoxOpen(AppConstants.getHiveBoxName())) {
    var appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
  }
  var notificationBox = await Hive.openBox(AppConstants.getHiveBoxName());

  Map<String, dynamic> data = {
    for (var item
        in notificationBox.values.where((element) => element['backup'] != true))
      item['notificationId'].toString(): _convertToEncodable(item)
  };
  String jsonString = jsonEncode(data);

  // Save the JSON data to a file
  final appDir = await getApplicationDocumentsDirectory();
  final backupFile = File('${appDir.path}/backup_notifications.json');
  await backupFile.writeAsString(jsonString);

  GoogleService googleService = GoogleService();
  drive.DriveApi? driveApi = await googleService.getDriveApi();

  if (driveApi == null) {
    throw Exception("Failed to authenticate with Google Drive API.");
  }

  var fatherFolder = await googleService.getFolderId(driveApi, 'notifsaver');
  var driveFile = drive.File()
    ..name = "backup_notifications_${DateTime.now().toIso8601String()}.json"
    ..parents = [fatherFolder];

  var fileMedia = drive.Media(
    backupFile.openRead(),
    await backupFile.length(),
  );

  await driveApi.files.create(
    driveFile,
    uploadMedia: fileMedia,
  );

  // Mark notifications as backed up
  for (Map<String, dynamic> item in data.values) {
    var notification = await notificationBox.get(item['notificationId']);
    notification['backup'] = true;
    await notificationBox.put(item['notificationId'], notification);
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await LogModel.addLog(
          AppConstants.logInfo, "Background Task executing: $task");

      switch (task) {
        case 'saveNotification':
          await saveNotification();
          break;
        case 'backupToDrive':
          await backupToDrive();
          break;
        default:
      }

      await LogModel.addLog(
          AppConstants.logInfo, "Background Task executed: $task");
    } catch (err) {
      await LogModel.addLog(
          AppConstants.logError, "Error in background task: $err");
    }
    return Future.value(true);
  });
}

class AutoJobManagementInjection {
  // Method to initialize all controllers and other dependencies
  static Future<void> init() async {
    await Hive.initFlutter();
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    Workmanager().registerPeriodicTask(
      '1',
      'saveNotification',
      frequency: const Duration(minutes: 15), // Frequency is minimum 15 minutes
    );

    Workmanager().registerPeriodicTask(
      '2',
      'backupToDrive',
      frequency: const Duration(hours: 24), // Frequency is minimum 15 minutes
    );
  }
}
