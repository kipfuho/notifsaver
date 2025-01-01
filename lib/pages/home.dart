import 'package:prj3/controllers/filter_controller.dart';
import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:prj3/jobs_inject.dart';
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
  final UserController _userCtl = Get.find();
  int _selectedIndex = 0; // Track the selected tab

  // Define the different pages for the BottomNavigationBar
  final List<Widget> _pages = [
    const NotificationList(notificationType: 'unread'),
    const NotificationList(notificationType: 'read'),
    const NotificationList(notificationType: 'saved'),
  ];

  // Method to print all Hive data
  Future<void> printHiveData() async {
    var currentDate = DateTime.now();
    for (int i = 0; i < 5; i += 1) {
      print(AppConstants.getHiveBoxName(date: currentDate));
      var box =
          await Hive.openBox(AppConstants.getHiveBoxName(date: currentDate));
      currentDate = DateTime(
        currentDate.month == 1 ? currentDate.year - 1 : currentDate.year,
        currentDate.month == 1 ? 12 : currentDate.month - 1,
        currentDate.day,
      );
      var keys = box.keys;

      for (var key in keys) {
        var value = box.get(key);
        print('Key: $key, Value: $value');
      }
    }

    // await box.close();
  }

  // Method to delete the Hive box
  Future<void> deleteHiveBox() async {
    var currentDate = DateTime.now();
    for (int i = 0; i < 5; i += 1) {
      print(AppConstants.getHiveBoxName(date: currentDate));
      var box =
          await Hive.openBox(AppConstants.getHiveBoxName(date: currentDate));
      currentDate = DateTime(
        currentDate.month == 1 ? currentDate.year - 1 : currentDate.year,
        currentDate.month == 1 ? 12 : currentDate.month - 1,
        currentDate.day,
      );
      await box.deleteFromDisk();
    }
    // await box.close();
  }

  // Handle BottomNavigationBar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void testFunction() {
    syncData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            _userCtl.user.value == null, // Hide back button
        title: Text(Intl.message('home', name: 'home')),
        actions: [
          IconButton(
            icon: Obx(() => Icon(filterController.isSearching.value
                ? Icons.close
                : Icons.search)),
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
              ElevatedButton(
                onPressed: () {
                  notificationController.addNotificationForTest();
                },
                child: const Text('Add Data'),
              ),
              ElevatedButton(
                onPressed: () {
                  testFunction();
                },
                child: const Text('Test Function'),
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
