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
  var isLoading = false.obs;

  final List<Map<String, dynamic>> _notificationQueue = [];
  late StreamSubscription _queueProcessor;
  late Box? notificationBox;

  @override
  void onInit() {
    super.onInit();
    _initNotificationBox();
    _listenToNotificationStream();
    _startQueueProcessor();
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
      PlatformChannels.openNotificationSettings();
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
    await filterNotifications();
  }

  Future<void> _initNotificationBox() async {
    notificationBox = await Hive.openBox(AppConstants.getHiveBoxName());
    await filterNotifications();
  }

  bool _compareToSearchQuery(dynamic notification,
      {String? searchText, List<String>? searchApps}) {
    bool containSearchText = true;
    bool isInSearchApps = true;
    if (searchText != null && searchText.isNotEmpty) {
      containSearchText = notification['text'].contains('searchText');
    }
    if (searchApps != null && searchApps != []) {
      isInSearchApps = searchApps.contains(notification['packageName']);
    }
    return containSearchText && isInSearchApps;
  }

  Future<void> filterNotifications(
      {String? searchText, List<String>? searchApps}) async {
    if (notificationBox == null) return;
    isLoading.value = true;

    unreadNotifications.value = notificationBox!.values
        .where((notification) =>
            notification['status'] == 'unread' &&
            _compareToSearchQuery(notification,
                searchText: searchText, searchApps: searchApps))
        .toList();

    readNotifications.value = notificationBox!.values
        .where((notification) => notification['status'] == 'read')
        .toList();

    savedNotifications.value = notificationBox!.values
        .where((notification) => notification['status'] == 'saved')
        .toList();

    isLoading.value = false;
  }

  Future<void> markAsRead(dynamic notificationId, {int? index}) async {
    var notification = notificationBox!.get(notificationId);
    if (notification != null) {
      notification['status'] = 'read';
      notification['updatedAt'] = DateTime.now();
      await notificationBox!.put(notificationId, notification);

      readNotifications.add(notification);
      if (index != null) {
        unreadNotifications.removeAt(index);
      } else {
        unreadNotifications.removeWhere(
            (notification) => notification['notificationId'] == notificationId);
      }
    }
  }

  Future<void> saveNotification(dynamic notificationId, {int? index}) async {
    var notification = notificationBox!.get(notificationId);
    if (notification != null) {
      notification['status'] = 'saved';
      notification['updatedAt'] = DateTime.now();
      await notificationBox!.put(notificationId, notification);

      savedNotifications.add(notification);
      if (index != null) {
        readNotifications.removeAt(index);
      } else {
        readNotifications.removeWhere(
            (notification) => notification['notificationId'] == notificationId);
      }
    }
  }

  Future<void> unSaveNotification(dynamic notificationId, {int? index}) async {
    var notification = notificationBox!.get(notificationId);
    if (notification != null) {
      notification['status'] = 'read';
      notification['updatedAt'] = DateTime.now();
      await notificationBox!.put(notificationId, notification);

      readNotifications.add(notification);
      if (index != null) {
        savedNotifications.removeAt(index);
      } else {
        savedNotifications.removeWhere(
            (notification) => notification['notificationId'] == notificationId);
      }
    }
  }

  Future<void> deleteNotification(dynamic notificationId) async {
    var notification = notificationBox!.get(notificationId);
    if (notification != null) {
      notification['status'] = 'deleted';
      notification['updatedAt'] = DateTime.now();
      await notificationBox!.put(notificationId, notification);

      savedNotifications.removeWhere(
          (notification) => notification['notificationId'] == notificationId);
      readNotifications.removeWhere(
          (notification) => notification['notificationId'] == notificationId);
      unreadNotifications.removeWhere(
          (notification) => notification['notificationId'] == notificationId);
    }
  }

  RxList<dynamic> getNotificationList(dynamic type) {
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
