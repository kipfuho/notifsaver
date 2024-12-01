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

  static Future<String> getAppName(String packageName) async {
    final String appName =
        await notificationsChannel.invokeMethod('getAppName', packageName);
    return appName;
  }

  static Future<List<String>> getAppPackageNames() async {
    final List<String> appNames =
        await notificationsChannel.invokeMethod('getApplicationPackageNames');
    return appNames;
  }

  static Future<List<String>> getAllExclusiveApp() async {
    final List<String> appNames =
        await notificationsChannel.invokeMethod('getExclusiveApps');
    return appNames;
  }

  static Future<void> addExclusiveApp(packageName) async {
    await notificationsChannel.invokeMethod('addExclusiveApp', packageName);
    return;
  }

  static Future<void> removeExclusiveApp(packageName) async {
    await notificationsChannel.invokeMethod('removeExclusiveApp', packageName);
    return;
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
