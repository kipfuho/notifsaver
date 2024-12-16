part of 'setting.dart';

class SingleSettingTile extends StatelessWidget {
  final int index;
  final String appName;
  final InstalledAppController settingController;

  SingleSettingTile({
    super.key,
    required this.index,
    required this.appName,
    InstalledAppController? settingController,
  }) : settingController = settingController ?? Get.find();

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            NotificationIcon(packageName: appName),
          ],
        ),
        title: Obx(
            () => Text(settingController.displayAppName[appName] ?? appName)),
        trailing: Obx(
          () => Checkbox(
            value: settingController.settingSelectedApps[appName] ?? false,
            onChanged: (bool? value) {
              settingController.setSettingAppSelection(appName, value ?? false);
            },
          ),
        ));
  }
}
