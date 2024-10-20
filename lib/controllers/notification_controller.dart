import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  static const platform = MethodChannel('com.example.notifsaver/notifications');
  static const notificationEventChannel =
      EventChannel('com.example.notifsaver/notificationStream');

  var notificationData = 'No notifications received'.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToNotificationStream();
  }

  Future<void> openNotificationSettings() async {
    try {
      await platform.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      print("Failed to open notification settings: '${e.message}'.");
    }
  }

  void _listenToNotificationStream() {
    notificationEventChannel.receiveBroadcastStream().listen((event) {
      notificationData.value = event.toString();
    }, onError: (error) {
      notificationData.value =
          "Failed to listen to notifications: ${error.message}";
    });
  }
}
