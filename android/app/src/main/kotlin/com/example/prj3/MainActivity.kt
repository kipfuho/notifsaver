package com.example.notifsaver

import io.flutter.embedding.android.FlutterActivity
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.graphics.drawable.Drawable
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import java.io.ByteArrayOutputStream
import android.graphics.Bitmap
import android.graphics.Canvas
import android.content.Intent
import android.util.Base64
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.notifsaver/notifications"
    private val STREAM_CHANNEL = "com.example.notifsaver/notificationStream"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Safely unwrapping the binaryMessenger
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success("Opened Notification Settings")
                }
                "getUnprocessedNotificationsFromTempStorage" -> {
                    val unprocessedNotifications = SharedPrefManager.getUnprocessedNotifications(this)
                    result.success(unprocessedNotifications)
                }
                "removeNotificationFromTempStorage" -> {
                    val notificationId = call.argument<String>("notificationId")
                    notificationId?.let { SharedPrefManager.removeNotification(this, it) }
                    result.success(null)
                }
                "getAppIcon" -> {
                    val packageName = call.arguments as String
                    val icon = getAppIcon(packageName)
                    if (icon != null) {
                        result.success(icon)
                    } else {
                        result.error("UNAVAILABLE", "App icon not available.", null)
                    }
                }
                "getApplicationPackageNames" -> {
                    val packagesThatCanSendNotifications = getPackagesThatCanSendNotifications()
                    if (packagesThatCanSendNotifications) {
                        result.success(packagesThatCanSendNotifications)
                    } else {
                        result.error("UNAVAILABLE", "App package name not available.", null)
                    }
                }
                "getExclusiveApps" -> {
                    val exclusiveApps = SharedPrefManager.getAllExclusiveApp(this)
                    result.success(exclusiveApps.toList())
                }
                "addExclusiveApp" -> {
                    val packageName = call.arguments as String
                    SharedPrefManager.addExclusiveAppList(this, packageName)
                    result.success(null)
                }
                "removeExclusiveApp" -> {
                    val packageName = call.arguments as String
                    SharedPrefManager.removeExclusiveAppList(this, packageName)
                    result.success(null)
                }
                else -> result.notImplemented()
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

    private fun getAppIcon(packageName: String): String? {
        return try {
            // Get ApplicationInfo for the specified package
            val appInfo: ApplicationInfo = this.packageManager.getApplicationInfo(packageName, 0)

            // Get the app icon as a Drawable
            val icon: Drawable = this.packageManager.getApplicationIcon(appInfo)

            // Convert the Drawable to a Bitmap
            val bitmap = when (icon) {
                is BitmapDrawable -> icon.bitmap
                is AdaptiveIconDrawable -> {
                    // Create a Bitmap and draw the AdaptiveIconDrawable onto it
                    val bitmap = Bitmap.createBitmap(
                        icon.intrinsicWidth,
                        icon.intrinsicHeight,
                        Bitmap.Config.ARGB_8888
                    )
                    val canvas = Canvas(bitmap)
                    icon.setBounds(0, 0, canvas.width, canvas.height)
                    icon.draw(canvas)
                    bitmap
                }
                else -> {
                    Log.e("getAppIcon", "Icon is not a supported Drawable type: ${icon.javaClass.simpleName}")
                    return null // Return null if the icon cannot be processed
                }
            }

            // Convert Bitmap to Base64 String if bitmap is not null
            val byteArrayOutputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
            val byteArray = byteArrayOutputStream.toByteArray()
            
            Base64.encodeToString(byteArray, Base64.NO_WRAP)
        } catch (e: PackageManager.NameNotFoundException) {
            Log.e("getAppIcon", "Application not found: ${e.message}")
            null
        } catch (e: Exception) {
            Log.e("getAppIcon", "Error retrieving app icon: ${e.message}", e)
            null
        }
    }

    fun getPackagesThatCanSendNotifications(): List<String> {
        try {
            val packageManager = this.packageManager
            val installedPackages = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
            val notificationManager = this.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            val packagesThatCanSendNotifications = mutableListOf<String>()
            for (app in installedPackages) {
                val packageName = app.packageName
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                val canSendNotifications = notificationManager.areNotificationsEnabledForPackage(packageName, appInfo.uid)

                if (canSendNotifications) {
                    packagesThatCanSendNotifications.add(packageName)
                }
            }

            return packagesThatCanSendNotifications
        } catch (e: Exception) {
            Log.e("getPackagesThatCanSendNotifications", "Error retrieving app icon: ${e.message}", e)
            null
        }
    }
}
