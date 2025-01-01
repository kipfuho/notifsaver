class AppConstants {
  // Define your notification types here
  static const String logs = 'logs';
  static const String logInfo = 'info';
  static const String logError = 'error';

  static String getHiveBoxName({DateTime? date}) {
    DateTime now = date ?? DateTime.now();
    // Format the box name as "notifications_YYYY_MM"
    var boxName =
        'notifications_${now.year}_${now.month.toString().padLeft(2, '0')}';
    return boxName;
  }
}
