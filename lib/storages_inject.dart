import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Perform background task: Listen to notifications, save to Hive, etc.
    var box = await Hive.openBox('notificationsBox');
    box.add('New background notification at ${DateTime.now()}');
    print("Background Task executed: $task");
    return Future.value(true);
  });
}

class StorageManagementInjection {
  // Method to initialize all controllers and other dependencies
  static void init() async {
    // Initialize Hive
    await Hive.initFlutter();
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
