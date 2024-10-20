package com.example.notifsaver

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {
    private var result: MethodChannel.Result? = null
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val notificationId = sbn.id
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

        // Log all the notification data
        Log.i("NotificationListener", """
            Notification posted from: $packageName
            Notification ID: $notificationId
            Tag: $tag
            Post Time: $postTime
            Title: $title
            Text: $text
            SubText: $subText
            BigText: $bigText
            Category: $category
            TickerText: $tickerText
            Priority: $notificationPriority
            Channel ID: $notificationChannelId
        """)

        // Send all the data to Flutter via EventChannel
        val notificationDetails = """
            Package: $packageName
            ID: $notificationId
            Tag: $tag
            Post Time: $postTime
            Title: $title
            Text: $text
            SubText: $subText
            BigText: $bigText
            Category: $category
            TickerText: $tickerText
            Priority: $notificationPriority
            Channel ID: $notificationChannelId
        """.trimIndent()

        eventSink?.success(notificationDetails)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        Log.i("NotificationListener", "Notification removed from: ${sbn.packageName}")
    }

    fun setEventSink(eventSink: EventChannel.EventSink) {
        NotificationListener.eventSink = eventSink
    }
}