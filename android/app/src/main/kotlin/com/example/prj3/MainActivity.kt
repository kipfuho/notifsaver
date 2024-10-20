package com.example.notifsaver

import android.os.Bundle
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.notifsaver/notifications"
    private val STREAM_CHANNEL = "com.example.notifsaver/notificationStream"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Safely unwrapping the binaryMessenger
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openNotificationSettings") {
                openNotificationSettings()
                result.success("Opened Notification Settings")
            } else {
                result.notImplemented()
            }
        }

        // Set up the EventChannel to receive notification data
        EventChannel(flutterEngine!!.dartExecutor.binaryMessenger, STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    NotificationListener.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    NotificationListener.eventSink = null
                }
            }
        )
    }

    // Function to open the notification settings
    private fun openNotificationSettings() {
        val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
        startActivity(intent)
    }
}
