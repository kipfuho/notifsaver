import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  var user = Rx<User?>(null); // Reactive variable to hold the user state

  void setUser(User? newUser) {
    user.value = newUser;
  }

  bool get isLoggedIn => user.value != null; // Check if user is logged in
}