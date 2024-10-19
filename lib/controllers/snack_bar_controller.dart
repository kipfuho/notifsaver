import 'package:get/get.dart';

class MySnackbarController extends GetxController {
  var isSnackbarVisible = false.obs;
  var title = ''.obs;   // New variable to hold the title
  var message = ''.obs; // Variable to hold the message

  void showSnackbar(String titleText, String msg) {
    title.value = titleText;  // Set the title
    message.value = msg;      // Set the message
    isSnackbarVisible.value = true;

    // Hide the snackbar after a set duration
    Future.delayed(const Duration(seconds: 3), () {
      isSnackbarVisible.value = false;
    });
  }
}