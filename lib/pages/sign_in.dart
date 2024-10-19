import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prj3/controllers/snack_bar_controller.dart';
import 'package:prj3/controllers/user_controller.dart';
import 'package:prj3/pages/home.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserController _userController = Get.find(); // Get the UserController
  final MySnackbarController snackbarController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      snackbarController.showSnackbar('Error', e.toString());
      return null;
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
                onPressed: () async {
                  final user = await _signInWithGoogle();
                  if (user != null) {
                    // Sign-in successful
                    _userController.setUser(user);
                    print("Navigating to HomeScreen"); // Debugging statement
                    Get.to(() => HomeScreen());
                  } else {
                    print("User is null after sign-in"); // Debugging statement
                  }
                },
                child: const Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}