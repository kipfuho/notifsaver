import 'package:get/get.dart';
import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:prj3/controllers/locale_controller.dart';

class StateManagementInjection {
  // Method to initialize all controllers and other dependencies
  static void init() {
    // Initialize UserController
    Get.put(UserController());

    // Initialize NotificationController
    Get.put(NotificationController());

    // Initialize LocaleController
    Get.put(LocaleController());
  }
}
