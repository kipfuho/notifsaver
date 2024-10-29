import 'package:flutter/services.dart';

class PlatformChannels {
  static const MethodChannel notificationsChannel =
      MethodChannel('com.example.notifsaver/notifications');

  static const notificationsEventChannel =
      EventChannel('com.example.notifsaver/notificationStream');

  static Future<String?> getAppIcon(String packageName) async {
    final String? icon =
        await notificationsChannel.invokeMethod('getAppIcon', packageName);
    return icon;
  }

  static Future<void> openNotificationSettings() async {
    await notificationsChannel.invokeMethod('openNotificationSettings');
  }

  static Future<List<dynamic>>
      getUnprocessedNotificationsFromTempStorage() async {
    var unprocessedNotifications = await notificationsChannel
        .invokeMethod('getUnprocessedNotificationsFromTempStorage');
    return unprocessedNotifications;
  }

  static Future<void> removeNotificationFromTempStorage(notificationId) async {
    await notificationsChannel
        .invokeMethod('removeNotificationFromTempStorage', {
      'notificationId': notificationId,
    });
  }
}
