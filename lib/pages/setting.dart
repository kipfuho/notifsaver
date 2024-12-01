import 'package:flutter/material.dart';
import 'package:prj3/platform_channel.dart';

class ExclusiveAppSettingsPage extends StatefulWidget {
  const ExclusiveAppSettingsPage({super.key});

  @override
  State<ExclusiveAppSettingsPage> createState() =>
      _ExclusiveAppSettingsPageState();
}

class _ExclusiveAppSettingsPageState extends State<ExclusiveAppSettingsPage> {
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
        title: const Text("Manage Exclusive Apps"),
      ),
      body: allApps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allApps.length,
              itemBuilder: (context, index) {
                final appName = allApps[index];
                final isSelected = selectedApps.contains(appName);

                return ListTile(
                  title: Text(appName),
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
            ),
    );
  }
}
