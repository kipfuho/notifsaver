import 'dart:io';
import 'package:get/get.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prj3/constant.dart';
import 'package:prj3/controllers/network_controller.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:prj3/google_service.dart';
import 'package:prj3/models/log_model.dart';
import 'package:workmanager/workmanager.dart';
import 'package:prj3/platform_channel.dart';
import 'dart:convert';

Future<void> _checkNetwork() async {
  NetworkController networkCtl;
  try {
    networkCtl = Get.find();
  } catch (e) {
    networkCtl = Get.put(NetworkController());
  }
  bool internetAccess = await networkCtl.hasInternetAccess();
  if (!internetAccess) {
    throw Exception("Error saveNotification. No Internet Access");
  }
}

Future<void> saveNotification() async {
  await _checkNetwork();

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
  await _checkNetwork();

  if (!Hive.isBoxOpen(AppConstants.getHiveBoxName())) {
    var appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
  }
  var notificationBox = await Hive.openBox(AppConstants.getHiveBoxName());

  // Get the previous month's box, to make sure no noti is missed
  DateTime now = DateTime.now();
  DateTime previousMonth = DateTime(now.year, now.month - 1);
  var previousNotificationBox =
      await Hive.openBox(AppConstants.getHiveBoxName(date: previousMonth));

  Map<String, dynamic> data = {
    for (var item
        in notificationBox.values.where((element) => element['backup'] != true))
      item['notificationId'].toString(): _convertToEncodable(item),
    for (var item in previousNotificationBox.values
        .where((element) => element['backup'] != true))
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
  for (Map<dynamic, dynamic> item in data.values) {
    var notification = await notificationBox.get(item['notificationId']);
    notification['backup'] = true;
    await notificationBox.put(item['notificationId'], notification);
  }
}

Future<void> deleteLogs() async {
  // TODO: disable logs for production
  await _checkNetwork();

  if (!Hive.isBoxOpen(AppConstants.logs)) {
    var appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
  }
  var logBox = Hive.isBoxOpen(AppConstants.logs)
      ? Hive.box(AppConstants.logs)
      : await Hive.openBox(AppConstants.logs);

  DateTime now = DateTime.now();
  DateTime threshold = now.subtract(const Duration(days: 3));

  // Iterate through the logs and delete those older than 3 days
  for (var key in logBox.keys) {
    var log = logBox.get(key);
    if (log != null && log['timestamp'] != null) {
      DateTime logDate = DateTime.parse(log['timestamp']);
      if (logDate.isBefore(threshold)) {
        await logBox.delete(key);
      }
    }
  }
}

Future<void> syncData() async {
  await _checkNetwork();

  UserController userController;
  try {
    userController = Get.find();
  } catch (e) {
    userController = Get.put(UserController());
  }
  userController.startSyncData();

  if (!Hive.isBoxOpen(AppConstants.getHiveBoxName())) {
    var appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
  }

  GoogleService googleService = GoogleService();
  drive.DriveApi? driveApi = await googleService.getDriveApi();

  if (driveApi == null) {
    throw Exception("Failed to authenticate with Google Drive API.");
  }

  var fatherFolder = await googleService.getFolderId(driveApi, 'notifsaver');

  // List all files in the folder
  List<drive.File> files =
      await googleService.listFilesInFolder(driveApi, fatherFolder);
  for (var file in files) {
    var media = await driveApi.files.get(file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    var fileContent = await media.stream.transform(utf8.decoder).join();

    // Parse the JSON content
    Map<String, dynamic> jsonData = jsonDecode(fileContent);

    // Search through the notifications
    for (var notification in jsonData.values) {
      DateTime updatedAt = DateTime.parse(notification['updatedAt']);
      var notiBox =
          await Hive.openBox(AppConstants.getHiveBoxName(date: updatedAt));
      await notiBox.put(notification['notificationId'], notification);
    }
  }

  await backupToDrive();
  userController.finishSyncData();
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background Task executing: $task");
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
        case 'deleteLogs':
          await deleteLogs();
          break;
        case 'syncData':
          await syncData();
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

    Workmanager().registerPeriodicTask(
      '3',
      'deleteLogs',
      frequency: const Duration(days: 3), // Frequency is minimum 15 minutes
    );
  }
}
