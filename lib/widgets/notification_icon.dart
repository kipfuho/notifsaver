import 'package:flutter/material.dart';
import 'package:prj3/utils/app_icon_manager.dart';

class NotificationIcon extends StatelessWidget {
  final String packageName;

  const NotificationIcon({super.key, required this.packageName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image?>(
      future: AppIconManager.getCachedAppIcon(packageName), // Get cached icon
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            backgroundColor: Colors.purple,
            child: CircularProgressIndicator(), // Placeholder while loading
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return CircleAvatar(
            backgroundColor: Colors.transparent,
            child: snapshot.data!, // Display the cached icon
          );
        } else {
          // Fetch and cache the icon if not available
          AppIconManager.fetchAndCacheAppIcon(packageName);
          return const CircleAvatar(
            backgroundColor: Colors.purple,
            child: Icon(Icons.android), // Fallback icon
          );
        }
      },
    );
  }
}