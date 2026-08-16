import 'package:flutter/foundation.dart';

import 'calendar_event.dart';

/// Position of a date within a selected range.
enum CalendarRangePosition {
  /// Date is not selected as part of a range.
  none,

  /// Date is the only date in the range.
  single,

  /// Date starts a multi-day range.
  start,

  /// Date is between the range boundaries.
  middle,

  /// Date ends a multi-day range.
  end,
}

/// Immutable presentation state for one calendar day.
@immutable
class CalendarDayState<T> {
  /// Creates day state passed to components and builders.
  const CalendarDayState({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isFocused,
    required this.isDisabled,
    required this.isOutsideInterval,
    required this.rangePosition,
    required this.events,
    required this.semanticLabel,
  });

  /// Normalized civil date.
  final DateTime date;

  /// Whether [date] is today.
  final bool isToday;

  /// Whether the current selection contains [date].
  final bool isSelected;

  /// Whether [date] is the focused date.
  final bool isFocused;

  /// Whether user interaction is disabled.
  final bool isDisabled;

  /// Whether the date sits outside the primary interval or month.
  final bool isOutsideInterval;

  /// Position within a range selection.
  final CalendarRangePosition rangePosition;

  /// Unique events intersecting [date].
  final List<CalendarEvent<T>> events;

  /// Complete localized accessibility label.
  final String semanticLabel;

  /// Number of unique events intersecting [date].
  int get eventCount => events.length;
}
