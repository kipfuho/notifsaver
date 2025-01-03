import 'package:prj3/controllers/installed_app_controller.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prj3/controllers/locale_controller.dart';
import 'package:prj3/widgets/notification_icon.dart';
import 'package:prj3/platform_channel.dart';
import 'package:prj3/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

part 'setting.ext.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale _currentLocale = const Locale('en', 'US');
  final LocaleController localeController = Get.find();
  final InstalledAppController settingController = Get.find();
  final UserController _userCtl = Get.find();

  @override
  void initState() {
    super.initState();
    _loadLocale();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Intl.message('settings_title', name: 'settings_title')),
          actions: [
            if (_userCtl.user.value != null)
              Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => ProfilePage());
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        NetworkImage(_userCtl.user.value!.photoURL ?? ''),
                  ),
                ),
              ),
          ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Intl.message(
                          'settings_selectLanguage',
                          name: 'settings_selectLanguage',
                        ),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 24),
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
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Intl.message('settings_inclusiveApps',
                  name: 'settings_inclusiveApps'),
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: settingController.allApps.length,
                  itemBuilder: (context, index) {
                    final appName = settingController.allApps[index];
                    return SingleSettingTile(index: index, appName: appName);
                  }),
            ),
          ],
        ));
  }
}
