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
    final List<dynamic> appNames =
        await notificationsChannel.invokeMethod('getApplicationPackageNames');
    final List<String> packageNames = appNames.cast<String>();

    return packageNames;
  }

  static Future<List<String>> getAllInclusiveApp() async {
    final List<dynamic> appNames =
        await notificationsChannel.invokeMethod('getInclusiveApps');
    final List<String> packageNames = appNames.cast<String>();
    return packageNames;
  }

  static Future<void> addInclusiveApp(packageName) async {
    await notificationsChannel.invokeMethod('addInclusiveApp', packageName);
    return;
  }

  static Future<void> removeInclusiveApp(packageName) async {
    await notificationsChannel.invokeMethod('removeInclusiveApp', packageName);
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
