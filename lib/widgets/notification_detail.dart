import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class NotificationDetail extends StatelessWidget {
  final Map<dynamic, dynamic> notification;
  final NotificationController notificationController;
  final RxString notiType;

  NotificationDetail({
    super.key,
    required this.notification,
    NotificationController? notificationController,
  })  : notificationController = notificationController ?? Get.find(),
        notiType = notification['status'].obs;

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
                        Text(notification['appName'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow("Tag", notification['tag']),
                    _buildDetailRow("Post Time", notification['postTime']),
                    _buildDetailRow("Title", notification['title']),
                    _buildDetailRow("Text", notification['text']),
                    _buildDetailRow("Sub Text", notification['subText']),
                    _buildDetailRow("Big Text", notification['bigText']),
                    _buildDetailRow("Category", notification['category']),
                    _buildDetailRow("Ticker Text", notification['tickerText']),
                    _buildDetailRow("Priority", notification['priority']),
                    _buildDetailRow("Channel ID", notification['channelId']),
                    _buildDetailRow("Status", notification['status']),
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
          notificationController
              .saveNotification(notification['notificationId']);
          Navigator.pop(context);
        },
        child: Text(Intl.message('save', name: 'save')),
      );
    }

    return ElevatedButton(
      onPressed: () async {
        notificationController
            .unSaveNotification(notification['notificationId']);
        Navigator.pop(context);
      },
      child: Text(Intl.message('unsave', name: 'unsave')),
    );
  }
}
