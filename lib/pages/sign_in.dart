import 'package:prj3/controllers/user_controller.dart';
import 'package:prj3/utils/hot_message.dart';
import 'package:prj3/google_service.dart';
import 'package:flutter/material.dart';
import 'package:prj3/pages/home.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GoogleService _googleService = GoogleService();
  final UserController _userController = Get.find();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await _googleService.signInWithGoogle();
      if (user != null) {
        // Sign-in successful
        _userController.setUser(user);
        print("Navigating to HomeScreen"); // Debugging statement
        Get.to(() => const HomeScreen());
      } else {
        print("User is null after sign-in"); // Debugging statement
      }
    } catch (err) {
      HotMessage.showToast('Error', err.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notif Saver'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Intl.message('login', name: 'login'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading) const CircularProgressIndicator(),
              if (!isLoading)
                ElevatedButton(
                  onPressed: _signInWithGoogle,
                  child:
                      Text(Intl.message('login_google', name: 'login_google')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
