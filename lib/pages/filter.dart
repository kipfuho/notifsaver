import 'package:prj3/controllers/filter_controller.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'package:prj3/utils/app_manager.dart';
import 'package:prj3/platform_channel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final FilterController _filterController = Get.find();
  List<String> allApps = [];
  List<String> selectedApps = [];
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final appNames = await PlatformChannels.getAppPackageNames();
      setState(() {
        allApps = appNames;
        selectedApps = _filterController.getSearchApps();
        searchText = _filterController.getSearchText();
      });
    } catch (e) {
      print("Error loading apps: $e");
    }
  }

  void applyFilter() {
    _filterController.setSearchText(searchText);
    _filterController.setSearchApps(selectedApps);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search notification',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: searchText),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                itemCount: allApps.length,
                addAutomaticKeepAlives: true,
                itemBuilder: (context, index) {
                  final appName = allApps[index];
                  return FutureBuilder<String?>(
                    future: AppIconManager.getCachedAppName(appName),
                    builder: (context, snapshot) {
                      String displayName = appName;
                      if (snapshot.connectionState == ConnectionState.done) {
                        displayName = snapshot.data ?? appName;
                      }
                      return ListTile(
                        leading: NotificationIcon(packageName: appName),
                        title: Text(displayName),
                        trailing: Checkbox(
                          value: selectedApps.contains(appName),
                          onChanged: (bool? isChecked) {
                            setState(() {
                              if (isChecked == true) {
                                selectedApps.add(appName);
                              } else {
                                selectedApps.remove(appName);
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: FloatingActionButton(
                onPressed: () {
                  applyFilter(); // Call the applyFilter method before going back
                  Navigator.pop(context);
                },
                child: const Icon(Icons.search),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
