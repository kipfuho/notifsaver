import 'package:hive_flutter/hive_flutter.dart';
import 'package:prj3/platform_channel.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';


class NotificationController extends GetxController {
  var notificationData = 'No notifications received'.obs;
  final List<Map<String, dynamic>> _notificationQueue = []; // Queue for notifications
  late StreamSubscription _queueProcessor; // Subscription to process the queue

  @override
  void onInit() {
    super.onInit();
    _listenToNotificationStream();
    _startQueueProcessor(); // Start the queue processor on init
  }

  @override
  void onClose() {
    _queueProcessor.cancel(); // Stop the queue processor when controller is disposed
    super.onClose();
  }

  void openNotificationSettings() {
    try {
      PlatformChannels.openNotificationSettings;
    } on PlatformException catch (e) {
      print("Failed to open notification settings: '${e.message}'");
    }
  }

  void _listenToNotificationStream() {
    PlatformChannels.notificationsEventChannel.receiveBroadcastStream().listen((event) {
      try {
        // Decode the JSON string into a Map
        Map<String, dynamic> notificationJson = jsonDecode(event);
        
        // Update the notificationData for UI display
        notificationData.value = """
          Package: ${notificationJson['packageName']}
          Title: ${notificationJson['title']}
          Text: ${notificationJson['text']}
          Time: ${notificationJson['postTime']}
        """;

        // Add notification to queue instead of saving directly
        _addToQueue(notificationJson);
      } catch (e) {
        notificationData.value = "Failed to parse notification: $e";
      }
    }, onError: (error) {
      notificationData.value = "Failed to listen to notifications: ${error.message}";
    });
  }

  void _addToQueue(Map<String, dynamic> notification) {
    _notificationQueue.add(notification);
  }

  void _startQueueProcessor() {
    _queueProcessor = Stream.periodic(const Duration(seconds: 1)).listen((_) async {
      if (_notificationQueue.isNotEmpty) {
        Map<String, dynamic> notification = _notificationQueue.removeAt(0);
        await _saveNotificationToHive(notification); // Save one notification at a time
      }
    });
  }

  Future<void> _saveNotificationToHive(Map<String, dynamic> notification) async {
    var box = await Hive.openBox('notificationsBox');
    await box.add(notification); // Save the notification data to Hive'

    // Confirm receipt to Android to remove from temporary storage
    await PlatformChannels.removeNotificationFromTempStorage(notification['notificationId']);
  }
}
