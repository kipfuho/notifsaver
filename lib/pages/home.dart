import 'package:prj3/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'package:prj3/widgets/notification_list.dart';
import 'package:prj3/widgets/test_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Use GetX to find the NotificationController
  final NotificationController notificationController = Get.find();

  Future<void> printHiveData() async {
    var box = await Hive.openBox('notificationsBox');
    var keys = box.keys;

    for (var key in keys) {
      var value = box.get(key);
      print('Key: $key, Value: $value');
    }
  }

  Future<void> deleteHiveBox() async {
    // Open the box (if not already opened)
    var box = await Hive.openBox('notificationsBox');

    // Delete the box from disk
    await box.deleteFromDisk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              notificationController.openNotificationSettings();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use Obx to listen to notificationData updates
            Obx(() => Text(
                'Notification Data: ${notificationController.notificationData}')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                notificationController.openNotificationSettings();
              },
              child: const Text('Open Notification Settings'),
            ),
            const NotificationList(),
            const SizedBox(height: 20),
            // Button to print Hive data
            ElevatedButton(
              onPressed: () {
                printHiveData();
              },
              child: const Text('Print Hive Data'),
            ),
            const SizedBox(height: 20),
            // Button to print Hive data
            ElevatedButton(
              onPressed: () {
                deleteHiveBox();
              },
              child: const Text('Delete Hive Data'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle Unread button press
                    },
                    child: Text('Unread'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle Read button press
                    },
                    child: Text('Read'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle Saved button press
                    },
                    child: Text('Saved'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
