package com.example.notifsaver

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class NotificationListener : NotificationListenerService() {
    private var result: MethodChannel.Result? = null
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val tag = sbn.tag ?: "No tag"
        val postTime = sbn.postTime
        val notification = sbn.notification
        val extras = notification.extras

        // Extracting notification details
        val title = extras.getString("android.title", "No Title")
        val text = extras.getString("android.text", "No Text")
        val subText = extras.getString("android.subText", "No SubText")
        val bigText = extras.getString("android.bigText", "No BigText")
        val category = notification.category ?: "No Category"
        val tickerText = notification.tickerText?.toString() ?: "No TickerText"
        val notificationPriority = notification.priority
        val notificationChannelId = notification.channelId
        val notificationId = "${packageName}#${sbn.id}#$postTime"


        // Create JSON object with all the notification details
        val notificationDetails = JSONObject().apply {
            put("packageName", packageName)
            put("notificationId", notificationId)
            put("tag", tag)
            put("postTime", postTime)
            put("title", title)
            put("text", text)
            put("subText", subText)
            put("bigText", bigText)
            put("category", category)
            put("tickerText", tickerText)
            put("priority", notificationPriority)
            put("channelId", notificationChannelId)
        }

        // Log JSON data for debugging
        Log.i("NotificationListener", "Notification posted: $notificationDetails")

        // Save notification to temporary storage
        SharedPrefManager.addNotification(this, notificationDetails)

        // Send JSON data to Flutter via EventChannel
        eventSink?.success(notificationDetails.toString())
    }

    fun removeNotificationFromTempStorage(notificationId: String) {
        SharedPrefManager.removeNotification(this, notificationId)
    }

    fun getUnprocessedNotificationsFromTempStorage(): List<String> {
        return SharedPrefManager.getUnprocessedNotifications(this)
    }
}