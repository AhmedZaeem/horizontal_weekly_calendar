import 'package:flutter/foundation.dart';

import '../domain/calendar_date_math.dart';

/// The controlled selection behavior used by calendar widgets.
enum CalendarSelectionMode {
  /// Zero or one selected civil date.
  single,

  /// Any number of independently selected civil dates.
  multiple,

  /// Zero or one inclusive, contiguous date range.
  range,
}

/// Behavior when an already selected date is tapped in single mode.
enum CalendarSingleTapBehavior {
  /// Keep one selected date by replacing the previous value.
  replace,

  /// Clear the selection when the selected date is tapped again.
  toggle,
}

/// Behavior when a completed range receives another date tap.
enum CalendarCompletedRangeTap {
  /// Start a new one-day range from the tapped date.
  restart,

  /// Keep the original start and move the range end.
  extend,

  /// Move whichever existing boundary is nearest to the tapped date.
  nearestBoundary,
}

/// Selection rules shared by every selectable calendar surface.
@immutable
class CalendarSelectionBehavior {
  /// Creates predictable selection rules.
  const CalendarSelectionBehavior({
    this.singleTap = CalendarSingleTapBehavior.replace,
    this.allowEmptyMultiple = true,
    this.maximumMultipleDates,
    this.completedRangeTap = CalendarCompletedRangeTap.restart,
    this.maximumRangeDays,
  })  : assert(maximumMultipleDates == null || maximumMultipleDates >= 1),
        assert(maximumRangeDays == null || maximumRangeDays >= 1);

  /// Same-date behavior for single selection.
  final CalendarSingleTapBehavior singleTap;

  /// Whether removing the final multiple-selection date is allowed.
  final bool allowEmptyMultiple;

  /// Optional maximum number of dates in multiple mode.
  final int? maximumMultipleDates;

  /// Tap behavior after a range has both boundaries.
  final CalendarCompletedRangeTap completedRangeTap;

  /// Optional inclusive maximum range length.
  final int? maximumRangeDays;

  /// Returns a copy with supplied rules replaced.
  CalendarSelectionBehavior copyWith({
    CalendarSingleTapBehavior? singleTap,
    bool? allowEmptyMultiple,
    int? maximumMultipleDates,
    CalendarCompletedRangeTap? completedRangeTap,
    int? maximumRangeDays,
  }) {
    return CalendarSelectionBehavior(
      singleTap: singleTap ?? this.singleTap,
      allowEmptyMultiple: allowEmptyMultiple ?? this.allowEmptyMultiple,
      maximumMultipleDates: maximumMultipleDates ?? this.maximumMultipleDates,
      completedRangeTap: completedRangeTap ?? this.completedRangeTap,
      maximumRangeDays: maximumRangeDays ?? this.maximumRangeDays,
    );
  }
}

/// An inclusive, ordered range of civil dates.
final class CalendarDateRange {
  /// Creates a range from [start] through [end], including both endpoints.
  CalendarDateRange(DateTime start, DateTime end)
      : start = CalendarDateMath.dateOnly(start),
        end = CalendarDateMath.dateOnly(end) {
    if (CalendarDateMath.civilDayDifference(this.start, this.end) < 0) {
      throw ArgumentError('start must not be after end.');
    }
  }

  /// First selected civil date, inclusive.
  final DateTime start;

  /// Last selected civil date, inclusive.
  final DateTime end;

  /// Number of selected civil dates.
  int get dayCount => CalendarDateMath.civilDayDifference(start, end) + 1;

  /// All civil dates in this range, in chronological order.
  List<DateTime> get dates => CalendarDateMath.days(start, dayCount);

  /// Whether [date] falls inside this inclusive range.
  bool contains(DateTime date) {
    final offset = CalendarDateMath.civilDayDifference(start, date);
    return offset >= 0 && offset < dayCount;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CalendarDateRange &&
            CalendarDateMath.isSameDay(start, other.start) &&
            CalendarDateMath.isSameDay(end, other.end);
  }

  @override
  int get hashCode => Object.hash(
        start.year,
        start.month,
        start.day,
        end.year,
        end.month,
        end.day,
      );

  @override
  String toString() => 'CalendarDateRange($start, $end)';
}

/// Immutable controlled selection value shared by all calendar views.
final class CalendarSelection {
  CalendarSelection._({
    required this.mode,
    DateTime? selectedDate,
    Set<DateTime>? selectedDates,
    CalendarDateRange? selectedRange,
  })  : _selectedDate = selectedDate,
        _selectedDates = selectedDates ?? const <DateTime>{},
        _selectedRange = selectedRange;

  /// Creates a single-date selection.
  factory CalendarSelection.single(DateTime? date) {
    return CalendarSelection._(
      mode: CalendarSelectionMode.single,
      selectedDate: date == null ? null : CalendarDateMath.dateOnly(date),
    );
  }

  /// Creates a multiple-date selection and removes duplicate civil dates.
  factory CalendarSelection.multiple(Iterable<DateTime> dates) {
    final normalizedByCivilDay = <int, DateTime>{};
    for (final date in dates) {
      final normalized = CalendarDateMath.dateOnly(date);
      normalizedByCivilDay.putIfAbsent(
        _civilKey(normalized),
        () => normalized,
      );
    }
    return CalendarSelection._(
      mode: CalendarSelectionMode.multiple,
      selectedDates: Set<DateTime>.unmodifiable(normalizedByCivilDay.values),
    );
  }

  /// Creates an inclusive date-range selection.
  factory CalendarSelection.range(CalendarDateRange? range) {
    return CalendarSelection._(
      mode: CalendarSelectionMode.range,
      selectedRange: range,
    );
  }

  /// Selection behavior represented by this value.
  final CalendarSelectionMode mode;

  final DateTime? _selectedDate;
  final Set<DateTime> _selectedDates;
  final CalendarDateRange? _selectedRange;

  /// Selected date for [CalendarSelectionMode.single], otherwise `null`.
  DateTime? get selectedDate => _selectedDate;

  /// Selected dates for [CalendarSelectionMode.multiple], otherwise empty.
  Set<DateTime> get selectedDates => _selectedDates;

  /// Selected range for [CalendarSelectionMode.range], otherwise `null`.
  CalendarDateRange? get selectedRange => _selectedRange;

  /// Whether [date] is included in this selection.
  bool contains(DateTime date) {
    final selectedDate = _selectedDate;
    return switch (mode) {
      CalendarSelectionMode.single =>
        selectedDate != null && CalendarDateMath.isSameDay(selectedDate, date),
      CalendarSelectionMode.multiple => _selectedDates.any(
          (selected) => CalendarDateMath.isSameDay(selected, date),
        ),
      CalendarSelectionMode.range => _selectedRange?.contains(date) ?? false,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CalendarSelection || mode != other.mode) return false;

    return switch (mode) {
      CalendarSelectionMode.single => _sameNullableDate(
          _selectedDate,
          other._selectedDate,
        ),
      CalendarSelectionMode.multiple =>
        _selectedDates.length == other._selectedDates.length &&
            _selectedDates.every(
              (selected) => other._selectedDates.any(
                (candidate) => CalendarDateMath.isSameDay(selected, candidate),
              ),
            ),
      CalendarSelectionMode.range => _selectedRange == other._selectedRange,
    };
  }

  @override
  int get hashCode {
    return switch (mode) {
      CalendarSelectionMode.single =>
        Object.hash(mode, _dateHash(_selectedDate)),
      CalendarSelectionMode.multiple => Object.hash(
          mode, Object.hashAllUnordered(_selectedDates.map(_dateHash))),
      CalendarSelectionMode.range => Object.hash(mode, _selectedRange),
    };
  }

  @override
  String toString() {
    return switch (mode) {
      CalendarSelectionMode.single =>
        'CalendarSelection.single($_selectedDate)',
      CalendarSelectionMode.multiple =>
        'CalendarSelection.multiple($_selectedDates)',
      CalendarSelectionMode.range => 'CalendarSelection.range($_selectedRange)',
    };
  }

  static bool _sameNullableDate(DateTime? first, DateTime? second) {
    if (first == null || second == null) return first == second;
    return CalendarDateMath.isSameDay(first, second);
  }

  static int _dateHash(DateTime? date) {
    return date == null ? 0 : Object.hash(date.year, date.month, date.day);
  }

  static int _civilKey(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }
}
