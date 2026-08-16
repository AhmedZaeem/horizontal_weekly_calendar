import 'package:flutter/material.dart';

import 'domain/calendar_date_math.dart';

/// Returns true if [a] and [b] represent the same calendar date.
@Deprecated('Use CalendarDateMath.isSameDay instead.')
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Returns true if [date] falls outside the [minDate]–[maxDate] range.
@Deprecated('Use CalendarDateMath.clamp or a selectableDayPredicate instead.')
bool isDateDisabled(DateTime date, DateTime? minDate, DateTime? maxDate) {
  final normalized = DateTime(date.year, date.month, date.day);
  if (minDate != null) {
    final min = DateTime(minDate.year, minDate.month, minDate.day);
    if (normalized.isBefore(min)) return true;
  }
  if (maxDate != null) {
    final max = DateTime(maxDate.year, maxDate.month, maxDate.day);
    if (normalized.isAfter(max)) return true;
  }
  return false;
}

/// Returns true if navigating to the previous month is allowed given [minDate].
@Deprecated('Use HorizontalCalendarController.previous instead.')
bool canNavigateToPreviousMonth(DateTime currentDate, DateTime? minDate) {
  if (minDate == null) return true;
  final previousMonth = DateTime(currentDate.year, currentDate.month - 1);
  final lastDayOfPrev =
      DateTime(previousMonth.year, previousMonth.month + 1, 0);
  final min = DateTime(minDate.year, minDate.month, minDate.day);
  return !lastDayOfPrev.isBefore(min);
}

/// Returns true if navigating to the next month is allowed given [maxDate].
@Deprecated('Use HorizontalCalendarController.next instead.')
bool canNavigateToNextMonth(DateTime currentDate, DateTime? maxDate) {
  if (maxDate == null) return true;
  final firstDayOfNext = DateTime(currentDate.year, currentDate.month + 1, 1);
  final max = DateTime(maxDate.year, maxDate.month, maxDate.day);
  return !firstDayOfNext.isAfter(max);
}

/// Generates a list of complete 7-day weeks covering the full [date] month,
/// aligned to [startDay] (1=Monday … 7=Sunday).
///
/// Delegates to [CalendarDateMath.monthGrid], so the 1.x entrypoint produces
/// exactly the same contiguous, gap-free, duplicate-free dates as the 2.0
/// surfaces.
@Deprecated('Use CalendarDateMath.monthGrid instead.')
List<List<DateTime>> generateWeeks(DateTime date, int startDay) {
  final grid = CalendarDateMath.monthGrid(date, startDay);
  return List.generate(
    grid.length ~/ 7,
    (weekIndex) => grid.sublist(weekIndex * 7, weekIndex * 7 + 7),
  );
}

/// Generates sequential chunks of up to 7 days for the [date] month
/// without weekday alignment. The last chunk may have fewer than 7 days.
@Deprecated('Use CalendarDateMath.days instead.')
List<List<DateTime>> generateWeeksChunked(DateTime date) {
  final totalDays = CalendarDateMath.daysInMonth(date.year, date.month);
  final firstOfMonth = DateTime(date.year, date.month, 1);
  final numberOfWeeks = (totalDays + 6) ~/ 7;

  return List.generate(numberOfWeeks, (weekIndex) {
    final offset = weekIndex * 7;
    final length = offset + 7 <= totalDays ? 7 : totalDays - offset;
    return CalendarDateMath.days(
      CalendarDateMath.addDays(firstOfMonth, offset),
      length,
    );
  });
}

/// Builds a navigation icon button that appears disabled when [enabled] is false.
@Deprecated('Use the v2 CalendarHeader or a custom header builder instead.')
Widget buildNavigationIcon({
  required IconData icon,
  required bool enabled,
  required Color? iconColor,
  required BuildContext context,
  required double size,
  required VoidCallback? onPressed,
}) {
  return IconButton(
    icon: Icon(
      icon,
      color: enabled
          ? iconColor
          : (iconColor ?? Theme.of(context).iconTheme.color)
              ?.withValues(alpha: 0.3),
      size: size,
    ),
    onPressed: enabled ? onPressed : null,
  );
}
