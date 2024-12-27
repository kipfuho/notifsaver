import 'package:prj3/controllers/snack_bar_controller.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prj3/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final UserController _userController = Get.find();
  final MySnackbarController _snackbarController = Get.find();

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    if (_userController.user.value == null) {
      // If no user is found, navigate to the sign-in screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.to(() => const SignInScreen());
      });
      return const SizedBox.shrink();
    }

    final user = _userController.user.value!; // Get the logged-in user

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.photoURL ?? ''),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? 'No Email',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_userController.syncStatus.value == 1) {
                  _snackbarController.showSnackbar(
                    Intl.message('error', name: 'error'),
                    Intl.message('sync_in_progress_message',
                        name: 'sync_in_progress_message'),
                  );
                  return;
                }
                print('start register');
                Workmanager().registerOneOffTask(
                  "4",
                  "syncData",
                );
              },
              child: Obx(
                () {
                  if (_userController.syncStatus.value == 1) {
                    return CircularProgressIndicator();
                  } else if (_userController.syncStatus.value == 2) {
                    return Text(Intl.message('sync_done', name: 'sync_done'));
                  } else {
                    return Text(Intl.message('sync_data', name: 'sync_data'));
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                _userController.setUser(null);
                Get.to(() => const SignInScreen());
              },
              child: Text(Intl.message('sign_out', name: 'sign_out')),
            ),
          ],
        ),
      ),
    );
  }
}
