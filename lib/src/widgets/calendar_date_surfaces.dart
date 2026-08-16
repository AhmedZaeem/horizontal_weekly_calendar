import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configuration/calendar_configuration.dart';
import '../domain/calendar_date_math.dart';
import '../domain/calendar_event_layout.dart';
import '../models/calendar_event.dart';
import '../models/calendar_selection.dart';
import '../models/calendar_visible_interval.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';
import 'calendar_date_carousel.dart';

/// Immutable state for one [CalendarDateRail] item.
@immutable
class CalendarDateRailItemState<T> {
  /// Creates date-rail item state.
  const CalendarDateRailItemState({
    required this.date,
    required this.item,
    required this.events,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.semanticLabel,
  });

  /// Normalized date.
  final DateTime date;

  /// Optional typed metadata.
  final CalendarCarouselItem<T>? item;

  /// Events intersecting the date.
  final List<CalendarEvent<T>> events;

  /// Whether the date is selected.
  final bool isSelected;

  /// Whether the date is today.
  final bool isToday;

  /// Whether interaction is disabled.
  final bool isDisabled;

  /// Localized accessibility label.
  final String semanticLabel;
}

/// Builds one complete custom date-rail item.
typedef CalendarDateRailItemBuilder<T> = Widget Function(
  BuildContext context,
  CalendarDateRailItemState<T> state,
);

/// Vertical scrollable date axis for feeds, journeys, and schedule sidebars.
class CalendarDateRail<T> extends StatelessWidget {
  /// Creates a date rail containing contiguous civil dates.
  const CalendarDateRail({
    super.key,
    required this.startDate,
    required this.dayCount,
    required this.selectedDate,
    required this.onDateSelected,
    this.onItemSelected,
    this.items = const [],
    this.events = const [],
    this.bounds,
    this.selectableDayPredicate,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.itemExtent = 76,
    this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  })  : assert(dayCount >= 1 && dayCount <= 366),
        assert(itemExtent >= 48);

  /// First date in the rail.
  final DateTime startDate;

  /// Number of contiguous dates.
  final int dayCount;

  /// Controlled selected date.
  final DateTime selectedDate;

  /// Reports an accepted date.
  final ValueChanged<DateTime> onDateSelected;

  /// Reports typed metadata associated with an accepted date.
  final ValueChanged<CalendarCarouselItem<T>?>? onItemSelected;

  /// Optional per-date metadata.
  final List<CalendarCarouselItem<T>> items;

  /// Typed events grouped into rail dates.
  final List<CalendarEvent<T>> events;

  /// Optional inclusive bounds.
  final CalendarDateRange? bounds;

  /// Optional enabled-day rule.
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Shared visual configuration.
  final CalendarAppearance appearance;

  /// Fixed vertical item extent.
  final double itemExtent;

  /// Optional complete item replacement.
  final CalendarDateRailItemBuilder<T>? itemBuilder;

  /// Rail padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final start = CalendarDateMath.dateOnly(startDate);
    final dates = CalendarDateMath.days(start, dayCount);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final itemByDate = <int, CalendarCarouselItem<T>>{
      for (final item in items) _civilKey(item.date): item,
    };
    final interval = CalendarVisibleInterval(
      start,
      CalendarDateMath.addDays(start, dayCount),
    );
    final eventsByDate = <int, List<CalendarEvent<T>>>{};
    for (final segment in CalendarEventLayout.segment(events, interval)) {
      eventsByDate
          .putIfAbsent(_civilKey(segment.date), () => [])
          .add(segment.event);
    }
    return Material(
      type: MaterialType.transparency,
      child: ListView.builder(
        padding: padding,
        itemExtent: itemExtent,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final item = itemByDate[_civilKey(date)];
          final dayEvents = List<CalendarEvent<T>>.unmodifiable(
            eventsByDate[_civilKey(date)] ?? const [],
          );
          final disabled = (bounds != null && !bounds!.contains(date)) ||
              !(selectableDayPredicate?.call(date) ?? true);
          final selected = CalendarDateMath.isSameDay(date, selectedDate);
          final today = CalendarDateMath.isSameDay(date, DateTime.now());
          final label = '${DateFormat.yMMMMEEEEd(locale).format(date)}'
              '${selected ? ', selected' : ''}'
              '${disabled ? ', disabled' : ''}'
              '${dayEvents.isEmpty ? '' : ', ${dayEvents.length} events'}';
          final state = CalendarDateRailItemState<T>(
            date: date,
            item: item,
            events: dayEvents,
            isSelected: selected,
            isToday: today,
            isDisabled: disabled,
            semanticLabel: label,
          );
          final key = _dateKey('calendar-rail', date);
          return Semantics(
            identifier: key,
            label: label,
            selected: selected,
            enabled: !disabled,
            button: true,
            child: InkWell(
              key: ValueKey(key),
              borderRadius: BorderRadius.circular(theme.dayBorderRadius),
              onTap: disabled
                  ? null
                  : () {
                      onItemSelected?.call(item);
                      onDateSelected(date);
                    },
              child: itemBuilder?.call(context, state) ??
                  _DefaultDateRailItem(state: state, theme: theme),
            ),
          );
        },
      ),
    );
  }
}

class _DefaultDateRailItem<T> extends StatelessWidget {
  const _DefaultDateRailItem({required this.state, required this.theme});

  final CalendarDateRailItemState<T> state;
  final HorizontalCalendarThemeData theme;

  @override
  Widget build(BuildContext context) {
    final foreground = state.isSelected ? theme.onAccentColor : theme.textColor;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: state.isSelected ? theme.accentColor : theme.surfaceColor,
        borderRadius: BorderRadius.circular(theme.dayBorderRadius),
        border: Border.all(
          color: state.isToday ? theme.todayColor : theme.borderColor,
          width: state.isToday ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.E().format(state.date),
                    maxLines: 1,
                    style: theme.weekdayTextStyle.copyWith(color: foreground),
                  ),
                  Text(
                    '${state.date.day}',
                    style: theme.dayTextStyle.copyWith(color: foreground),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.item?.title ??
                  (state.events.isEmpty
                      ? 'No scheduled items'
                      : '${state.events.length} scheduled'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.eventTextStyle.copyWith(color: foreground),
            ),
          ),
          if (state.item?.badge case final badge?)
            Text(
              badge,
              maxLines: 1,
              style: theme.eventTextStyle.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

/// Typed interval displayed by [CalendarScheduleRibbon].
@immutable
class CalendarScheduleInterval<T> {
  /// Creates a half-open schedule interval.
  CalendarScheduleInterval({
    required this.id,
    required this.start,
    required this.end,
    this.title,
    this.color,
    this.data,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'Must not be empty.');
    if (!end.isAfter(start)) {
      throw ArgumentError('end must be after start.');
    }
  }

  /// Stable application identity.
  final String id;

  /// Inclusive start instant.
  final DateTime start;

  /// Exclusive end instant.
  final DateTime end;

  /// Optional visible title.
  final String? title;

  /// Optional interval color.
  final Color? color;

  /// Original application payload.
  final T? data;
}

/// Immutable layout state for one schedule interval segment.
@immutable
class CalendarScheduleIntervalState<T> {
  /// Creates schedule segment state.
  const CalendarScheduleIntervalState({
    required this.interval,
    required this.visibleStart,
    required this.visibleEnd,
    required this.lane,
    required this.isClippedStart,
    required this.isClippedEnd,
  });

  /// Original typed interval.
  final CalendarScheduleInterval<T> interval;

  /// Visible inclusive segment start.
  final DateTime visibleStart;

  /// Visible exclusive segment end.
  final DateTime visibleEnd;

  /// Zero-based overlap lane.
  final int lane;

  /// Whether the original starts before the visible ruler.
  final bool isClippedStart;

  /// Whether the original ends after the visible ruler.
  final bool isClippedEnd;
}

/// Builds a custom schedule interval segment.
typedef CalendarScheduleIntervalBuilder<T> = Widget Function(
  BuildContext context,
  CalendarScheduleIntervalState<T> state,
);

/// Horizontal time-of-day ruler for appointments, broadcasts, and operations.
class CalendarScheduleRibbon<T> extends StatelessWidget {
  /// Creates a schedule ribbon for [date].
  const CalendarScheduleRibbon({
    super.key,
    required this.date,
    this.intervals = const [],
    this.onIntervalTap,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.startHour = 0,
    this.endHour = 24,
    this.minuteWidth = 1.2,
    this.laneExtent = 48,
    this.now,
    this.intervalBuilder,
  })  : assert(startHour >= 0 && startHour < 24),
        assert(endHour > startHour && endHour <= 24),
        assert(minuteWidth > 0),
        assert(laneExtent >= 36);

  /// Civil date represented by the ruler.
  final DateTime date;

  /// Typed schedule intervals.
  final List<CalendarScheduleInterval<T>> intervals;

  /// Reports the original tapped interval.
  final ValueChanged<CalendarScheduleInterval<T>>? onIntervalTap;

  /// Shared visual configuration.
  final CalendarAppearance appearance;

  /// First visible hour.
  final int startHour;

  /// Exclusive final visible hour.
  final int endHour;

  /// Logical pixels per minute.
  final double minuteWidth;

  /// Height of one overlap lane.
  final double laneExtent;

  /// Optional current-time override.
  final DateTime? now;

  /// Optional complete interval replacement.
  final CalendarScheduleIntervalBuilder<T>? intervalBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final day = CalendarDateMath.dateOnly(date);
    final windowStart = DateTime(day.year, day.month, day.day, startHour);
    final windowEnd = DateTime(day.year, day.month, day.day, endHour);
    final segments = _layoutIntervals(windowStart, windowEnd);
    final lanes =
        segments.fold<int>(1, (value, item) => math.max(value, item.lane + 1));
    final width = (endHour - startHour) * 60 * minuteWidth;
    final height = 30 + lanes * laneExtent + 10;
    final current = now ?? DateTime.now();

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: height,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                for (var hour = startHour; hour <= endHour; hour += 1)
                  Positioned(
                    left: (hour - startHour) * 60 * minuteWidth,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      children: [
                        Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: theme.weekdayTextStyle.copyWith(
                            color: theme.mutedTextColor,
                          ),
                        ),
                        Expanded(
                          child: VerticalDivider(
                            width: 1,
                            color: theme.borderColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!current.isBefore(windowStart) &&
                    current.isBefore(windowEnd))
                  Positioned(
                    left:
                        current.difference(windowStart).inMinutes * minuteWidth,
                    top: 24,
                    bottom: 0,
                    child: Container(width: 2, color: theme.todayColor),
                  ),
                for (final state in segments)
                  Positioned(
                    left: state.visibleStart.difference(windowStart).inMinutes *
                        minuteWidth,
                    top: 30 + state.lane * laneExtent,
                    width: math.max(
                      36,
                      state.visibleEnd
                              .difference(state.visibleStart)
                              .inMinutes *
                          minuteWidth,
                    ),
                    height: laneExtent - 6,
                    child: Semantics(
                      button: onIntervalTap != null,
                      label: state.interval.title ?? state.interval.id,
                      child: InkWell(
                        key: ValueKey('schedule-interval-${state.interval.id}'),
                        borderRadius:
                            BorderRadius.circular(theme.dayBorderRadius),
                        onTap: onIntervalTap == null
                            ? null
                            : () => onIntervalTap!(state.interval),
                        child: intervalBuilder?.call(context, state) ??
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    state.interval.color ?? theme.accentColor,
                                borderRadius: BorderRadius.circular(
                                  theme.dayBorderRadius,
                                ),
                              ),
                              child: Text(
                                state.interval.title ?? state.interval.id,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.eventTextStyle.copyWith(
                                  color: theme.onAccentColor,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<CalendarScheduleIntervalState<T>> _layoutIntervals(
    DateTime windowStart,
    DateTime windowEnd,
  ) {
    final sorted = intervals
        .where((item) =>
            item.start.isBefore(windowEnd) && item.end.isAfter(windowStart))
        .toList()
      ..sort((first, second) {
        final byStart = first.start.compareTo(second.start);
        return byStart != 0 ? byStart : first.id.compareTo(second.id);
      });
    final laneEnds = <DateTime>[];
    final result = <CalendarScheduleIntervalState<T>>[];
    for (final interval in sorted) {
      final visibleStart =
          interval.start.isBefore(windowStart) ? windowStart : interval.start;
      final visibleEnd =
          interval.end.isAfter(windowEnd) ? windowEnd : interval.end;
      var lane = laneEnds.indexWhere((end) => !end.isAfter(visibleStart));
      if (lane == -1) {
        lane = laneEnds.length;
        laneEnds.add(visibleEnd);
      } else {
        laneEnds[lane] = visibleEnd;
      }
      result.add(CalendarScheduleIntervalState<T>(
        interval: interval,
        visibleStart: visibleStart,
        visibleEnd: visibleEnd,
        lane: lane,
        isClippedStart: interval.start.isBefore(windowStart),
        isClippedEnd: interval.end.isAfter(windowEnd),
      ));
    }
    return result;
  }
}

/// Progress state of a milestone relative to a controlled current date.
enum CalendarMilestoneState {
  /// Milestone date is before the current date.
  completed,

  /// Milestone date matches the current date.
  current,

  /// Milestone date is after the current date.
  upcoming,

  /// Milestone is intentionally blocked regardless of its date.
  blocked,
}

/// Built-in presentation for [CalendarMilestoneTimeline].
enum CalendarMilestoneDesign {
  /// Connected timeline cards with prominent status.
  timeline,

  /// Alternating journey-style stops.
  roadmap,

  /// Compact numbered progress steps.
  steps,

  /// Independent milestone cards.
  cards,

  /// Restrained type and status marks.
  minimal,
}

/// Typed dated milestone displayed by [CalendarMilestoneTimeline].
@immutable
class CalendarMilestone<T> {
  /// Creates a milestone.
  CalendarMilestone({
    required this.id,
    required this.date,
    required this.title,
    this.subtitle,
    this.data,
    this.state,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'Must not be empty.');
    if (title.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Must not be empty.');
    }
  }

  /// Stable application identity.
  final String id;

  /// Milestone date.
  final DateTime date;

  /// Primary milestone label.
  final String title;

  /// Optional supporting label.
  final String? subtitle;

  /// Original application payload.
  final T? data;

  /// Optional explicit state, useful for blocked or external workflows.
  final CalendarMilestoneState? state;
}

/// Immutable builder state for a milestone.
@immutable
class CalendarMilestoneItemState<T> {
  /// Creates milestone item state.
  const CalendarMilestoneItemState({
    required this.milestone,
    required this.state,
    required this.index,
    required this.isFirst,
    required this.isLast,
  });

  /// Original typed milestone.
  final CalendarMilestone<T> milestone;

  /// Progress state relative to the controlled current date.
  final CalendarMilestoneState state;

  /// Chronological item index.
  final int index;

  /// Whether this is the first milestone.
  final bool isFirst;

  /// Whether this is the final milestone.
  final bool isLast;
}

/// Builds one complete milestone item.
typedef CalendarMilestoneBuilder<T> = Widget Function(
  BuildContext context,
  CalendarMilestoneItemState<T> state,
);

/// Horizontal or vertical typed milestone timeline.
class CalendarMilestoneTimeline<T> extends StatelessWidget {
  /// Creates a milestone timeline.
  const CalendarMilestoneTimeline({
    super.key,
    required this.milestones,
    required this.currentDate,
    this.onMilestoneTap,
    this.orientation = Axis.horizontal,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.itemExtent = 172,
    this.design = CalendarMilestoneDesign.timeline,
    this.connectorColor,
    this.connectorWidth = 2,
    this.itemBuilder,
    this.padding = const EdgeInsets.all(4),
  })  : assert(itemExtent >= 96),
        assert(connectorWidth >= 0 && connectorWidth <= 20);

  /// Typed source milestones.
  final List<CalendarMilestone<T>> milestones;

  /// Controlled date used to derive milestone progress.
  final DateTime currentDate;

  /// Reports the original tapped milestone.
  final ValueChanged<CalendarMilestone<T>>? onMilestoneTap;

  /// Timeline orientation.
  final Axis orientation;

  /// Shared visual configuration.
  final CalendarAppearance appearance;

  /// Fixed main-axis item extent.
  final double itemExtent;

  /// Built-in milestone presentation.
  final CalendarMilestoneDesign design;

  /// Optional connector override.
  final Color? connectorColor;

  /// Connector thickness.
  final double connectorWidth;

  /// Optional complete milestone replacement.
  final CalendarMilestoneBuilder<T>? itemBuilder;

  /// Timeline padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final indexed = milestones.indexed.toList()
      ..sort((first, second) {
        final byDate = CalendarDateMath.civilDayDifference(
          second.$2.date,
          first.$2.date,
        );
        return byDate != 0 ? byDate : first.$1.compareTo(second.$1);
      });
    return Material(
      type: MaterialType.transparency,
      child: ListView.builder(
        padding: padding,
        scrollDirection: orientation,
        itemExtent: itemExtent,
        itemCount: indexed.length,
        itemBuilder: (context, index) {
          final milestone = indexed[index].$2;
          final difference = CalendarDateMath.civilDayDifference(
            milestone.date,
            currentDate,
          );
          final state = milestone.state ??
              (difference > 0
                  ? CalendarMilestoneState.completed
                  : difference == 0
                      ? CalendarMilestoneState.current
                      : CalendarMilestoneState.upcoming);
          final itemState = CalendarMilestoneItemState<T>(
            milestone: milestone,
            state: state,
            index: index,
            isFirst: index == 0,
            isLast: index == indexed.length - 1,
          );
          return Semantics(
            label: '${milestone.title}, ${state.name}',
            button: onMilestoneTap != null,
            child: InkWell(
              key: ValueKey('calendar-milestone-${milestone.id}'),
              onTap: onMilestoneTap == null
                  ? null
                  : () => onMilestoneTap!(milestone),
              child: itemBuilder?.call(context, itemState) ??
                  _DefaultMilestoneItem(
                    state: itemState,
                    theme: theme,
                    design: design,
                    orientation: orientation,
                    connectorColor: connectorColor,
                    connectorWidth: connectorWidth,
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _DefaultMilestoneItem<T> extends StatelessWidget {
  const _DefaultMilestoneItem({
    required this.state,
    required this.theme,
    required this.design,
    required this.orientation,
    required this.connectorColor,
    required this.connectorWidth,
  });

  final CalendarMilestoneItemState<T> state;
  final HorizontalCalendarThemeData theme;
  final CalendarMilestoneDesign design;
  final Axis orientation;
  final Color? connectorColor;
  final double connectorWidth;

  @override
  Widget build(BuildContext context) {
    final completed = state.state == CalendarMilestoneState.completed;
    final current = state.state == CalendarMilestoneState.current;
    final blocked = state.state == CalendarMilestoneState.blocked;
    final active = completed || current;
    final accent = blocked ? theme.errorColor : theme.accentColor;
    final background = switch (design) {
      CalendarMilestoneDesign.cards =>
        active ? accent.withValues(alpha: .12) : theme.surfaceColor,
      CalendarMilestoneDesign.roadmap =>
        current ? accent : theme.elevatedSurfaceColor,
      CalendarMilestoneDesign.steps => completed ? accent : theme.surfaceColor,
      CalendarMilestoneDesign.timeline => active ? accent : theme.surfaceColor,
      CalendarMilestoneDesign.minimal => Colors.transparent,
    };
    final onAccent = (design == CalendarMilestoneDesign.timeline && active) ||
        (design == CalendarMilestoneDesign.roadmap && current) ||
        (design == CalendarMilestoneDesign.steps && completed);
    final foreground = onAccent ? theme.onAccentColor : theme.textColor;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!state.isLast &&
              design != CalendarMilestoneDesign.cards &&
              design != CalendarMilestoneDesign.minimal)
            PositionedDirectional(
              top: orientation == Axis.horizontal ? 18 : null,
              bottom: orientation == Axis.vertical ? -12 : null,
              start: orientation == Axis.vertical ? 18 : null,
              end: orientation == Axis.horizontal ? -12 : null,
              width: orientation == Axis.vertical ? connectorWidth : null,
              height: orientation == Axis.horizontal ? connectorWidth : null,
              child: ColoredBox(
                color:
                    connectorColor ?? (completed ? accent : theme.borderColor),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(
                design == CalendarMilestoneDesign.steps
                    ? theme.minimumInteractiveDimension
                    : theme.dayBorderRadius,
              ),
              border: Border.all(
                color: current || blocked ? accent : theme.borderColor,
                width: current ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              blocked
                                  ? Icons.lock_outline_rounded
                                  : completed
                                      ? Icons.check_circle_rounded
                                      : current
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.circle_outlined,
                              size: 16,
                              color: onAccent ? theme.onAccentColor : accent,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                design == CalendarMilestoneDesign.steps
                                    ? 'STEP ${state.index + 1}'
                                    : DateFormat.MMMd()
                                        .format(state.milestone.date),
                                style: theme.weekdayTextStyle.copyWith(
                                  color: onAccent
                                      ? theme.onAccentColor
                                      : theme.mutedTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          state.milestone.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.dayTextStyle.copyWith(
                            color: foreground,
                          ),
                        ),
                        if (state.milestone.subtitle case final subtitle?)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.eventTextStyle.copyWith(
                              color: onAccent
                                  ? theme.onAccentColor
                                  : theme.mutedTextColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Availability state of one booking slot.
enum CalendarAvailabilityState {
  /// Slot can be selected normally.
  available,

  /// Slot can be selected but has limited capacity.
  limited,

  /// Slot cannot be selected.
  unavailable,
}

/// Responsive arrangement for [CalendarAvailabilityStrip].
enum CalendarAvailabilityLayout {
  /// Resolves from finite width and text scale.
  auto,

  /// Horizontally scrolling fixed-width slots.
  horizontal,

  /// Multi-line slots that wrap to available width.
  wrap,

  /// Equal-width grid slots.
  grid,
}

/// Built-in availability visual treatments.
enum CalendarAvailabilityDesign {
  /// Balanced bordered time cards.
  card,

  /// Dense rounded capsules.
  pill,

  /// Time-led rows with duration and status.
  schedule,

  /// Restrained text and indicator treatment.
  compact,
}

/// Typed booking slot displayed by [CalendarAvailabilityStrip].
@immutable
class CalendarAvailabilitySlot<T> {
  /// Creates a half-open availability slot.
  CalendarAvailabilitySlot({
    required this.id,
    required this.start,
    required this.end,
    this.state = CalendarAvailabilityState.available,
    this.label,
    this.data,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'Must not be empty.');
    if (!end.isAfter(start)) {
      throw ArgumentError('end must be after start.');
    }
  }

  /// Stable application identity.
  final String id;

  /// Inclusive start instant.
  final DateTime start;

  /// Exclusive end instant.
  final DateTime end;

  /// Capacity state.
  final CalendarAvailabilityState state;

  /// Optional visible label.
  final String? label;

  /// Original application payload.
  final T? data;
}

/// Immutable builder state for one availability slot.
@immutable
class CalendarAvailabilityItemState<T> {
  /// Creates availability item state.
  const CalendarAvailabilityItemState({
    required this.slot,
    required this.isSelected,
    required this.isEnabled,
    required this.semanticLabel,
  });

  /// Original typed slot.
  final CalendarAvailabilitySlot<T> slot;

  /// Whether the slot ID matches the controlled selected ID.
  final bool isSelected;

  /// Whether the slot accepts interaction.
  final bool isEnabled;

  /// Localized accessibility label.
  final String semanticLabel;
}

/// Builds one complete availability item.
typedef CalendarAvailabilityBuilder<T> = Widget Function(
  BuildContext context,
  CalendarAvailabilityItemState<T> state,
);

/// Horizontal selectable time-slot strip for booking and reservation flows.
class CalendarAvailabilityStrip<T> extends StatelessWidget {
  /// Creates an availability strip.
  const CalendarAvailabilityStrip({
    super.key,
    required this.slots,
    this.selectedSlotId,
    this.onSlotSelected,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.itemExtent = 118,
    this.height = 72,
    this.layout = CalendarAvailabilityLayout.auto,
    this.design = CalendarAvailabilityDesign.card,
    this.minimumItemWidth = 96,
    this.maximumItemWidth = 180,
    this.spacing = 8,
    this.showDuration = true,
    this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
  })  : assert(itemExtent >= 72),
        assert(height >= 48),
        assert(minimumItemWidth >= 64),
        assert(maximumItemWidth >= minimumItemWidth),
        assert(spacing >= 0);

  /// Typed source slots.
  final List<CalendarAvailabilitySlot<T>> slots;

  /// Controlled selected slot ID.
  final String? selectedSlotId;

  /// Reports the original accepted slot.
  final ValueChanged<CalendarAvailabilitySlot<T>>? onSlotSelected;

  /// Shared visual configuration.
  final CalendarAppearance appearance;

  /// Fixed width of one slot.
  final double itemExtent;

  /// Strip height.
  final double height;

  /// Responsive slot arrangement.
  final CalendarAvailabilityLayout layout;

  /// Built-in slot presentation.
  final CalendarAvailabilityDesign design;

  /// Smallest slot width in wrap and grid layouts.
  final double minimumItemWidth;

  /// Largest slot width in responsive layouts.
  final double maximumItemWidth;

  /// Gap between slots.
  final double spacing;

  /// Whether built-in items show their duration.
  final bool showDuration;

  /// Optional complete slot replacement.
  final CalendarAvailabilityBuilder<T>? itemBuilder;

  /// Strip padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    Widget item(double width, int index) {
      final slot = slots[index];
      final selected = slot.id == selectedSlotId;
      final enabled = slot.state != CalendarAvailabilityState.unavailable;
      final time = DateFormat.jm(locale).format(slot.start);
      final label = '${slot.label ?? time}, ${slot.state.name}'
          '${selected ? ', selected' : ''}';
      final state = CalendarAvailabilityItemState<T>(
        slot: slot,
        isSelected: selected,
        isEnabled: enabled,
        semanticLabel: label,
      );
      return SizedBox(
        width: width,
        child: Semantics(
          label: label,
          selected: selected,
          enabled: enabled,
          button: true,
          child: InkWell(
            key: ValueKey('availability-slot-${slot.id}'),
            borderRadius: BorderRadius.circular(theme.dayBorderRadius),
            onTap: !enabled || onSlotSelected == null
                ? null
                : () => onSlotSelected!(slot),
            child: itemBuilder?.call(context, state) ??
                _DefaultAvailabilityItem(
                  state: state,
                  theme: theme,
                  design: design,
                  showDuration: showDuration,
                  locale: locale,
                ),
          ),
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(builder: (context, constraints) {
        final finiteWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : math.max(itemExtent, 320);
        final textScale =
            MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
        final resolved = layout == CalendarAvailabilityLayout.auto
            ? slots.length > 24
                ? CalendarAvailabilityLayout.horizontal
                : finiteWidth >= 520
                    ? CalendarAvailabilityLayout.grid
                    : finiteWidth >= 300 && textScale < 1.7
                        ? CalendarAvailabilityLayout.wrap
                        : CalendarAvailabilityLayout.horizontal
            : layout;
        if (resolved == CalendarAvailabilityLayout.horizontal) {
          final width = math.min(
            maximumItemWidth,
            math.max(minimumItemWidth, math.min(itemExtent, finiteWidth * .72)),
          );
          return SizedBox(
            height: height + (textScale - 1) * 28,
            child: ListView.separated(
              padding: padding,
              scrollDirection: Axis.horizontal,
              itemCount: slots.length,
              separatorBuilder: (_, __) => SizedBox(width: spacing),
              itemBuilder: (context, index) => item(width, index),
            ),
          );
        }
        final columns = resolved == CalendarAvailabilityLayout.grid
            ? math.max(1, (finiteWidth / minimumItemWidth).floor())
            : math.max(1, (finiteWidth / maximumItemWidth).floor());
        final itemWidth = math.min(
          maximumItemWidth,
          math.max(
            minimumItemWidth,
            (finiteWidth - spacing * (columns - 1)) / columns,
          ),
        );
        return Padding(
          padding: padding,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var index = 0; index < slots.length; index++)
                item(itemWidth, index)
            ],
          ),
        );
      }),
    );
  }
}

class _DefaultAvailabilityItem<T> extends StatelessWidget {
  const _DefaultAvailabilityItem({
    required this.state,
    required this.theme,
    required this.design,
    required this.showDuration,
    required this.locale,
  });

  final CalendarAvailabilityItemState<T> state;
  final HorizontalCalendarThemeData theme;
  final CalendarAvailabilityDesign design;
  final bool showDuration;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    final selected = state.isSelected;
    final foreground = selected
        ? theme.onAccentColor
        : state.isEnabled
            ? theme.textColor
            : theme.disabledColor;
    final duration = state.slot.end.difference(state.slot.start);
    final minutes = duration.inMinutes;
    final durationLabel = minutes >= 60 && minutes % 60 == 0
        ? '${minutes ~/ 60}h'
        : '${minutes}m';
    final radius = design == CalendarAvailabilityDesign.pill
        ? 1000.0
        : theme.dayBorderRadius;
    final statusColor = switch (state.slot.state) {
      CalendarAvailabilityState.available => theme.accentColor,
      CalendarAvailabilityState.limited => theme.todayColor,
      CalendarAvailabilityState.unavailable => theme.disabledColor,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? theme.accentColor
            : design == CalendarAvailabilityDesign.compact
                ? Colors.transparent
                : theme.surfaceColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              selected ? theme.accentColor : statusColor.withValues(alpha: .7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: LayoutBuilder(
          builder: (context, constraints) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: design == CalendarAvailabilityDesign.schedule
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4,
                        height: 28,
                        decoration: BoxDecoration(
                          color: selected ? theme.onAccentColor : statusColor,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.slot.label ??
                                DateFormat.jm(locale).format(state.slot.start),
                            maxLines: 1,
                            style:
                                theme.dayTextStyle.copyWith(color: foreground),
                          ),
                          Text(
                            showDuration
                                ? '$durationLabel · ${state.slot.state.name}'
                                : state.slot.state.name,
                            maxLines: 1,
                            style: theme.eventTextStyle
                                .copyWith(color: foreground),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.slot.label ??
                            DateFormat.jm(locale).format(state.slot.start),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.dayTextStyle.copyWith(color: foreground),
                      ),
                      Text(
                        showDuration
                            ? '$durationLabel · ${state.slot.state.name}'
                            : state.slot.state.name,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: theme.eventTextStyle.copyWith(color: foreground),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

int _civilKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

String _dateKey(String prefix, DateTime date) {
  return '$prefix-${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
