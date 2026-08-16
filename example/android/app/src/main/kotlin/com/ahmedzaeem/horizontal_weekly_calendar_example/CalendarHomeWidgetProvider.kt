package com.ahmedzaeem.horizontal_weekly_calendar_example

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

class CalendarHomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { id -> update(context, appWidgetManager, id) }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        update(context, appWidgetManager, appWidgetId)
    }

    private fun update(
        context: Context,
        manager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        val options = manager.getAppWidgetOptions(appWidgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 160)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)
        val layout = when {
            minHeight >= 250 -> R.layout.calendar_widget_large
            minWidth >= 250 -> R.layout.calendar_widget_medium
            else -> R.layout.calendar_widget_small
        }
        val views = RemoteViews(context.packageName, layout)
        val raw = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getString(PAYLOAD_KEY, null)
        val payload = raw?.let(::safeJson)
        val configuration = payload?.optJSONObject("configuration")
        val theme = configuration?.optJSONObject("theme")
        val content = configuration?.optString("content")
            ?.takeIf(String::isNotBlank)
            ?: "week"
        val backgroundColor = theme.color("backgroundColor", 0xff11131a.toInt())
        val foregroundColor = theme.color("foregroundColor", 0xffffffff.toInt())
        val secondaryColor = theme.color("secondaryColor", 0xffaeb4c5.toInt())
        val accentColor = theme.color("accentColor", 0xff9f8cff.toInt())
        val gradientStart = theme?.optJSONArray("gradientColors")
            ?.takeIf { it.length() == 2 }
            ?.optLong(0)
            ?.toInt()
        val surfaceColor = when (theme?.optString("surfaceStyle")) {
            "gradient" -> gradientStart ?: backgroundColor
            else -> backgroundColor
        }
        val showSubtitle = theme?.optBoolean("showSubtitle", true) ?: true
        val showLocation = theme?.optBoolean("showLocation", true) ?: true
        val showEventTime = theme?.optBoolean("showEventTime", true) ?: true
        val showWeekday = theme?.optBoolean("showWeekday", true) ?: true
        val weekdayFormat = theme?.optString("weekdayFormat") ?: "narrow"
        val headerStyle = theme?.optString("headerStyle") ?: "title"
        val maximumEvents = theme?.optInt("maximumEvents", 5)?.coerceIn(0, 12) ?: 5
        val selectedDate = payload?.optString("selectedDate")
            ?.takeIf { it.length >= 10 }
            ?.substring(0, 10)
            ?: "2026-08-10"
        val parts = selectedDate.split("-")
        val month = parts.getOrNull(1)?.toIntOrNull()?.let(::monthName) ?: "AUG"
        val day = parts.getOrNull(2)?.toIntOrNull()?.toString() ?: "10"
        val title = payload?.optString("title")?.takeIf(String::isNotBlank) ?: "My calendar"
        val subtitle = payload?.optString("subtitle")?.takeIf(String::isNotBlank)
            ?: "Tap to open your week"
        val events = payload?.optJSONArray("events")
        val firstEvent = events?.optJSONObject(0)

        val header = when (headerStyle) {
            "month" -> "$month ${parts.getOrNull(0) ?: ""}".trim()
            "compact" -> "$month $day"
            else -> title
        }
        views.setTextViewText(R.id.widget_title, header)
        views.setTextViewText(R.id.widget_month, month)
        views.setTextViewText(R.id.widget_day, day)
        views.setTextViewText(R.id.widget_subtitle, subtitle)
        views.setInt(R.id.widget_root, "setBackgroundColor", surfaceColor)
        views.setTextColor(R.id.widget_title, foregroundColor)
        views.setTextColor(R.id.widget_month, accentColor)
        views.setTextColor(R.id.widget_day, foregroundColor)
        views.setTextColor(R.id.widget_subtitle, secondaryColor)
        views.setViewVisibility(
            R.id.widget_title,
            if (headerStyle == "hidden") View.GONE else View.VISIBLE,
        )
        views.setViewVisibility(
            R.id.widget_subtitle,
            if (showSubtitle) View.VISIBLE else View.GONE,
        )
        val weekIds = intArrayOf(
            R.id.widget_week_0,
            R.id.widget_week_1,
            R.id.widget_week_2,
            R.id.widget_week_3,
            R.id.widget_week_4,
            R.id.widget_week_5,
            R.id.widget_week_6,
        )
        val parsed = runCatching {
            SimpleDateFormat("yyyy-MM-dd", Locale.US).parse(selectedDate)
        }.getOrNull()
        if (parsed != null) {
            val calendar = Calendar.getInstance().apply {
                time = parsed
                firstDayOfWeek = Calendar.MONDAY
                add(Calendar.DAY_OF_MONTH, -(get(Calendar.DAY_OF_WEEK) + 5) % 7)
            }
            weekIds.forEach { viewId ->
                val pattern = when (weekdayFormat) {
                    "short" -> "EEE\nd"
                    "full" -> "EEEE\nd"
                    else -> "EEEEE\nd"
                }
                val label = SimpleDateFormat(pattern, Locale.getDefault())
                    .format(calendar.time)
                views.setTextViewText(viewId, label)
                views.setTextColor(viewId, foregroundColor)
                calendar.add(Calendar.DAY_OF_MONTH, 1)
            }
        }
        val eventTitle: String
        val eventDetail: String
        when (content) {
            "progress" -> {
                val completed = payload?.optInt("completedCount", 0) ?: 0
                val total = payload?.optInt("totalCount", 0) ?: 0
                val percent = if (total <= 0) 0 else (completed * 100 / total).coerceIn(0, 100)
                eventTitle = "$completed of $total complete"
                eventDetail = "$percent% progress"
            }
            "countdown" -> {
                val target = payload?.optString("targetDate")
                    ?.takeIf { it.length >= 10 }
                    ?.substring(0, 10)
                val remaining = target?.let { daysBetween(selectedDate, it) } ?: 0
                eventTitle = if (remaining == 1) "1 day remaining" else "$remaining days remaining"
                eventDetail = subtitle
            }
            else -> {
                eventTitle = firstEvent?.optString("title")
                    ?.takeIf(String::isNotBlank)
                    ?: "No upcoming events"
                eventDetail = eventDetails(
                    firstEvent,
                    showSubtitle = showSubtitle,
                    showLocation = showLocation,
                    showEventTime = showEventTime,
                ) ?: "Your time is clear"
            }
        }
        views.setTextViewText(
            R.id.widget_event_title,
            eventTitle,
        )
        views.setTextViewText(
            R.id.widget_event_detail,
            eventDetail,
        )
        views.setTextColor(R.id.widget_event_title, foregroundColor)
        views.setTextColor(R.id.widget_event_detail, secondaryColor)
        views.setInt(
            R.id.widget_event_group,
            "setBackgroundColor",
            (accentColor and 0x00ffffff) or 0x22000000,
        )
        val supportsEventContent = content in setOf(
            "today",
            "week",
            "agenda",
            "countdown",
            "progress",
            "nextEvent",
        )
        views.setViewVisibility(
            R.id.widget_event_group,
            if (layout == R.layout.calendar_widget_small ||
                maximumEvents == 0 ||
                !supportsEventContent
            ) View.GONE else View.VISIBLE,
        )
        views.setViewVisibility(
            R.id.widget_event_detail,
            if (eventDetail.isBlank()) View.GONE else View.VISIBLE,
        )
        weekIds.forEach { viewId ->
            views.setViewVisibility(
                viewId,
                if (layout == R.layout.calendar_widget_large &&
                    content == "week" &&
                    showWeekday &&
                    weekdayFormat != "hidden"
                ) View.VISIBLE else View.GONE,
            )
        }

        val actionUri = payload?.optJSONObject("action")?.optString("uri")
            ?.takeIf(String::isNotBlank)
            ?: "calendar-example://day/$selectedDate"
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(actionUri), context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
        manager.updateAppWidget(appWidgetId, views)
    }

    private fun safeJson(value: String): JSONObject? =
        try {
            JSONObject(value)
        } catch (_: Exception) {
            null
        }

    private fun JSONObject?.color(name: String, fallback: Int): Int =
        if (this?.has(name) == true && !isNull(name)) optLong(name).toInt() else fallback

    private fun eventDetails(
        event: JSONObject?,
        showSubtitle: Boolean,
        showLocation: Boolean,
        showEventTime: Boolean,
    ): String? {
        if (event == null) return null
        val parts = mutableListOf<String>()
        if (showEventTime) {
            val start = event.optString("start").isoTime()
            val end = event.optString("end").isoTime()
            if (start != null && end != null) parts += "$start–$end"
        }
        if (showSubtitle) {
            event.optString("subtitle").takeIf(String::isNotBlank)?.let(parts::add)
        }
        if (showLocation) {
            event.optString("location").takeIf(String::isNotBlank)?.let(parts::add)
        }
        return parts.takeIf(List<String>::isNotEmpty)?.joinToString(" · ")
    }

    private fun String.isoTime(): String? =
        takeIf { it.length >= 16 }?.substring(11, 16)

    private fun daysBetween(start: String, end: String): Int {
        val format = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        val first = runCatching { format.parse(start) }.getOrNull() ?: return 0
        val second = runCatching { format.parse(end) }.getOrNull() ?: return 0
        return kotlin.math.abs(((second.time - first.time) / 86_400_000L).toInt())
    }

    private fun monthName(month: Int): String = arrayOf(
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC",
    ).getOrElse(month - 1) { "" }

    companion object {
        const val PREFERENCES = "horizontal_weekly_calendar_home_widgets"
        const val PAYLOAD_KEY = "calendar_widget_payload"
    }
}
