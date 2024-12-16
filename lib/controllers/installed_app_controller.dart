import 'package:prj3/platform_channel.dart';
import 'package:get/get.dart';

class InstalledAppController extends GetxController {
  final allApps = <String>[].obs;
  final settingSelectedApps = {}.obs;

  @override
  void onInit() async {
    super.onInit();
    allApps.value = await PlatformChannels.getAppPackageNames();
    await _initSettingSelectedApp();
  }

  Future<void> _initSettingSelectedApp() async {
    List<String> inclusiveAppNames =
        await PlatformChannels.getAllInclusiveApp();
    for (var name in inclusiveAppNames) {
      settingSelectedApps[name] = true;
    }
  }

  bool getSettingAppSelection(String appName) {
    return settingSelectedApps[appName] ?? false;
  }

  void setSettingAppSelection(String appName, bool selection) {
    settingSelectedApps[appName] = selection;
  }
}
