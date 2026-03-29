import 'package:flutter/material.dart';

/// Returns true if [a] and [b] represent the same calendar date.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Returns true if [date] falls outside the [minDate]–[maxDate] range.
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
bool canNavigateToPreviousMonth(DateTime currentDate, DateTime? minDate) {
  if (minDate == null) return true;
  final previousMonth = DateTime(currentDate.year, currentDate.month - 1);
  final lastDayOfPrev = DateTime(previousMonth.year, previousMonth.month + 1, 0);
  final min = DateTime(minDate.year, minDate.month, minDate.day);
  return !lastDayOfPrev.isBefore(min);
}

/// Returns true if navigating to the next month is allowed given [maxDate].
bool canNavigateToNextMonth(DateTime currentDate, DateTime? maxDate) {
  if (maxDate == null) return true;
  final firstDayOfNext = DateTime(currentDate.year, currentDate.month + 1, 1);
  final max = DateTime(maxDate.year, maxDate.month, maxDate.day);
  return !firstDayOfNext.isAfter(max);
}

int _daysBetweenInclusive(DateTime start, DateTime end) {
  return DateTime.utc(end.year, end.month, end.day)
          .difference(DateTime.utc(start.year, start.month, start.day))
          .inDays +
      1;
}

/// Generates a list of complete 7-day weeks covering the full [date] month,
/// aligned to [startDay] (1=Monday … 7=Sunday). Uses DST-safe arithmetic.
List<List<DateTime>> generateWeeks(DateTime date, int startDay) {
  final firstDayOfMonth = DateTime(date.year, date.month, 1);
  final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

  final daysToSubtract = (firstDayOfMonth.weekday - startDay + 7) % 7;
  final firstCalendarDay = DateTime(
    firstDayOfMonth.year,
    firstDayOfMonth.month,
    firstDayOfMonth.day - daysToSubtract,
  );

  final daysToAdd = (startDay + 6 - lastDayOfMonth.weekday) % 7;
  final lastCalendarDay = DateTime(
    lastDayOfMonth.year,
    lastDayOfMonth.month,
    lastDayOfMonth.day + daysToAdd,
  );

  final totalDays = _daysBetweenInclusive(firstCalendarDay, lastCalendarDay);
  final numberOfWeeks = totalDays ~/ 7;

  return List.generate(numberOfWeeks, (weekIndex) {
    return List.generate(7, (dayIndex) {
      final offset = (weekIndex * 7) + dayIndex;
      return DateTime(
        firstCalendarDay.year,
        firstCalendarDay.month,
        firstCalendarDay.day + offset,
      );
    });
  });
}

/// Generates sequential chunks of up to 7 days for the [date] month
/// without weekday alignment. The last chunk may have fewer than 7 days.
List<List<DateTime>> generateWeeksChunked(DateTime date) {
  final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
  final totalDays = lastDayOfMonth.day;
  final numberOfWeeks = (totalDays + 6) ~/ 7;

  return List.generate(numberOfWeeks, (weekIndex) {
    final List<DateTime> week = [];
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final dayNumber = (weekIndex * 7) + dayOffset + 1;
      if (dayNumber > totalDays) break;
      week.add(DateTime(date.year, date.month, dayNumber));
    }
    return week;
  });
}

/// Builds a navigation icon button that appears disabled when [enabled] is false.
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
