import 'package:flutter/material.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:prj3/google_service.dart';
import 'package:prj3/pages/home.dart';
import 'package:get/get.dart';
import 'package:prj3/utils/hot_message.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GoogleService _googleService = GoogleService();
  final UserController _userController = Get.find(); // Get the UserController

  @override
  void initState() {
    super.initState();
  }

  void _signInWithGoogle() async {
    try {
      final user = await _googleService.signInWithGoogle();
      if (user != null) {
        // Sign-in successful
        _userController.setUser(user);
        print("Navigating to HomeScreen"); // Debugging statement
        Get.to(() => HomeScreen());
      } else {
        print("User is null after sign-in"); // Debugging statement
      }
    } catch (err) {
      HotMessage.showToast('Error', err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notif Saver'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            bottom: 100.0), // Adjust this value to move it higher or lower
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centers content vertically
            children: <Widget>[
              const Text(
                'Login', // This is the login text
                style: TextStyle(
                  fontSize: 24, // You can adjust the font size
                  fontWeight: FontWeight.bold, // Make the text bold
                ),
              ),
              const SizedBox(
                  height: 20), // Adds space between the text and the button
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: const Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
