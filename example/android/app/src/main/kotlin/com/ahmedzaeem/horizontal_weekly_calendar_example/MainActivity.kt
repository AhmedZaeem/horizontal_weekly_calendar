package com.ahmedzaeem.horizontal_weekly_calendar_example

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HOME_WIDGET_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "update" -> {
                    @Suppress("UNCHECKED_CAST")
                    val payload = call.arguments as? Map<String, Any?>
                    if (payload == null) {
                        result.error("invalid_payload", "Expected a calendar widget map.", null)
                        return@setMethodCallHandler
                    }
                    getSharedPreferences(CalendarHomeWidgetProvider.PREFERENCES, MODE_PRIVATE)
                        .edit()
                        .putString(CalendarHomeWidgetProvider.PAYLOAD_KEY, JSONObject(payload).toString())
                        .apply()
                    refreshCalendarWidgets()
                    result.success(true)
                }
                "refresh" -> {
                    refreshCalendarWidgets()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun refreshCalendarWidgets() {
        val manager = AppWidgetManager.getInstance(this)
        val component = ComponentName(this, CalendarHomeWidgetProvider::class.java)
        val ids = manager.getAppWidgetIds(component)
        sendBroadcast(Intent(this, CalendarHomeWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        })
    }

    companion object {
        private const val HOME_WIDGET_CHANNEL =
            "dev.ahmedzaeem.horizontal_weekly_calendar/home_widgets"
    }
}
