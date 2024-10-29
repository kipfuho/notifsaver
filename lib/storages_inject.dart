import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:prj3/platform_channel.dart';
import 'dart:convert';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Call Android to retrieve unprocessed notifications
      final List<dynamic> unprocessedNotifications =
          await PlatformChannels.getUnprocessedNotificationsFromTempStorage();

      // if (unprocessedNotifications.isEmpty) {
      //   return Future.value(true);
      // }

      // Get the directory for storing Hive data
      if (!Hive.isBoxOpen('notificationsBox')) {
        var appDir = await getApplicationDocumentsDirectory();
        Hive.init(appDir.path);
      }
      var box = await Hive.openBox('notificationsBox');
      for (String notificationJson in unprocessedNotifications) {
        var notification = jsonDecode(notificationJson);
        await box.add(notification);

        // Call Android to remove notification from temp storage after saving
        await PlatformChannels.removeNotificationFromTempStorage(
            notification['notificationId']);
      }

      print("Background Task executed: $task");
    } catch (e) {
      print("Error in background task: $e");
    }

    return Future.value(true);
  });
}

class StorageManagementInjection {
  // Method to initialize all controllers and other dependencies
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();
    var appDir = await getApplicationDocumentsDirectory();
    print(appDir);
    // Open a box to store notifications
    await Hive.openBox('notificationsBox');

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
