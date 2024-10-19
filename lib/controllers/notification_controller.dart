import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  static const platform = MethodChannel('com.example.notifsaver/notifications');

  var notificationData = 'No notifications received'.obs;

  @override
  void onInit() {
    super.onInit();
    _startListeningForNotifications();
  }

  Future<void> openNotificationSettings() async {
    try {
      await platform.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      print("Failed to open notification settings: '${e.message}'.");
    }
  }

  Future<void> _startListeningForNotifications() async {
    try {
      final String result = await platform.invokeMethod('startNotificationListener');
      notificationData.value = result;
    } on PlatformException catch (e) {
      notificationData.value = "Failed to get notifications: '${e.message}'.";
    }
  }
}
