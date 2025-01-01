import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:prj3/controllers/filter_controller.dart';
import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/utils/hot_message.dart';
import 'package:prj3/widgets/notification_detail.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'package:prj3/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:async';

part 'notification_list.ext.dart';

class NotificationList extends StatefulWidget {
  final String notificationType;
  const NotificationList({super.key, required this.notificationType});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList>
    with AutomaticKeepAliveClientMixin {
  late final PagingListController _pListCtl;
  final NotificationController _notiCtl = Get.find();
  final FilterController _filterCtl = Get.find();

  @override
  void initState() {
    super.initState();
    _pListCtl = Get.put(PagingListController(widget.notificationType),
        tag: widget.notificationType);

    ever(
      _filterCtl.isSearching,
      (bool newIsSearching) async {
        if (newIsSearching) {
          await _notiCtl.filterNotifications(
            searchApps: _filterCtl.searchParams['searchApps'],
            searchText: _filterCtl.searchParams['searchText'],
          );
        }
        _pListCtl.refreshList();
      },
    );
  }

  @override
  void dispose() {
    _pListCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return PagedListView<int, dynamic>(
      pagingController: _pListCtl._pagingCtl,
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
          itemBuilder: (context, notification, index) {
            return GestureDetector(
              onTap: () {
                if (notification['status'] == 'unread') {
                  _notiCtl.markAsRead(
                      notification['notificationId'], notification['updatedAt'],
                      index: index);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDetail(
                        notification: notification, index: index),
                  ),
                );
              },
              onDoubleTap: () {
                _pListCtl.refreshList();
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['text'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['updatedAt'] != null
                          ? HelperFunction.formatYYYYMMDD(
                              notification['updatedAt'])
                          : 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          noItemsFoundIndicatorBuilder: (context) => Scaffold(
                body: GestureDetector(
                  onDoubleTap: () {
                    _pListCtl.refreshList();
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        Intl.message('no_notifications',
                            name: 'no_notifications'),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              )),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keeps widget alive across navigations
}
