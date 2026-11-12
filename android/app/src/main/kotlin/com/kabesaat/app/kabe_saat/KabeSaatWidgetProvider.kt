package com.kabesaat.app.kabe_saat

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class KabeSaatWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        const val PREFS_NAME = "KabeSaatWidgetPrefs"

        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val cityName = prefs.getString("city_name", "İstanbul") ?: "İstanbul"
            val nextName = prefs.getString("next_name", "AKŞAM VAKTİ") ?: "AKŞAM VAKTİ"
            val nextTime = prefs.getString("next_time", "18:04") ?: "18:04"
            val countdown = prefs.getString("countdown", "Vaktin girmesine az kaldı") ?: "Vaktin girmesine az kaldı"
            
            val timeImsak = prefs.getString("time_imsak", "06:05") ?: "06:05"
            val timeOgle = prefs.getString("time_ogle", "12:53") ?: "12:53"
            val timeIkindi = prefs.getString("time_ikindi", "15:47") ?: "15:47"
            val timeAksam = prefs.getString("time_aksam", "18:04") ?: "18:04"
            val timeYatsi = prefs.getString("time_yatsi", "19:26") ?: "19:26"

            val views = RemoteViews(context.packageName, R.layout.widget_kabe_saat).apply {
                setTextViewText(R.id.widget_city, cityName)
                setTextViewText(R.id.widget_next_name, nextName.uppercase())
                setTextViewText(R.id.widget_next_time, nextTime)
                setTextViewText(R.id.widget_countdown, countdown)

                setTextViewText(R.id.widget_time_imsak, "İmsak $timeImsak")
                setTextViewText(R.id.widget_time_ogle, "Öğle $timeOgle")
                setTextViewText(R.id.widget_time_ikindi, "İkindi $timeIkindi")
                setTextViewText(R.id.widget_time_aksam, "Akşam $timeAksam")
                setTextViewText(R.id.widget_time_yatsi, "Yatsı $timeYatsi")

                // Open App on Click
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, KabeSaatWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (id in allWidgetIds) {
                updateAppWidget(context, appWidgetManager, id)
            }
        }
    }
}

