package com.example.notifsaver

import android.os.Bundle
import android.content.Intent
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.notifsaver/notifications"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Safely unwrapping the binaryMessenger
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startNotificationListener") {
                // Assuming you have your NotificationListener class set up properly
                val notificationListener = NotificationListener() // Adjust this based on your class setup
                notificationListener.setResult(result) // Make sure this method exists in your class
            } else if (call.method == "openNotificationSettings") {
                openNotificationSettings()
                result.success("Opened Notification Settings")
            } else {
                result.notImplemented()
            }
        }
    }

    // Function to open the notification settings
    private fun openNotificationSettings() {
        val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
        startActivity(intent)
    }
}
