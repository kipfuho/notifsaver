import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/widgets/notification_list.dart';
import 'package:prj3/constant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationController notificationController = Get.find();
  int _selectedIndex = 0; // Track the selected tab

  // Define the different pages for the BottomNavigationBar
  final List<Widget> _pages = [
    const NotificationList(notificationType: AppConstants.unreadNotifications),
    const NotificationList(notificationType: AppConstants.readNotifications),
    const NotificationList(notificationType: AppConstants.savedNotifications),
  ];

  // Method to print all Hive data
  Future<void> printHiveData() async {
    var box = await Hive.openBox('notificationsBox');
    var keys = box.keys;

    for (var key in keys) {
      var value = box.get(key);
      print('Key: $key, Value: $value');
    }
  }

  // Method to delete the Hive box
  Future<void> deleteHiveBox() async {
    var box = await Hive.openBox('notificationsBox');
    await box.deleteFromDisk();
  }

  // Handle BottomNavigationBar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              notificationController.openNotificationSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => Text(
              'Notification Data: ${notificationController.notificationData}')),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: printHiveData,
                child: const Text('Print Hive Data'),
              ),
              ElevatedButton(
                onPressed: deleteHiveBox,
                child: const Text('Delete Hive Data'),
              ),
            ],
          ),
          Expanded(child: _pages[_selectedIndex]), // Display the selected page
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.markunread),
            label: 'Unread',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Read',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
