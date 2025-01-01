import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/utils/common.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class NotificationDetail extends StatelessWidget {
  final Map<dynamic, dynamic> notification;
  final int index;
  final NotificationController notificationController;
  final RxString notiType;

  NotificationDetail({
    super.key,
    required this.notification,
    required this.index,
    NotificationController? notificationController,
  })  : notificationController = notificationController ?? Get.find(),
        notiType = RxString(notification['status']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(Intl.message('notification_detail',
              name: 'notification_detail'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NotificationIcon(
                            packageName: notification['packageName']),
                        const SizedBox(width: 16),
                        Text(
                            notification['appName'] ??
                                notification['packageName'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        Intl.message('tag', name: 'tag'), notification['tag']),
                    _buildDetailRow(
                        Intl.message('post_time', name: 'post_time'),
                        HelperFunction.formatYYYYMMDDHHMMSS(
                            notification['postTime'].toString())),
                    _buildDetailRow(
                        Intl.message('last_modified_time',
                            name: 'last_modified_time'),
                        HelperFunction.formatYYYYMMDDHHMMSS(
                            notification['updatedAt'].toString())),
                    _buildDetailRow(Intl.message('title', name: 'title'),
                        notification['title']),
                    _buildDetailRow(Intl.message('text', name: 'text'),
                        notification['text']),
                    _buildDetailRow(Intl.message('sub_text', name: 'sub_text'),
                        notification['subText']),
                    _buildDetailRow(Intl.message('big_text', name: 'big_text'),
                        notification['bigText']),
                    _buildDetailRow(Intl.message('category', name: 'category'),
                        notification['category']),
                    _buildDetailRow(
                        Intl.message('ticker_text', name: 'ticker_text'),
                        notification['tickerText']),
                    _buildDetailRow(Intl.message('priority', name: 'priority'),
                        notification['priority']),
                    _buildDetailRow(
                        Intl.message('channel_id', name: 'channel_id'),
                        notification['channelId']),
                    _buildDetailRow(Intl.message('status', name: 'status'),
                        notification['status']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(300.0, 12.0, 300.0, 12.0),
          child: Obx(() => _buildButton(context, notiType.value))),
    );
  }

  // Helper method to build each row in the details list
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value?.toString() ?? "N/A"),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String notiType) {
    if (notiType == 'read') {
      return ElevatedButton(
        onPressed: () async {
          this.notiType.value = 'saved';
          notificationController.saveNotification(
              notification['notificationId'], notification['updatedAt'],
              index: index);
        },
        child: Text(Intl.message('save', name: 'save')),
      );
    }

    return ElevatedButton(
      onPressed: () async {
        this.notiType.value = 'read';
        notificationController.unSaveNotification(
            notification['notificationId'], notification['updatedAt'],
            index: index);
      },
      child: Text(Intl.message('unsave', name: 'unsave')),
    );
  }
}
