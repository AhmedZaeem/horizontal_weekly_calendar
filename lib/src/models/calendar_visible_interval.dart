import 'package:flutter/foundation.dart';

import '../domain/calendar_date_math.dart';

/// A non-empty civil-date interval whose [start] is inclusive and [end] is
/// exclusive.
@immutable
class CalendarVisibleInterval {
  /// Creates a visible interval and removes time-of-day from both boundaries.
  factory CalendarVisibleInterval(DateTime start, DateTime end) {
    final normalizedStart = CalendarDateMath.dateOnly(start);
    final normalizedEnd = CalendarDateMath.dateOnly(end);
    if (CalendarDateMath.civilDayDifference(
          normalizedStart,
          normalizedEnd,
        ) <=
        0) {
      throw ArgumentError.value(
        end,
        'end',
        'must be a civil date after start',
      );
    }
    return CalendarVisibleInterval._(normalizedStart, normalizedEnd);
  }

  const CalendarVisibleInterval._(this.start, this.end);

  /// First visible civil date, inclusive.
  final DateTime start;

  /// Civil date immediately after the interval, exclusive.
  final DateTime end;

  /// Number of visible civil dates.
  int get dayCount => CalendarDateMath.civilDayDifference(start, end);

  /// Whether [date] belongs to this half-open civil interval.
  bool contains(DateTime date) {
    final offset = CalendarDateMath.civilDayDifference(start, date);
    return offset >= 0 && offset < dayCount;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CalendarVisibleInterval &&
            CalendarDateMath.isSameDay(start, other.start) &&
            CalendarDateMath.isSameDay(end, other.end);
  }

  @override
  int get hashCode => Object.hash(
        Object.hash(start.year, start.month, start.day),
        Object.hash(end.year, end.month, end.day),
      );
}
