package com.example.notifsaver

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {
    private var result: MethodChannel.Result? = null

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val title = sbn.notification.extras.getString("android.title")
        val text = sbn.notification.extras.getString("android.text")

        Log.i("NotificationListener", "Notification posted from: $packageName")
        Log.i("NotificationListener", "Title: $title")
        Log.i("NotificationListener", "Text: $text")

        // Send the notification details to Flutter via Platform Channel
        result?.success("Title: $title, Text: $text, From: $packageName")
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        Log.i("NotificationListener", "Notification removed from: ${sbn.packageName}")
    }

    fun setResult(result: MethodChannel.Result) {
        this.result = result
    }
}