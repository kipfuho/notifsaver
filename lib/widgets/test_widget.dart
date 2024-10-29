import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppIconFetcher extends StatefulWidget {
  final String packageName;

  AppIconFetcher({required this.packageName});

  @override
  _AppIconFetcherState createState() => _AppIconFetcherState();
}

class _AppIconFetcherState extends State<AppIconFetcher> {
  static const platform = MethodChannel('com.example.notifsaver/notifications');
  Uint8List? appIcon;

  @override
  void initState() {
    super.initState();
    _fetchAppIcon(widget.packageName);
  }

  Future<void> _fetchAppIcon(String packageName) async {
    try {
      final String base64Icon = await platform.invokeMethod('getAppIcon', packageName);
      setState(() {
        appIcon = base64Decode(base64Icon);
      });
    } on PlatformException catch (e) {
      print("Failed to get app icon: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Icon')),
      body: Center(
        child: appIcon != null
            ? Image.memory(appIcon!)
            : CircularProgressIndicator(),
      ),
    );
  }
}
