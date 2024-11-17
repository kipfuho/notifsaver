import 'package:hive_flutter/hive_flutter.dart';
import 'package:prj3/constant.dart';
import 'package:prj3/platform_channel.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';

class NotificationController extends GetxController {
  var notificationData = 'No notifications received'.obs;
  var unreadNotifications = <dynamic>[].obs;
  var readNotifications = <dynamic>[].obs;
  var savedNotifications = <dynamic>[].obs;

  final List<Map<String, dynamic>> _notificationQueue =
      []; // Queue for notifications
  late StreamSubscription _queueProcessor; // Subscription to process the queue
  late Box? notificationBox;

  @override
  void onInit() {
    super.onInit();
    _initNotificationBox();
    _listenToNotificationStream();
    _startQueueProcessor(); // Start the queue processor on init
  }

  @override
  void onClose() {
    _queueProcessor
        .cancel(); // Stop the queue processor when controller is disposed
    notificationBox?.close();
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
    PlatformChannels.notificationsEventChannel.receiveBroadcastStream().listen(
        (event) {
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
      notificationData.value =
          "Failed to listen to notifications: ${error.message}";
    });
  }

  void _addToQueue(Map<String, dynamic> notification) {
    _notificationQueue.add(notification);
  }

  void _startQueueProcessor() {
    _queueProcessor =
        Stream.periodic(const Duration(seconds: 1)).listen((_) async {
      if (_notificationQueue.isNotEmpty) {
        Map<String, dynamic> notification = _notificationQueue.removeAt(0);
        await _saveNotificationToHive(notification);
      }
    });
  }

  Future<void> _saveNotificationToHive(
      Map<String, dynamic> notification) async {
    await notificationBox!.put(notification['notificationId'], notification);
    await PlatformChannels.removeNotificationFromTempStorage(
        notification['notificationId']);
    await _filterNotifications();
  }

  Future<void> _initNotificationBox() async {
    notificationBox = await Hive.openBox(AppConstants.getHiveBoxName());
    await _filterNotifications();
  }

  Future<void> _filterNotifications() async {
    if (notificationBox == null) return;
  
    unreadNotifications.value = notificationBox!.values
        .where((notification) => notification['status'] == 'unread')
        .toList();

    readNotifications.value = notificationBox!.values
        .where((notification) => notification['status'] == 'read')
        .toList();

    savedNotifications.value = notificationBox!.values
        .where((notification) => notification['status'] == 'saved')
        .toList();
  }

  Future<void> markAsRead(int notificationId) async {
    var notification = notificationBox!.get(notificationId);
    if (notification != null) {
      notification['status'] = 'read';
      notification['updatedAt'] = DateTime.now();
      await notificationBox!.put(notificationId, notification);
      await _filterNotifications();
    }
  }

  Future<void> saveNotification(int notificationId) async {
    var notification = notificationBox!.get(notificationId);
    if (notification != null) {
      notification['status'] = 'saved';
      notification['updatedAt'] = DateTime.now();
      await notificationBox!.put(notificationId, notification);
      await _filterNotifications();
    }
  }

  Future<void> unSaveNotification(int notificationId) async {
    var notification = notificationBox!.get(notificationId);
    if (notification != null) {
      notification['status'] = 'read';
      notification['updatedAt'] = DateTime.now();
      await notificationBox!.put(notificationId, notification);
      await _filterNotifications();
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    var notification = notificationBox!.get(notificationId);
    if (notification != null) {
      notification['status'] = 'deleted';
      notification['updatedAt'] = DateTime.now();
      await notificationBox!.put(notificationId, notification);
      await _filterNotifications();
    }
  }

  RxList<dynamic> getNotificationList(String type) {
    if (type == 'unread') {
      return unreadNotifications;
    }
    if (type == 'read') {
      return readNotifications;
    }
    if (type == 'saved') {
      return savedNotifications;
    }
    return [].obs;
  }
}
