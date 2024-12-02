import 'package:shared_preferences/shared_preferences.dart';
import 'package:prj3/controllers/locale_controller.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'package:prj3/utils/app_manager.dart';
import 'package:prj3/platform_channel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> allApps = [];
  List<String> exclusiveApps = [];
  List<String> selectedApps = [];
  Locale _currentLocale = const Locale('en', 'US');
  final LocaleController localeController = Get.find();

  @override
  void initState() {
    super.initState();
    _loadAppData();
    _loadLocale();
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

  Future<void> _loadLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? localeString = prefs.getString('locale');
    if (localeString != null) {
      final localeParts = localeString.split('_');
      setState(() {
        _currentLocale = Locale(localeParts[0], localeParts[1]);
      });
    }
  }

  Future<void> _saveLocale(Locale locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', locale.toString());
    localeController.changeLocale(locale.languageCode, locale.countryCode);
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
          title: Text(Intl.message('settings_title', name: 'settings_title')),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Button to open notifications permission setting
                  ElevatedButton(
                    onPressed: () {
                      PlatformChannels.openNotificationSettings();
                    },
                    child: Text(Intl.message('settings_openNotificationSetting',
                        name: 'settings_openNotificationSetting')),
                  ),
                  const SizedBox(height: 16),
                  // Language Selector Dropdown
                  Text(
                    Intl.message('settings_selectLangugage',
                        name: 'settings_selectLangugage'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  DropdownButton<Locale>(
                    value: _currentLocale,
                    onChanged: (Locale? newLocale) async {
                      if (newLocale != null) {
                        setState(() {
                          _currentLocale = newLocale;
                        });
                        await _saveLocale(newLocale);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en', 'US'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: Locale('vi', 'VN'),
                        child: Text('Việt Nam'),
                      ),
                      // Add other languages here
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Intl.message('settings_exclusiveApps',
                  name: 'settings_exclusiveApps'),
              style: const TextStyle(
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
