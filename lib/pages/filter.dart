import 'package:prj3/controllers/filter_controller.dart';
import 'package:prj3/controllers/installed_app_controller.dart';
import 'package:prj3/models/log_model.dart';
import 'package:prj3/utils/hot_message.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final InstalledAppController _settingController = Get.find();
  final FilterController _filterController = Get.find();
  final selectedApps = <String, dynamic>{}.obs;
  String searchText = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      for (String appName in _filterController.getSearchApps()) {
        selectedApps[appName] = true;
      }
      setState(() {
        searchText = _filterController.getSearchText();
        startDate = _filterController.getStartDate();
        endDate = _filterController.getEndDate();
      });
    } catch (err) {
      HotMessage.showError(err.toString());
      LogModel.logError("Error loading apps: $err");
    }
  }

  void applyFilter() {
    _filterController.setSearchParams(
      searchText: searchText,
      selectedApps: selectedApps.keys.toList(),
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
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
            Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      startDate != null
                          ? "Start Date: ${startDate!.toLocal().toString().split(' ')[0]}"
                          : "Start Date: Not selected",
                    ),
                    Text(
                      endDate != null
                          ? "End Date: ${endDate!.toLocal().toString().split(' ')[0]}"
                          : "End Date: Not selected",
                    ),
                    ElevatedButton(
                      onPressed: _selectDateRange,
                      child: const Text("Select Date Range"),
                    ),
                  ],
                )),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                itemCount: _settingController.allApps.length,
                addAutomaticKeepAlives: true,
                itemBuilder: (context, index) {
                  final appName = _settingController.allApps[index];
                  return ListTile(
                    leading: NotificationIcon(packageName: appName),
                    title: Obx(() => Text(
                        _settingController.displayAppName[appName] ?? appName)),
                    trailing: Obx(() => Checkbox(
                          value: selectedApps[appName] ?? false,
                          onChanged: (bool? isChecked) {
                            selectedApps[appName] = isChecked;
                          },
                        )),
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
