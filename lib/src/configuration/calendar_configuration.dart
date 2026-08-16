import 'package:flutter/widgets.dart';

import '../models/calendar_day_state.dart';
import '../models/calendar_selection.dart';
import '../models/calendar_visible_interval.dart';
import '../theme/horizontal_calendar_theme.dart';
import 'calendar_motion.dart';

/// Horizontal scrolling model used by the flagship strip.
enum CalendarScrollBehavior {
  /// Snaps by the configured visible-day count.
  page,

  /// Allows continuous horizontal scrolling.
  free,
}

/// Spatial density independent from visual style.
enum CalendarDensity {
  /// Reduced padding and cell width.
  compact,

  /// Balanced default spacing.
  comfortable,

  /// Generous spacing and wider day cells.
  spacious,
}

/// Built-in event indicator presentation.
enum EventIndicatorStyle {
  /// One compact circular marker.
  dot,

  /// Numeric event count.
  count,

  /// Short horizontal activity bar.
  bar,

  /// Up to three overlapping circular markers.
  stack,
}

/// Interaction and date-window behavior shared by calendar widgets.
@immutable
class CalendarBehavior {
  /// Creates behavior configuration.
  const CalendarBehavior({
    this.visibleDayCount = 7,
    this.firstDayOfWeek = DateTime.monday,
    this.scrolling = CalendarScrollBehavior.page,
    this.enableHaptics = true,
    this.enableKeyboard = true,
    this.enableGestures = true,
    this.selectableDayPredicate,
    this.selectionBehavior = const CalendarSelectionBehavior(),
  })  : assert(visibleDayCount >= 1 && visibleDayCount <= 31),
        assert(firstDayOfWeek >= DateTime.monday &&
            firstDayOfWeek <= DateTime.sunday);

  /// Number of contiguous dates shown in one page.
  final int visibleDayCount;

  /// Dart weekday constant that begins a week.
  final int firstDayOfWeek;

  /// Page-snapping or free scrolling behavior.
  final CalendarScrollBehavior scrolling;

  /// Whether platform-appropriate haptic feedback may be emitted.
  final bool enableHaptics;

  /// Whether calendar keyboard shortcuts are enabled.
  final bool enableKeyboard;

  /// Whether pointer and touch gestures are enabled.
  final bool enableGestures;

  /// Optional application-specific day availability rule.
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Shared single, multiple, and range transition rules.
  final CalendarSelectionBehavior selectionBehavior;

  /// Returns a copy with the supplied fields replaced.
  CalendarBehavior copyWith({
    int? visibleDayCount,
    int? firstDayOfWeek,
    CalendarScrollBehavior? scrolling,
    bool? enableHaptics,
    bool? enableKeyboard,
    bool? enableGestures,
    bool Function(DateTime date)? selectableDayPredicate,
    CalendarSelectionBehavior? selectionBehavior,
  }) {
    return CalendarBehavior(
      visibleDayCount: visibleDayCount ?? this.visibleDayCount,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      scrolling: scrolling ?? this.scrolling,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableKeyboard: enableKeyboard ?? this.enableKeyboard,
      enableGestures: enableGestures ?? this.enableGestures,
      selectableDayPredicate:
          selectableDayPredicate ?? this.selectableDayPredicate,
      selectionBehavior: selectionBehavior ?? this.selectionBehavior,
    );
  }
}

/// Visual preset, density, indicators, and optional token override.
@immutable
class CalendarAppearance {
  /// Creates appearance configuration.
  const CalendarAppearance({
    this.style = CalendarStyle.adaptive,
    this.density = CalendarDensity.comfortable,
    this.eventIndicatorStyle = EventIndicatorStyle.dot,
    this.theme,
    this.showHeader = true,
    this.showSurface = true,
    this.motion,
  });

  /// Platform convention or explicit style family.
  final CalendarStyle style;

  /// Independent spatial density.
  final CalendarDensity density;

  /// Built-in event indicator treatment.
  final EventIndicatorStyle eventIndicatorStyle;

  /// Optional complete semantic-token override.
  final HorizontalCalendarThemeData? theme;

  /// Whether the standard calendar header is visible.
  final bool showHeader;

  /// Whether the calendar paints its own background, outline, and padding.
  ///
  /// Set this to `false` when the calendar is composed inside a card or sheet
  /// the application already draws, so the two surfaces do not nest and the
  /// dates keep the full width of the container.
  final bool showSurface;

  /// Optional motion choreography; omitting it preserves classic behavior.
  final CalendarMotion? motion;

  /// Returns a copy with the supplied fields replaced.
  CalendarAppearance copyWith({
    CalendarStyle? style,
    CalendarDensity? density,
    EventIndicatorStyle? eventIndicatorStyle,
    HorizontalCalendarThemeData? theme,
    bool? showHeader,
    bool? showSurface,
    CalendarMotion? motion,
  }) {
    return CalendarAppearance(
      style: style ?? this.style,
      density: density ?? this.density,
      eventIndicatorStyle: eventIndicatorStyle ?? this.eventIndicatorStyle,
      theme: theme ?? this.theme,
      showHeader: showHeader ?? this.showHeader,
      showSurface: showSurface ?? this.showSurface,
      motion: motion ?? this.motion,
    );
  }
}

/// State supplied to a custom calendar header.
@immutable
class CalendarHeaderState {
  /// Creates immutable header state.
  const CalendarHeaderState({
    required this.focusedDate,
    required this.visibleInterval,
    required this.canNavigateBackward,
    required this.canNavigateForward,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  /// Current focused civil date.
  final DateTime focusedDate;

  /// Current half-open visible interval.
  final CalendarVisibleInterval visibleInterval;

  /// Whether earlier dates are reachable.
  final bool canNavigateBackward;

  /// Whether later dates are reachable.
  final bool canNavigateForward;

  /// Navigates to the previous chronological page.
  final VoidCallback onPrevious;

  /// Navigates to the next chronological page.
  final VoidCallback onNext;

  /// Navigates to today's civil date.
  final VoidCallback onToday;
}

/// Builds complete custom content for one day.
typedef CalendarDayBuilder<T> = Widget Function(
  BuildContext context,
  CalendarDayState<T> state,
);

/// Builds a complete custom header.
typedef CalendarHeaderBuilder = Widget Function(
  BuildContext context,
  CalendarHeaderState state,
);

/// Builds a custom event indicator for one day.
typedef CalendarEventIndicatorBuilder<T> = Widget Function(
  BuildContext context,
  CalendarDayState<T> state,
);

/// Focused builder overrides for calendar presentation.
@immutable
class CalendarBuilders<T> {
  /// Creates a set of optional builder overrides.
  const CalendarBuilders({
    this.dayBuilder,
    this.headerBuilder,
    this.eventIndicatorBuilder,
  });

  /// Replaces the complete day content.
  final CalendarDayBuilder<T>? dayBuilder;

  /// Replaces the standard header.
  final CalendarHeaderBuilder? headerBuilder;

  /// Replaces the built-in event indicator.
  final CalendarEventIndicatorBuilder<T>? eventIndicatorBuilder;
}
