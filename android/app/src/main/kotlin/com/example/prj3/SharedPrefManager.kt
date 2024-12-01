package com.example.notifsaver

import android.content.Context
import org.json.JSONObject

object SharedPrefManager {
    private const val PREFS_NAME = "TempNotifications_notifsaver"
    private const val SETTING_NAME = "Setting_notifsaver"

    fun getUnprocessedNotifications(context: Context): List<String> {
        val sharedPrefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val allEntries = sharedPrefs.all
        val unprocessedNotifications = mutableListOf<String>()

        for ((_, value) in allEntries) {
            if (value is String) {
                unprocessedNotifications.add(value)
            }
        }

        return unprocessedNotifications
    }

    fun addNotification(context: Context, notificationJson: JSONObject) {
        val sharedPrefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = sharedPrefs.edit()
        val notificationId = notificationJson.getString("notificationId")
        editor.putString(notificationId, notificationJson.toString())
        editor.apply()
    }

    fun removeNotification(context: Context, notificationId: String) {
        val sharedPrefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = sharedPrefs.edit()
        editor.remove(notificationId)
        editor.apply()
    }

    fun getAllExclusiveApp(context: Context): List<String> {
        val _key = "exclusive_app"
        val sharedPrefs = context.getSharedPreferences(SETTING_NAME, Context.MODE_PRIVATE)
        val allExclusiveAppNameSet = sharedPrefs.getStringSet(_key, emptySet()) ?: emptySet()
        return allExclusiveAppNameSet
    }

    fun addExclusiveAppList(context: Context, packageName: String) {
        val _key = "exclusive_app"
        val sharedPrefs = context.getSharedPreferences(SETTING_NAME, Context.MODE_PRIVATE)
        val editor = sharedPrefs.edit()
        editor.putStringSet(_key, packageName)
        editor.apply()  // Apply the changes
    }
}