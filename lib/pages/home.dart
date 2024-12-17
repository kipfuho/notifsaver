import 'package:prj3/controllers/filter_controller.dart';
import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/pages/filter.dart';
import 'package:prj3/widgets/notification_list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prj3/pages/setting.dart';
import 'package:flutter/material.dart';
import 'package:prj3/constant.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationController notificationController = Get.find();
  final FilterController filterController = Get.find();
  int _selectedIndex = 0; // Track the selected tab

  // Define the different pages for the BottomNavigationBar
  final List<Widget> _pages = [
    const NotificationList(notificationType: 'unread'),
    const NotificationList(notificationType: 'read'),
    const NotificationList(notificationType: 'saved'),
  ];

  // Method to print all Hive data
  Future<void> printHiveData() async {
    var box = await Hive.openBox(AppConstants.getHiveBoxName());
    var keys = box.keys;

    for (var key in keys) {
      var value = box.get(key);
      print('Key: $key, Value: $value');
    }

    // await box.close();
  }

  // Method to delete the Hive box
  Future<void> deleteHiveBox() async {
    var box = await Hive.openBox(AppConstants.getHiveBoxName());
    await box.deleteFromDisk();
    // await box.close();
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
        automaticallyImplyLeading: false, // Hide back button
        title: Text(Intl.message('home', name: 'home')),
        actions: [
          IconButton(
            icon: Icon(filterController.isSearching.value
                ? Icons.close
                : Icons.search),
            onPressed: () {
              if (filterController.isSearching.value) {
                filterController.clearSearch();
              } else {
                Get.to(() => const FilterScreen());
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(() => const SettingsPage());
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
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.markunread),
            label: Intl.message('unread', name: 'unread'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.done),
            label: Intl.message('read', name: 'read'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.save),
            label: Intl.message('saved', name: 'saved'),
          ),
        ],
      ),
    );
  }
}
