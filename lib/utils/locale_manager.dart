import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LocaleHelper {
  static const _localeKey = 'locale';

  // Save the selected locale to SharedPreferences
  static Future<void> saveLocale(Locale locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_localeKey, locale.toString());
  }

  // Load the saved locale from SharedPreferences
  static Future<Locale?> loadLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? localeString = prefs.getString(_localeKey);
    if (localeString != null) {
      final locale =
          Locale(localeString.split('_')[0], localeString.split('_')[1]);
      return locale;
    }
    return null; // Return null if no locale is saved
  }
}
