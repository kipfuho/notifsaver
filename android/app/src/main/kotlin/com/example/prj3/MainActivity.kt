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
import android.content.Context
import android.content.Intent
import android.util.Base64
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.notifsaver/notifications"
    private val STREAM_CHANNEL = "com.example.notifsaver/notificationStream"

    private val NOT_INCLUDE_PACKAGE_MAP
     = mutableMapOf<String,Boolean>(
        "android" to true,
        "com.android.providers.telephony" to true,
        "com.android.providers.calendar" to true,
        "com.android.providers.downloads" to true,
        "com.google.android.soundpicker" to true,
        "com.google.android.providers.media.module" to true,
        "com.android.providers.downloads.ui" to true,
        "com.google.android.adservices.api" to true,
        "com.google.android.marvin.talkback" to true,
        "com.android.egg" to true,
        "com.android.nfc" to true,
        "com.google.android.as" to true,
        "com.google.android.permissioncontroller" to true,
        "com.google.android.bluetooth" to true,
        "com.android.providers.settings" to true,
        "com.android.printspooler" to true,
        "com.android.bips" to true,
        "com.google.android.captiveportallogin" to true,
        "com.android.musicfx" to true,
        "com.google.android.markup" to true,
        "com.android.server.telecom" to true,
        "com.google.android.packageinstaller" to true,
        "com.google.android.tag" to true,
        "com.google.android.tts" to true,
        "com.android.carrierdefaultapp" to true,
        "com.android.credentialmanager" to true,
        "com.android.devicediagnostics" to true,
        "com.android.wallpaper.livepicker" to true,
        "com.google.android.healthconnect.controller" to true,
        "com.google.android.gms.supervision" to true,
        "com.android.storagemanager" to true,
        "com.android.bookmarkprovider" to true,
        "com.google.android.settings.intelligence" to true,
        "com.android.wallpaper" to true,
        "com.google.android.apps.wallpaper" to true,
        "com.android.phone" to true,
        "com.android.systemui" to true,
        "com.android.traceur" to true,
        "com.google.android.cellbroadcastreceiver" to true,
        "com.android.bluetooth" to true,
        "com.google.android.apps.restore" to true
    )

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
                "getAppName" -> {
                    val packageName = call.arguments as String
                    val appName = getAppName(packageName)
                    result.success(appName)
                }
                "getApplicationPackageNames" -> {
                    val allPackageNames = getAllPackageNames()
                    if (allPackageNames.isNotEmpty()) {
                        result.success(allPackageNames)
                    } else {
                        result.error("UNAVAILABLE", "App package name not available.", null)
                    }
                }
                "getInclusiveApps" -> {
                    val inclusiveApps = SharedPrefManager.getAllInclusiveApp(this)
                    result.success(inclusiveApps.toList())
                }
                "addInclusiveApp" -> {
                    val packageName = call.arguments as String
                    SharedPrefManager.addInclusiveAppList(this, packageName)
                    result.success(null)
                }
                "removeInclusiveApp" -> {
                    val packageName = call.arguments as String
                    SharedPrefManager.removeInclusiveAppList(this, packageName)
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

    private fun getAppName(packageName: String): String {
        return try {
            val appInfo: ApplicationInfo = this.packageManager.getApplicationInfo(packageName, 0)
            val appName: CharSequence = this.packageManager.getApplicationLabel(appInfo)
            appName.toString()
        } catch (e: PackageManager.NameNotFoundException) {
            Log.e("getAppName", "Application not found: ${e.message}")
            packageName
        } catch (e: Exception) {
            Log.e("getAppName", "Error retrieving app name: ${e.message}", e)
            packageName
        }
    }

    fun getAllPackageNames(): List<String> {
        try {
            val packageManager = this.packageManager
            val installedPackages = packageManager.getInstalledPackages(PackageManager.GET_PERMISSIONS)

            val allPackages = mutableListOf<Pair<String, String>>()
            // Filter out unappropriate packages
            for (app in installedPackages) {
                val packageName = app.packageName
                if (NOT_INCLUDE_PACKAGE_MAP[packageName] == true) {
                    continue
                }
                val appName = getAppName(packageName)
                val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
                if (appName != null && appName != packageName && appName != "Filled" && applicationInfo.icon != 0) {
                    allPackages.add(packageName to appName)
                }
            }
            // Log.d("getAllPackageNames", "All package names: $allPackages")
            allPackages.sortBy { it.second }
            return allPackages.map { it.first }
        } catch (e: Exception) {
            Log.e("getAllPackageNames", "Error retrieving app icon: ${e.message}", e)
            return mutableListOf<String>()
        }
    }
}
