import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  final user = Rx<User?>(null); // Reactive finaliable to hold the user state
  final syncStatus = 0.obs;

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