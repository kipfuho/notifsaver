import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'package:prj3/widgets/test_widget.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<dynamic> notifications = []; // List to hold notification data
  int currentPage = 0; // Current page number
  final int pageSize = 10; // Number of items to fetch per page
  bool isLoading = false; // Loading state
  bool hasMore = true; // Flag to check if more items are available

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Function to load notifications from Hive box
  Future<void> _loadNotifications() async {
    var notificationBox = await Hive.openBox('notificationsBox');
    setState(() {
      notifications = notificationBox.values.toList(); // Get all notifications
    });
  }

  // Function to fetch notifications
  Future<void> _fetchNotifications() async {
    if (isLoading || !hasMore) return; // Prevent duplicate loads

    setState(() {
      isLoading = true;
    });

    // Simulate fetching data from a source (API, database, etc.)
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // Generate dummy data for demonstration
    List<String> newNotifications = List.generate(pageSize, (index) {
      return 'Notification ${currentPage * pageSize + index + 1}';
    });

    setState(() {
      currentPage++;
      isLoading = false;
      hasMore = newNotifications.length == pageSize; // Check if more data is available
      notifications.addAll(newNotifications);
    });
  }

  // Function to handle scroll event
  void _onScroll() {
    final scrollPosition = ScrollController().position;
    if (scrollPosition.pixels >= scrollPosition.maxScrollExtent && !isLoading) {
      _fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _fetchNotifications(); // Load more when reaching the bottom
        }
        return true;
      },
      child: Expanded(
        child: ListView.separated(
          itemCount: notifications.length + (isLoading ? 1 : 0), // Add loading item if loading
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            if (index == notifications.length) {
              // Show loading indicator at the end
              return const Center(child: CircularProgressIndicator());
            }
            return ListTile(
              leading: const NotificationIcon(packageName: 'com.google.android.gms'),
              title: Text(notifications[index]['title']),
            );
          },
        ),
      ),
    );
  }
}
