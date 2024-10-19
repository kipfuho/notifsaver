import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prj3/controllers/snack_bar_controller.dart';

class SnackbarWidget extends StatelessWidget {
  SnackbarWidget({super.key});
  final MySnackbarController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isSnackbarVisible.value) {
        return const SizedBox.shrink(); // Don't show anything if not visible
      }

      // Show the Snackbar using the ScaffoldMessenger
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.title.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(controller.message.value),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      });

      return const SizedBox.shrink(); // Don't show anything in the widget tree
    });
  }
}
