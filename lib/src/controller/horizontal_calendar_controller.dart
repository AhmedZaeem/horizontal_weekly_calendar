import 'package:flutter/foundation.dart';

import '../domain/calendar_date_math.dart';
import '../models/calendar_selection.dart';

/// Stable state of a foldable calendar.
enum CalendarFoldState {
  /// Shows the focused week.
  collapsed,

  /// Shows the complete focused month.
  expanded,
}

/// Chronological direction of the most recent accepted navigation command.
enum CalendarNavigationDirection {
  /// Moved toward an earlier civil date.
  backward,

  /// Moved toward a later civil date.
  forward,
}

/// Lightweight observable state and imperative navigation for v2 calendars.
class HorizontalCalendarController extends ChangeNotifier {
  /// Creates a controller.
  ///
  /// [visibleDayCount] is the page step used by [previous] and [next]. It must
  /// be from 1 through 31. Bounds are inclusive civil dates.
  HorizontalCalendarController({
    DateTime? focusedDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    this.visibleDayCount = 7,
    CalendarFoldState foldState = CalendarFoldState.collapsed,
    CalendarSelection? selection,
  })  : minimumDate =
            minimumDate == null ? null : CalendarDateMath.dateOnly(minimumDate),
        maximumDate =
            maximumDate == null ? null : CalendarDateMath.dateOnly(maximumDate),
        _focusedDate = CalendarDateMath.dateOnly(
          focusedDate ?? DateTime.now(),
        ),
        _foldState = foldState,
        _selection = selection ?? CalendarSelection.single(null) {
    if (visibleDayCount < 1 || visibleDayCount > 31) {
      throw RangeError.range(
        visibleDayCount,
        1,
        31,
        'visibleDayCount',
      );
    }
    final minimum = this.minimumDate;
    final maximum = this.maximumDate;
    if (minimum != null &&
        maximum != null &&
        CalendarDateMath.civilDayDifference(minimum, maximum) < 0) {
      throw ArgumentError('minimumDate must not be after maximumDate.');
    }
    _focusedDate = _resolveFocusedDate(_focusedDate);
  }

  /// Inclusive minimum focus date, if constrained.
  final DateTime? minimumDate;

  /// Inclusive maximum focus date, if constrained.
  final DateTime? maximumDate;

  /// Number of civil dates moved by [previous] and [next].
  final int visibleDayCount;

  DateTime _focusedDate;
  CalendarFoldState _foldState;
  CalendarSelection _selection;
  bool _disposed = false;

  /// Current normalized and bounds-resolved focused date.
  DateTime get focusedDate => _focusedDate;

  /// Current stable fold state.
  CalendarFoldState get foldState => _foldState;

  /// Current normalized selection.
  CalendarSelection get selection => _selection;

  /// Actual direction of the most recent accepted focus change.
  CalendarNavigationDirection? lastNavigationDirection;

  /// Animation preference supplied with the most recent accepted command.
  bool shouldAnimateLastCommand = false;

  /// Focuses [date] after normalization and inclusive bound resolution.
  Future<void> focusDate(DateTime date, {bool animate = true}) async {
    if (_disposed) return;
    final nextDate = _resolveFocusedDate(date);
    final difference = CalendarDateMath.civilDayDifference(
      _focusedDate,
      nextDate,
    );
    if (difference == 0) return;

    _focusedDate = nextDate;
    lastNavigationDirection = difference < 0
        ? CalendarNavigationDirection.backward
        : CalendarNavigationDirection.forward;
    shouldAnimateLastCommand = animate;
    notifyListeners();
  }

  /// Moves focus backward by [visibleDayCount] civil dates.
  Future<void> previous({bool animate = true}) {
    return focusDate(
      CalendarDateMath.addDays(_focusedDate, -visibleDayCount),
      animate: animate,
    );
  }

  /// Moves focus forward by [visibleDayCount] civil dates.
  Future<void> next({bool animate = true}) {
    return focusDate(
      CalendarDateMath.addDays(_focusedDate, visibleDayCount),
      animate: animate,
    );
  }

  /// Focuses today's civil date, resolved against the configured bounds.
  Future<void> today({bool animate = true}) {
    final now = DateTime.now();
    final today = _focusedDate.isUtc
        ? DateTime.utc(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day);
    return focusDate(today, animate: animate);
  }

  /// Changes the stable fold state when it differs from the current state.
  Future<void> setFoldState(
    CalendarFoldState state, {
    bool animate = true,
  }) async {
    if (_disposed || state == _foldState) return;
    _foldState = state;
    shouldAnimateLastCommand = animate;
    notifyListeners();
  }

  /// Replaces the current normalized selection when it has changed.
  void updateSelection(CalendarSelection selection) {
    if (_disposed || selection == _selection) return;
    _selection = selection;
    notifyListeners();
  }

  DateTime _resolveFocusedDate(DateTime date) {
    final normalized = CalendarDateMath.dateOnly(date);
    final minimum = minimumDate;
    final maximum = maximumDate;

    if (minimum != null &&
        CalendarDateMath.civilDayDifference(minimum, normalized) < 0) {
      return minimum;
    }
    if (maximum != null &&
        CalendarDateMath.civilDayDifference(maximum, normalized) > 0) {
      return maximum;
    }
    return normalized;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}
