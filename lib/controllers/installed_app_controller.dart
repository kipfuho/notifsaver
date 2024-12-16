import 'package:prj3/platform_channel.dart';
import 'package:get/get.dart';

class InstalledAppController extends GetxController {
  final allApps = <String>[].obs;
  final settingSelectedApps = {}.obs;
  final displayAppName = {}.obs;

  @override
  void onInit() async {
    super.onInit();
    allApps.value = await PlatformChannels.getAppPackageNames();
    await _initSettingSelectedApp();
    await _loadDisplayNameForApps();
  }

  Future<void> _initSettingSelectedApp() async {
    List<String> inclusiveAppNames =
        await PlatformChannels.getAllInclusiveApp();
    for (var name in inclusiveAppNames) {
      settingSelectedApps[name] = true;
    }
  }

  Future<void> _loadDisplayNameForApps() async {
    for (var appName in allApps) {
      String displayName = await PlatformChannels.getAppName(appName);
      displayAppName[appName] = displayName;
    }
  }

  bool getSettingAppSelection(String appName) {
    return settingSelectedApps[appName] ?? false;
  }

  void setSettingAppSelection(String appName, bool selection) {
    settingSelectedApps[appName] = selection;
  }
}
