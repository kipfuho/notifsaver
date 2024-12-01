import 'package:flutter/material.dart';
import 'package:prj3/platform_channel.dart';
import 'package:prj3/utils/app_manager.dart';
import 'package:prj3/widgets/notification_icon.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> allApps = [];
  List<String> exclusiveApps = [];
  List<String> selectedApps = [];

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  Future<void> _loadAppData() async {
    try {
      final appNames = await PlatformChannels.getAppPackageNames();
      final exclusiveAppNames = await PlatformChannels.getAllExclusiveApp();

      setState(() {
        allApps = appNames;
        exclusiveApps = exclusiveAppNames;
        selectedApps = List.from(exclusiveApps);
      });
    } catch (e) {
      print("Error loading apps: $e");
    }
  }

  void _toggleAppSelection(String packageName, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedApps.add(packageName);
        PlatformChannels.addExclusiveApp(packageName);
      } else {
        selectedApps.remove(packageName);
        PlatformChannels.removeExclusiveApp(packageName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Setting"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                      height: 8), // Add space between label and button
                  // Button
                  ElevatedButton(
                    onPressed: () {
                      // Add your button's action here
                      print("Button Pressed!");
                    },
                    child: const Text('Open notifications permission setting'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Exclusive apps',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: allApps.length,
                  itemBuilder: (context, index) {
                    final appName = allApps[index];
                    final isSelected = selectedApps.contains(appName);

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
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value != null) {
                                _toggleAppSelection(appName, value);
                              }
                            },
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ));
  }
}
