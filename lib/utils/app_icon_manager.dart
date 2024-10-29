// import 'package:prj3/utils/hot_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prj3/platform_channel.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

class AppIconManager {
  static const String _iconKeyPrefix = 'app_icon_';

  // Fetch app icon and cache it
  static Future<String?> fetchAndCacheAppIcon(String packageName) async {
    try {
      String? iconBase64 = await PlatformChannels.getAppIcon(packageName);
      if (iconBase64 != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(_iconKeyPrefix + packageName, iconBase64);
        return iconBase64;
      }

      return null;
    } catch (err) {
      // HotMessage.showToast('Error', err.toString());
      return null;
    }
  }

  // Retrieve cached app icon
  static Future<Image?> getCachedAppIcon(String packageName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? iconBase64 = prefs.getString(_iconKeyPrefix + packageName);

    if (iconBase64 != null) {
      Uint8List bytes = base64Decode(iconBase64);
      return Image.memory(bytes);
    }

    return null;
  }
}
