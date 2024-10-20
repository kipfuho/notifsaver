import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prj3/firebase_options.dart';
import 'package:get/get.dart';
import 'package:prj3/states_inject.dart';
import 'package:prj3/storages_inject.dart';

import 'pages/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inject Storage management
  StorageManagementInjection.init();

  // Inject states management
  StateManagementInjection.init();
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
