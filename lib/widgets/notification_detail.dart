import 'package:flutter/material.dart';

import 'package:prj3/widgets/notification_icon.dart';

class NotificationDetail extends StatelessWidget {
  final Map<dynamic, dynamic> notification;

  const NotificationDetail({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
}
