import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For persistence

class LocaleController extends GetxController {
  final _locale = const Locale('en', 'US').obs; // Default locale

  @override
  void onInit() async {
    super.onInit();
    await loadLocale(); // Load saved locale when controller is initialized
  }

  // Load locale from shared preferences (or any other persistence mechanism)
  Future<void> loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString('locale');
    print(savedLocale);
    if (savedLocale != null) {
      List<String> localeParts = savedLocale.split('_');
      _locale.value = Locale(localeParts[0], localeParts.length > 1 ? localeParts[1] : '');
      Get.updateLocale(_locale.value);
    }
  }

  // Change the app's locale
  Future<void> changeLocale(String languageCode, String? countryCode) async {
    // Update the locale
    _locale.value = Locale(languageCode, countryCode);

    // Save the new locale to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', '${languageCode}_$countryCode');

    // Apply the new locale to the app
    Get.updateLocale(_locale.value);
  }
}
