import '../models/calendar_day_state.dart';
import '../models/calendar_selection.dart';
import 'calendar_date_math.dart';

/// Shared selection transitions and presentation state for calendar surfaces.
abstract final class CalendarSelectionLogic {
  /// Returns the next selection after activating [date].
  static CalendarSelection select(
    CalendarSelection previous,
    DateTime date, {
    CalendarSelectionBehavior behavior = const CalendarSelectionBehavior(),
  }) {
    return switch (previous.mode) {
      CalendarSelectionMode.single => _nextSingle(previous, date, behavior),
      CalendarSelectionMode.multiple => _nextMultiple(previous, date, behavior),
      CalendarSelectionMode.range => _nextRange(previous, date, behavior),
    };
  }

  static CalendarSelection _nextSingle(
    CalendarSelection previous,
    DateTime date,
    CalendarSelectionBehavior behavior,
  ) {
    if (behavior.singleTap == CalendarSingleTapBehavior.toggle &&
        previous.contains(date)) {
      return CalendarSelection.single(null);
    }
    return CalendarSelection.single(date);
  }

  static CalendarSelection _nextMultiple(
    CalendarSelection previous,
    DateTime date,
    CalendarSelectionBehavior behavior,
  ) {
    if (previous.contains(date)) {
      if (!behavior.allowEmptyMultiple && previous.selectedDates.length == 1) {
        return previous;
      }
      return CalendarSelection.multiple(
        previous.selectedDates.where(
          (selected) => !CalendarDateMath.isSameDay(selected, date),
        ),
      );
    }
    final maximum = behavior.maximumMultipleDates;
    if (maximum != null && previous.selectedDates.length >= maximum) {
      return previous;
    }
    return CalendarSelection.multiple([...previous.selectedDates, date]);
  }

  /// Locates [date] within a selected range.
  static CalendarRangePosition rangePosition(
    CalendarSelection selection,
    DateTime date,
  ) {
    final range = selection.selectedRange;
    if (range == null || !range.contains(date)) {
      return CalendarRangePosition.none;
    }
    if (CalendarDateMath.isSameDay(range.start, range.end)) {
      return CalendarRangePosition.single;
    }
    if (CalendarDateMath.isSameDay(range.start, date)) {
      return CalendarRangePosition.start;
    }
    if (CalendarDateMath.isSameDay(range.end, date)) {
      return CalendarRangePosition.end;
    }
    return CalendarRangePosition.middle;
  }

  static CalendarSelection _nextRange(
    CalendarSelection previous,
    DateTime date,
    CalendarSelectionBehavior behavior,
  ) {
    final range = previous.selectedRange;
    if (range == null) {
      return CalendarSelection.range(CalendarDateRange(date, date));
    }
    if (range.dayCount == 1) {
      return CalendarSelection.range(
        _boundedRange(range.start, date, behavior.maximumRangeDays),
      );
    }
    return switch (behavior.completedRangeTap) {
      CalendarCompletedRangeTap.restart =>
        CalendarSelection.range(CalendarDateRange(date, date)),
      CalendarCompletedRangeTap.extend => CalendarSelection.range(
          _boundedRange(range.start, date, behavior.maximumRangeDays),
        ),
      CalendarCompletedRangeTap.nearestBoundary => CalendarSelection.range(
          _nearestBoundaryRange(range, date, behavior.maximumRangeDays),
        ),
    };
  }

  static CalendarDateRange _nearestBoundaryRange(
    CalendarDateRange range,
    DateTime date,
    int? maximumDays,
  ) {
    final fromStart =
        CalendarDateMath.civilDayDifference(range.start, date).abs();
    final fromEnd = CalendarDateMath.civilDayDifference(range.end, date).abs();
    return fromStart <= fromEnd
        ? _boundedRange(range.end, date, maximumDays)
        : _boundedRange(range.start, date, maximumDays);
  }

  static CalendarDateRange _boundedRange(
    DateTime anchor,
    DateTime date,
    int? maximumDays,
  ) {
    var offset = CalendarDateMath.civilDayDifference(anchor, date);
    if (maximumDays != null) {
      offset = offset.clamp(-(maximumDays - 1), maximumDays - 1);
    }
    final boundedDate = CalendarDateMath.addDays(anchor, offset);
    return offset >= 0
        ? CalendarDateRange(anchor, boundedDate)
        : CalendarDateRange(boundedDate, anchor);
  }
}
