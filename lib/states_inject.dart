import 'package:prj3/controllers/installed_app_controller.dart';
import 'package:prj3/controllers/network_controller.dart';
import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/controllers/locale_controller.dart';
import 'package:prj3/controllers/filter_controller.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:get/get.dart';

class StateManagementInjection {
  // Method to initialize all controllers and other dependencies
  static void init() {
    // Initialize UserController
    Get.put(UserController());

    // Initialize NotificationController
    Get.put(NotificationController());

    // Initialize LocaleController
    Get.put(LocaleController());

    // Initialize FilterController
    Get.put(FilterController());

    // Initialize FilterController
    Get.put(InstalledAppController());

    // Initialize FilterController
    Get.put(NetworkController());
  }
}
