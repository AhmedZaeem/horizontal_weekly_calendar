import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../configuration/calendar_configuration.dart';
import '../domain/calendar_date_math.dart';
import '../domain/calendar_event_layout.dart';
import '../domain/calendar_selection_logic.dart';
import '../models/calendar_day_state.dart';
import '../models/calendar_event.dart';
import '../models/calendar_selection.dart';
import '../models/calendar_visible_interval.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';
import 'calendar_components.dart';
import 'calendar_event_consumer.dart';
import 'calendar_page_motion.dart';
import 'horizontal_calendar.dart';

/// Presentation of dates adjacent to the primary month.
enum OutsideMonthVisibility {
  /// Preserve geometry without rendering adjacent dates.
  hidden,

  /// Render adjacent dates as interactive dates.
  visible,

  /// Render adjacent dates without interaction.
  visibleDisabled,
}

/// Geometry-preserving empty cell used for hidden outside-month dates.
class CalendarGridPlaceholder extends StatelessWidget {
  /// Creates an empty, semantics-free grid cell.
  const CalendarGridPlaceholder({super.key});

  @override
  Widget build(BuildContext context) =>
      const ExcludeSemantics(child: SizedBox());
}

/// Controlled natural-height month grid using the shared v2 calendar models.
class MonthCalendar<T> extends StatelessWidget {
  /// Creates a month grid.
  const MonthCalendar({
    super.key,
    required this.month,
    required this.focusedDate,
    required this.selection,
    required this.onFocusedDateChanged,
    required this.onSelectionChanged,
    this.bounds,
    this.behavior = const CalendarBehavior(),
    this.appearance = const CalendarAppearance(showHeader: false),
    this.outsideMonthVisibility = OutsideMonthVisibility.visible,
    this.events = const [],
    this.eventSource,
    this.builders = const CalendarBuilders(),
  });

  /// Creates a month calendar with an easy controlled single-date callback.
  factory MonthCalendar.single({
    Key? key,
    required DateTime month,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    ValueChanged<DateTime>? onFocusedDateChanged,
    CalendarDateRange? bounds,
    CalendarBehavior behavior = const CalendarBehavior(),
    CalendarAppearance appearance = const CalendarAppearance(showHeader: false),
    OutsideMonthVisibility outsideMonthVisibility =
        OutsideMonthVisibility.visible,
    List<CalendarEvent<T>> events = const [],
    CalendarEventSource<T>? eventSource,
    CalendarBuilders<T> builders = const CalendarBuilders(),
  }) {
    return MonthCalendar<T>(
      key: key,
      month: month,
      focusedDate: selectedDate,
      selection: CalendarSelection.single(selectedDate),
      onFocusedDateChanged: onFocusedDateChanged ?? (_) {},
      onSelectionChanged: (_, next) {
        final date = next.selectedDate;
        if (date != null) onDateSelected(date);
      },
      bounds: bounds,
      behavior: behavior,
      appearance: appearance,
      outsideMonthVisibility: outsideMonthVisibility,
      events: events,
      eventSource: eventSource,
      builders: builders,
    );
  }

  /// Month whose complete natural grid is displayed.
  final DateTime month;

  /// Controlled focused date.
  final DateTime focusedDate;

  /// Controlled selection shared with other calendar surfaces.
  final CalendarSelection selection;

  /// Reports a proposed focus change.
  final ValueChanged<DateTime> onFocusedDateChanged;

  /// Reports a proposed selection change.
  final CalendarSelectionChanged onSelectionChanged;

  /// Inclusive date bounds.
  final CalendarDateRange? bounds;

  /// Week start, availability, and interaction behavior.
  final CalendarBehavior behavior;

  /// Theme, preset, density, and event marker presentation.
  final CalendarAppearance appearance;

  /// Treatment of adjacent-month dates.
  final OutsideMonthVisibility outsideMonthVisibility;

  /// Typed events rendered in date cells.
  final List<CalendarEvent<T>> events;

  /// Optional asynchronous event source for the visible month grid.
  final CalendarEventSource<T>? eventSource;

  /// Day and event-indicator builder overrides.
  final CalendarBuilders<T> builders;

  @override
  Widget build(BuildContext context) {
    final normalizedMonth = DateTime(month.year, month.month);
    final dates = CalendarDateMath.monthGrid(
      normalizedMonth,
      behavior.firstDayOfWeek,
    );
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final rowExtent = math.max(
      theme.minimumInteractiveDimension,
      44 + 10 * scale,
    );
    final weekdayExtent = 24 + 6 * scale;
    final rows = dates.length ~/ 7;
    final interval = CalendarVisibleInterval(
      dates.first,
      CalendarDateMath.addDays(dates.last, 1),
    );
    final source = eventSource;
    if (source != null) {
      return CalendarEventConsumer<T>(
        source: source,
        interval: interval,
        builder: (context, snapshot) => MonthCalendar<T>(
          month: month,
          focusedDate: focusedDate,
          selection: selection,
          onFocusedDateChanged: onFocusedDateChanged,
          onSelectionChanged: onSelectionChanged,
          bounds: bounds,
          behavior: behavior,
          appearance: appearance,
          outsideMonthVisibility: outsideMonthVisibility,
          events: [...events, ...snapshot.events],
          builders: builders,
        ),
      );
    }
    final eventsByDate = _eventsByDate(interval);

    final grid = LayoutBuilder(builder: (context, constraints) {
      final minimumWidth = theme.minimumInteractiveDimension * 7;
      final gridWidth = math.max(
        constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0,
        minimumWidth,
      );
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: gridWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: weekdayExtent,
                child: Row(
                  children: [
                    for (final date in dates.take(7))
                      Expanded(
                        child: Center(
                          child: Text(
                            DateFormat.E(locale).format(date),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: theme.weekdayTextStyle.copyWith(
                              color: theme.mutedTextColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: rows * rowExtent,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent: rowExtent,
                  ),
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final outside = date.month != normalizedMonth.month ||
                        date.year != normalizedMonth.year;
                    if (outside &&
                        outsideMonthVisibility ==
                            OutsideMonthVisibility.hidden) {
                      return const CalendarGridPlaceholder();
                    }
                    return _buildDay(
                      context,
                      index,
                      date,
                      outside,
                      eventsByDate[_civilKey(date)] ?? const [],
                      theme,
                      locale,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
    return ChronologicalCalendarPageMotion(
      pageKey: normalizedMonth.year * 12 + normalizedMonth.month,
      motion: appearance.motion,
      child: grid,
    );
  }

  Widget _buildDay(
    BuildContext context,
    int index,
    DateTime date,
    bool outside,
    List<CalendarEvent<T>> dayEvents,
    HorizontalCalendarThemeData theme,
    String? locale,
  ) {
    final disabled = outside &&
            outsideMonthVisibility == OutsideMonthVisibility.visibleDisabled ||
        !_selectable(date);
    final isToday = CalendarDateMath.isSameDay(date, DateTime.now());
    final selected = selection.contains(date);
    final stateWords = <String>[
      if (isToday) 'today',
      if (selected) 'selected',
      if (disabled) 'disabled',
      if (dayEvents.isNotEmpty)
        '${dayEvents.length} ${dayEvents.length == 1 ? 'event' : 'events'}',
    ];
    final fullDate = DateFormat.yMMMMEEEEd(locale).format(date);
    final state = CalendarDayState<T>(
      date: date,
      isToday: isToday,
      isSelected: selected,
      isFocused: CalendarDateMath.isSameDay(date, focusedDate),
      isDisabled: disabled,
      isOutsideInterval: outside,
      rangePosition: CalendarSelectionLogic.rangePosition(selection, date),
      events: List.unmodifiable(dayEvents),
      semanticLabel:
          stateWords.isEmpty ? fullDate : '$fullDate, ${stateWords.join(', ')}',
    );
    final identifier = _identifier(date);
    return Opacity(
      opacity: outside ? .58 : 1,
      child: CalendarDayCell<T>(
        key: ValueKey(identifier),
        state: state,
        theme: theme,
        semanticIdentifier: identifier,
        locale: locale,
        eventIndicatorStyle: appearance.eventIndicatorStyle,
        eventIndicatorBuilder: builders.eventIndicatorBuilder,
        contentBuilder: builders.dayBuilder ?? _monthDayContent,
        motion: appearance.motion,
        motionIndex: index % 7,
        onTap: disabled ? null : () => _select(date),
      ),
    );
  }

  Widget _monthDayContent(BuildContext context, CalendarDayState<T> state) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final visual = CalendarDayVisualResolver.resolve(state, theme);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: visual.backgroundColor,
        borderRadius: _monthSelectionRadius(
          state.rangePosition,
          theme.dayBorderRadius,
        ),
        border: visual.borderColor == null
            ? null
            : Border.all(
                color: visual.borderColor!,
                width: visual.borderWidth,
              ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: state.eventCount > 0 ? theme.eventMarkerSize + 4 : 0,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${state.date.day}',
                maxLines: 1,
                style: theme.dayTextStyle.copyWith(
                  color: visual.foregroundColor,
                ),
              ),
            ),
          ),
          if (state.eventCount > 0)
            Positioned(
              bottom: 4,
              child: CalendarEventMarker(
                count: state.eventCount,
                style: appearance.eventIndicatorStyle,
                color: visual.eventColor,
                size: theme.eventMarkerSize,
              ),
            ),
        ],
      ),
    );
  }

  Map<int, List<CalendarEvent<T>>> _eventsByDate(
    CalendarVisibleInterval interval,
  ) {
    final grouped = <int, List<CalendarEvent<T>>>{};
    for (final segment in CalendarEventLayout.segment(events, interval)) {
      grouped.putIfAbsent(_civilKey(segment.date), () => []).add(segment.event);
    }
    return grouped;
  }

  bool _selectable(DateTime date) {
    if (bounds != null && !bounds!.contains(date)) return false;
    return behavior.selectableDayPredicate?.call(date) ?? true;
  }

  void _select(DateTime date) {
    final next = CalendarSelectionLogic.select(
      selection,
      date,
      behavior: behavior.selectionBehavior,
    );
    if (next != selection) onSelectionChanged(selection, next);
    if (!CalendarDateMath.isSameDay(focusedDate, date)) {
      onFocusedDateChanged(CalendarDateMath.dateOnly(date));
    }
  }
}

BorderRadiusGeometry _monthSelectionRadius(
  CalendarRangePosition position,
  double radius,
) {
  final rounded = Radius.circular(radius);
  return switch (position) {
    CalendarRangePosition.start => BorderRadiusDirectional.only(
        topStart: rounded,
        bottomStart: rounded,
      ),
    CalendarRangePosition.middle => BorderRadius.zero,
    CalendarRangePosition.end => BorderRadiusDirectional.only(
        topEnd: rounded,
        bottomEnd: rounded,
      ),
    CalendarRangePosition.none ||
    CalendarRangePosition.single =>
      BorderRadius.circular(radius),
  };
}

String _identifier(DateTime date) =>
    'month-day-${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

int _civilKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;
