import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prj3/widgets/notification_icon.dart';

class NotificationList extends StatefulWidget {
  final String notificationType;
  const NotificationList({super.key, required this.notificationType});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> notifications = []; // List to hold notification data
  int currentPage = 0; // Current page number
  final int pageSize = 10; // Number of items to fetch per page
  bool isLoading = false; // Loading state
  bool hasMore = true; // Flag to check if more items are available
  Box? notificationBox; // Reference to Hive box

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  @override
  void dispose() {
    notificationBox?.close(); // Close the box to prevent memory leaks
    super.dispose();
  }

  // Initialize Hive box and fetch initial notifications
  Future<void> _initNotifications() async {
    // Initialize the Hive box dynamically based on notificationType
    notificationBox = await Hive.openBox(widget.notificationType);
    _fetchNotifications();
  }

  // Function to load notifications from Hive box with pagination
  Future<List<dynamic>> _getNotifications() async {
    if (notificationBox == null) return [];
    return notificationBox!.values
        .skip(currentPage * pageSize)
        .take(pageSize)
        .toList();
  }

  // Function to fetch notifications and update state
  Future<void> _fetchNotifications() async {
    if (isLoading || !hasMore) return; // Prevent duplicate loads

    setState(() {
      isLoading = true;
    });

    var newNotifications = await _getNotifications();

    setState(() {
      currentPage++;
      isLoading = false;
      hasMore = newNotifications.length ==
          pageSize; // Check if more data is available
      notifications.addAll(newNotifications);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _fetchNotifications(); // Load more when reaching the bottom
        }
        return true;
      },
      child: ListView.separated(
        itemCount: notifications.length +
            (isLoading ? 1 : 0), // Add loading item if loading
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            // Show loading indicator at the end
            return const Center(child: CircularProgressIndicator());
          }

          return ListTile(
            leading: Row(
              mainAxisSize:
                  MainAxisSize.min, // Ensures minimal width for the row
              children: [
                Text(
                  '${index + 1}', // Display index starting from 1
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8), // Spacing between index and icon
                NotificationIcon(
                    packageName: notifications[index]['packageName']),
              ],
            ),
            title: Text(
              notifications[index]['title'],
              maxLines: 1, // Ensures the title is only on one line
              overflow: TextOverflow.ellipsis, // Clips text if it's too long
            ),
            subtitle: Text(
              notifications[index]['text'] ??
                  '', // Display additional content below title
              maxLines: 2, // Limits the subtitle to two lines
              overflow: TextOverflow.ellipsis, // Clips text if it's too long
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keeps widget alive across navigations
}
