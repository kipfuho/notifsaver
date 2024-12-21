import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  static Future<void> writeSecureStorage(String key, String? value) async {
    secureStorage.write(key: key, value: value);
  }

  static Future<void> deleteSecureStorage(String key) async {
    secureStorage.delete(key: key);
  }

  static Future<String?> readSecureStorage(String key) async {
    String? value = await secureStorage.read(key: key);
    return value;
  }
}
