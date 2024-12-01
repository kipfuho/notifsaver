package com.example.notifsaver

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.pm.PackageManager
import org.json.JSONObject
import android.util.Log

class NotificationListener : NotificationListenerService() {
    private var result: MethodChannel.Result? = null
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val exclusiveApps = SharedPrefManager.getAllExclusiveApp(this)
        // check if allow save notification
        if (exclusiveApps?.contains(packageName) == true) return

        val appName = getAppName(packageName)
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
        val notificationChannelId = notification.channelId ?: "DefaultChannel"
        val notificationId = "$postTime#${packageName}#${sbn.id}"
        val status = "unread"

        // Create JSON object with all the notification details
        val notificationDetails = JSONObject().apply {
            put("notificationId", notificationId)
            put("packageName", packageName)
            put("appName", appName)
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
            put("status", status)
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

    private fun getAppName(packageName: String): String {
        return try {
            val packageManager = applicationContext.packageManager
            val appInfo = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
            "Unknown App"
        }
    }
}