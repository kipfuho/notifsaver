import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:prj3/pages/sign_in.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final UserController _userController = Get.find(); // Get the UserController

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    if (_userController.user.value == null) {
      // If no user is found, navigate to the sign-in screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.to(() => const SignInScreen());
      });
      return const SizedBox.shrink(); // Return an empty widget while redirecting
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
                await FirebaseAuth.instance.signOut();
                _userController.setUser(null); // Clear the user in UserController
                Get.to(() => const SignInScreen()); // Navigate back to sign-in page
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
