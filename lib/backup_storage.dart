import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';  // For accessing local storage
import 'dart:convert';  // For encoding/decoding JSON

class BackupService {
  // Method to export data from Hive to a JSON file
  Future<File?> exportHiveData() async {
    try {
      // Get the Hive box
      var box = await Hive.openBox('notificationsBox');

      // Get the app's local directory (where the backup file will be saved)
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // Create a map of all the data in the Hive box
      Map<String, dynamic> backupData = {};
      for (int i = 0; i < box.length; i++) {
        backupData[i.toString()] = box.getAt(i);
      }

      // Convert the map to a JSON string
      String jsonString = jsonEncode(backupData);

      // Create a file and write the JSON data
      File file = File('$appDocPath/hive_backup.json');
      await file.writeAsString(jsonString);

      print('Data exported to: ${file.path}');
      return file;
    } catch (e) {
      print('Failed to export data: $e');
      return null;
    }
  }
}