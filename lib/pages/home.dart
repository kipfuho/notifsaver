import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Use GetX to find the NotificationController
  final NotificationController notificationController = Get.find();

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
          ],
        ),
      ),
    );
  }
}
