import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  var user = Rx<User?>(null); // Reactive variable to hold the user state
  var syncStatus = 0.obs;

  void startSyncData() {
    syncStatus.value = 1;
  }

  void finishSyncData() {
    syncStatus.value = 2;
  }

  void setUser(User? newUser) {
    user.value = newUser;
  }

  bool get isLoggedIn => user.value != null; // Check if user is logged in
}