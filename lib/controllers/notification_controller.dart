import 'package:hive_flutter/hive_flutter.dart';
import 'package:prj3/constant.dart';
import 'package:prj3/models/log_model.dart';
import 'package:prj3/platform_channel.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';

import 'package:prj3/utils/hot_message.dart';

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
    } on PlatformException catch (err) {
      HotMessage.showError(err.toString());
      LogModel.logError(
          "Failed to open notification settings: '${err.message}'");
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
      } catch (err) {
        HotMessage.showError(err.toString());
        notificationData.value = "Failed to parse notification: $err";
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
    // add createdAt and updatedAt
    notification['createdAt'] = DateTime.now().toIso8601String();
    notification['updatedAt'] = DateTime.now().toIso8601String();
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
    if (!notificationBox!.isOpen) {
      notificationBox = await Hive.openBox(AppConstants.getHiveBoxName());
    }

    unreadNotifications.value = notificationBox!.values
        .where((notification) =>
            notification['status'] == 'unread' &&
            _compareToSearchQuery(notification,
                searchText: searchText, searchApps: searchApps))
        .toList()
      ..sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));

    readNotifications.value = notificationBox!.values
        .where((notification) =>
            notification['status'] == 'read' &&
            _compareToSearchQuery(notification,
                searchText: searchText, searchApps: searchApps))
        .toList()
      ..sort((a, b) => DateTime.parse(b['updatedAt'])
          .compareTo(DateTime.parse(a['updatedAt'])));

    savedNotifications.value = notificationBox!.values
        .where((notification) =>
            notification['status'] == 'saved' &&
            _compareToSearchQuery(notification,
                searchText: searchText, searchApps: searchApps))
        .toList()
      ..sort((a, b) => DateTime.parse(b['updatedAt'])
          .compareTo(DateTime.parse(a['updatedAt'])));

    isLoading.value = false;
  }

  Future<void> markAsRead(String notificationId, String notificationPostTime,
      {int? index}) async {
    var box = await Hive.openBox(AppConstants.getHiveBoxName(
        date: DateTime.parse(notificationPostTime)));
    var notification = box.get(notificationId);
    if (notification != null) {
      notification['status'] = 'read';
      notification['updatedAt'] = DateTime.now().toIso8601String();
      await box.delete(notificationId);
      await notificationBox!.put(notificationId, notification);

      readNotifications.add(notification);
      if (index != null && index < unreadNotifications.length) {
        unreadNotifications.removeAt(index);
      } else {
        unreadNotifications.removeWhere(
            (notification) => notification['notificationId'] == notificationId);
      }
    }
  }

  Future<void> saveNotification(
      String notificationId, String notificationPostTime,
      {int? index}) async {
    var box = await Hive.openBox(AppConstants.getHiveBoxName(
        date: DateTime.parse(notificationPostTime)));
    var notification = box.get(notificationId);
    if (notification != null) {
      notification['status'] = 'saved';
      notification['updatedAt'] = DateTime.now().toIso8601String();
      await box.delete(notificationId);
      await notificationBox!.put(notificationId, notification);

      savedNotifications.add(notification);
      if (index != null && index < readNotifications.length) {
        readNotifications.removeAt(index);
      } else {
        readNotifications.removeWhere(
            (notification) => notification['notificationId'] == notificationId);
      }
    }
  }

  Future<void> unSaveNotification(
      String notificationId, String notificationPostTime,
      {int? index}) async {
    var box = await Hive.openBox(AppConstants.getHiveBoxName(
        date: DateTime.parse(notificationPostTime)));
    var notification = box.get(notificationId);
    if (notification != null) {
      notification['status'] = 'read';
      notification['updatedAt'] = DateTime.now().toIso8601String();
      await box.delete(notificationId);
      await notificationBox!.put(notificationId, notification);

      readNotifications.add(notification);
      if (index != null && index < savedNotifications.length) {
        savedNotifications.removeAt(index);
      } else {
        savedNotifications.removeWhere(
            (notification) => notification['notificationId'] == notificationId);
      }
    }
  }

  Future<void> deleteNotification(
      String notificationId, String notificationPostTime) async {
    var box = await Hive.openBox(AppConstants.getHiveBoxName(
        date: DateTime.parse(notificationPostTime)));
    var notification = box.get(notificationId);
    if (notification != null) {
      notification['status'] = 'deleted';
      notification['updatedAt'] = DateTime.now().toIso8601String();
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

  Future<Map<String, dynamic>> getPastNotificationList(
      dynamic type, DateTime time,
      {String? searchText, List<String>? searchApps}) async {
    var pastBox = await Hive.openBox(AppConstants.getHiveBoxName(date: time));
    if (type == 'unread') {
      return {
        'list': pastBox.values
            .where((notification) =>
                notification['status'] == 'unread' &&
                _compareToSearchQuery(notification,
                    searchText: searchText, searchApps: searchApps))
            .toList()
          ..sort((a, b) => DateTime.parse(b['updatedAt'])
              .compareTo(DateTime.parse(a['updatedAt']))),
        'shouldContinue': pastBox.values.isNotEmpty
      };
    }
    if (type == 'read') {
      return {
        'list': pastBox.values
            .where((notification) =>
                notification['status'] == 'read' &&
                _compareToSearchQuery(notification,
                    searchText: searchText, searchApps: searchApps))
            .toList()
          ..sort((a, b) => DateTime.parse(b['updatedAt'])
              .compareTo(DateTime.parse(a['updatedAt']))),
        'shouldContinue': pastBox.values.isNotEmpty
      };
    }
    if (type == 'saved') {
      return {
        'list': pastBox.values
            .where((notification) =>
                notification['status'] == 'saved' &&
                _compareToSearchQuery(notification,
                    searchText: searchText, searchApps: searchApps))
            .toList()
          ..sort((a, b) => DateTime.parse(b['updatedAt'])
              .compareTo(DateTime.parse(a['updatedAt']))),
        'shouldContinue': pastBox.values.isNotEmpty
      };
    }
    return {'list': [], 'shouldContinue': false};
  }

  T deepClone<T>(T object) {
    return jsonDecode(jsonEncode(object)) as T;
  }

  Future<void> addNotificationForTest({DateTime? date}) async {
    DateTime currentDate = date ?? DateTime.now();
    Map notification = {
      'notificationId': 'test_notification_${DateTime.now().toIso8601String()}',
      'packageName': 'com.test.app',
      'title': 'Test Notification',
      'text': 'This is a test notification',
      'postTime': currentDate.toIso8601String(),
      'status': 'unread',
      'createdAt': currentDate.toIso8601String(),
      'updatedAt': currentDate.toIso8601String(),
    };
    var box =
        await Hive.openBox(AppConstants.getHiveBoxName(date: currentDate));
    await box.put(notification['notificationId'], notification);
    await filterNotifications();
    print(unreadNotifications.value.length);
  }
}
