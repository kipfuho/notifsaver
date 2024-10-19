import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prj3/controllers/notification_controller.dart';
import 'package:prj3/controllers/snack_bar_controller.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:prj3/firebase_options.dart';
import 'package:prj3/pages/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(UserController()); // Initialize UserController
  Get.put(MySnackbarController());
  Get.put(NotificationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: SignInScreen(),
    );
  }
}
