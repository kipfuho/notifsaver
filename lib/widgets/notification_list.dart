import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/widgets/notification_detail.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'dart:async';

class NotificationList extends StatefulWidget {
  final String notificationType;
  const NotificationList({super.key, required this.notificationType});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList>
    with AutomaticKeepAliveClientMixin {
  final NotificationController notificationController = Get.find();
  static const int pageSize = 10;
  late RxList<dynamic> notifications;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);
  
  @override
  void initState() {
    super.initState();
    notifications = notificationController.getNotificationList(widget.notificationType);

    // Listen for changes in notifications
    ever(notifications, (_) {
      _appendNewItems();
    });

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final start = pageKey * pageSize;
      if ((_pagingController.itemList?.length ?? 0) > start) {
        _pagingController.appendLastPage([]);
      }
      final newItems = notifications.skip(start).take(pageSize).toList();

      final isLastPage = newItems.length < pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  // This method will be called when the notifications change
  void _appendNewItems() {
    final newItems = notifications.skip(_pagingController.itemList?.length ?? 0).take(pageSize).toList();
    print('append new item');
    print(newItems);

    if (newItems.isNotEmpty) {
      _pagingController.appendLastPage(newItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return PagedListView<int, dynamic>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
        itemBuilder: (context, notification, index) {
          return GestureDetector(
            onTap: () {
              // Mark notification as read and navigate to detail page
              notificationController.markAsRead(notification['notificationId']);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationDetail(notification: notification),
                ),
              );
            },
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  NotificationIcon(packageName: notification['packageName']),
                ],
              ),
              title: Text(
                notification['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                notification['text'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keeps widget alive across navigations
}
