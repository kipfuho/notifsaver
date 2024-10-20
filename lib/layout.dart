import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonLayout extends StatelessWidget {
  final String title;
  final Widget body;

  const CommonLayout({Key? key, required this.title, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation tap
          if (index == 0) {
            // Navigate to Home
            Get.offNamed('/home'); // Example: replace with your home route
          } else if (index == 1) {
            // Navigate to Settings
            Get.offNamed('/settings'); // Example: replace with your settings route
          }
        },
      ),
    );
  }
}