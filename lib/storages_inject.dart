import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prj3/constant.dart';
import 'package:prj3/models/log_model.dart';
import 'package:workmanager/workmanager.dart';
import 'package:prj3/platform_channel.dart';
import 'dart:convert';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Call Android to retrieve unprocessed notifications
      final List<dynamic> unprocessedNotifications =
          await PlatformChannels.getUnprocessedNotificationsFromTempStorage();

      if (unprocessedNotifications.isEmpty) {
        return Future.value(true);
      }

      // Get the directory for storing Hive data
      if (!Hive.isBoxOpen(AppConstants.unreadNotifications)) {
        var appDir = await getApplicationDocumentsDirectory();
        Hive.init(appDir.path);
      }
      var notificationBox =
          await Hive.openBox(AppConstants.unreadNotifications);
      for (String notificationJson in unprocessedNotifications) {
        var notification = jsonDecode(notificationJson);
        await notificationBox.add(notification);

        // Call Android to remove notification from temp storage after saving
        await PlatformChannels.removeNotificationFromTempStorage(
            notification['notificationId']);
      }
      await notificationBox.close();
      await LogModel.addLog(AppConstants.logInfo, "Background Task executed: $task");
    } catch (e) {
      await LogModel.addLog(AppConstants.logError, "Error in background task: $e");
    }

    return Future.value(true);
  });
}

class StorageManagementInjection {
  // Method to initialize all controllers and other dependencies
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Initialize WorkManager
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    // Register periodic background task (every 15 minutes)
    Workmanager().registerPeriodicTask(
      '1',
      'saveNotification',
      frequency: const Duration(minutes: 15), // Frequency is minimum 15 minutes
    );
  }
}
