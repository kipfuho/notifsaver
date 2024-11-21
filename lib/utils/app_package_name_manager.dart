// import 'package:prj3/utils/hot_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prj3/platform_channel.dart';

class AppPackageNameManager {
  static const String _allAppKey = 'app_package_name';

  // Fetch all app package names and cache it
  static Future<List<String>> fetchAndCacheAllAppPackageName() async {
    try {
      List<String> appNames = await PlatformChannels.getAppPackageNames();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_allAppKey, appNames);

      return appNames;
    } catch (err) {
      // HotMessage.showToast('Error', err.toString());
      return [];
    }
  }

  static Future<List<String>> getCachedAllAppPackageName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? appNames = prefs.getStringList(_allAppKey);
    if (appNames != null) {
      return appNames;
    }
    return [];
  }

  static Future<bool> clearAllAppNameCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.remove(_allAppKey);
    return result;
  }

  // get all app package names that do not wish to receive notification
  static Future<List<String>> getExclusiveAppFromCache() async {
    try {
      List<String> appNames = await PlatformChannels.getAllExclusiveApp();
      return appNames;
    } catch (err) {
      // HotMessage.showToast('Error', err.toString());
      return [];
    }
  }

  static Future<void> addNewAppToExclusiveList(packageName) async {
    await PlatformChannels.addExclusiveApp(packageName);
    return;
  }
}
