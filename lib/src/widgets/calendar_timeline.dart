import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configuration/calendar_configuration.dart';
import '../configuration/calendar_motion.dart';
import '../domain/calendar_date_math.dart';
import '../domain/calendar_event_layout.dart';
import '../models/calendar_event.dart';
import '../models/calendar_visible_interval.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';
import 'calendar_components.dart';
import 'calendar_event_consumer.dart';

/// Geometry and visible-hour configuration shared by timeline widgets.
@immutable
class CalendarTimelineConfiguration {
  /// Creates timeline geometry.
  const CalendarTimelineConfiguration({
    this.startHour = 0,
    this.endHour = 24,
    this.hourHeight = 64,
    this.timeInterval = const Duration(minutes: 60),
    this.viewportHeight = 640,
    this.dayColumnWidth = 180,
    this.showNowIndicator = true,
    this.showAllDayEvents = true,
    this.autoScrollToNow = true,
  })  : assert(startHour >= 0 && startHour < 24),
        assert(endHour > startHour && endHour <= 24),
        assert(hourHeight >= 32),
        assert(viewportHeight > 0),
        assert(dayColumnWidth >= 96);

  /// First visible hour, inclusive.
  final int startHour;

  /// Last visible hour, exclusive.
  final int endHour;

  /// Logical pixels assigned to one hour.
  final double hourHeight;

  /// Spacing between horizontal guide lines and labels.
  final Duration timeInterval;

  /// Height of the vertically scrollable timed region.
  final double viewportHeight;

  /// Preferred width of one day in [WeekTimeline].
  final double dayColumnWidth;

  /// Whether today's current-time line is visible.
  final bool showNowIndicator;

  /// Whether all-day events are shown above timed events.
  final bool showAllDayEvents;

  /// Whether the timed region opens centred on the current time.
  ///
  /// Only applies when the timeline covers today and the current time falls
  /// inside the visible hours; otherwise the timeline opens at [startHour].
  final bool autoScrollToNow;
}

/// Rebuilds its subtree on a coarse clock so a live timeline stays current.
class _TimelineClock extends StatefulWidget {
  const _TimelineClock({required this.fixedNow, required this.builder});

  /// Fixed clock supplied by a deterministic preview or test.
  final DateTime? fixedNow;

  /// Builds content for the resolved current time.
  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<_TimelineClock> createState() => _TimelineClockState();
}

class _TimelineClockState extends State<_TimelineClock> {
  static const Duration _tick = Duration(seconds: 30);

  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = widget.fixedNow ?? DateTime.now();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant _TimelineClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fixedNow != widget.fixedNow) {
      _now = widget.fixedNow ?? DateTime.now();
      _schedule();
    }
  }

  void _schedule() {
    _timer?.cancel();
    // A fixed clock never ticks, which keeps golden previews reproducible.
    if (widget.fixedNow != null) return;
    _timer = Timer.periodic(_tick, (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now);
}

/// Builds a positioned timed event.
typedef CalendarTimedEventBuilder<T> = Widget Function(
  BuildContext context,
  CalendarTimedEventLayout<T> layout,
);

/// Builds an all-day event.
typedef CalendarAllDayEventBuilder<T> = Widget Function(
  BuildContext context,
  CalendarEvent<T> event,
);

/// Builds a time-axis label.
typedef CalendarTimeLabelBuilder = Widget Function(
  BuildContext context,
  DateTime time,
);

/// Builder overrides shared by day and week timelines.
@immutable
class CalendarTimelineBuilders<T> {
  /// Creates timeline builder overrides.
  const CalendarTimelineBuilders({
    this.timedEventBuilder,
    this.allDayEventBuilder,
    this.timeLabelBuilder,
  });

  /// Replaces a positioned timed-event tile.
  final CalendarTimedEventBuilder<T>? timedEventBuilder;

  /// Replaces an all-day event tile.
  final CalendarAllDayEventBuilder<T>? allDayEventBuilder;

  /// Replaces time-axis labels.
  final CalendarTimeLabelBuilder? timeLabelBuilder;
}

/// Scrollable single-day event timeline with deterministic overlaps.
class DayTimeline<T> extends StatelessWidget {
  /// Creates a day timeline.
  const DayTimeline({
    super.key,
    required this.date,
    this.events = const [],
    this.eventSource,
    this.configuration = const CalendarTimelineConfiguration(),
    this.appearance = const CalendarAppearance(),
    this.builders = const CalendarTimelineBuilders(),
    this.onEventTap,
    this.onEventLongPress,
    this.now,
  });

  /// Civil date represented by the timeline.
  final DateTime date;

  /// Typed events intersecting this date.
  final List<CalendarEvent<T>> events;

  /// Optional asynchronous event source for this civil date.
  final CalendarEventSource<T>? eventSource;

  /// Timeline geometry and visible hours.
  final CalendarTimelineConfiguration configuration;

  /// Shared visual configuration.
  final CalendarAppearance appearance;

  /// Timeline builder overrides.
  final CalendarTimelineBuilders<T> builders;

  /// Called with the original event.
  final ValueChanged<CalendarEvent<T>>? onEventTap;

  /// Called with the original event on long press.
  final ValueChanged<CalendarEvent<T>>? onEventLongPress;

  /// Clock override used by deterministic previews and tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final day = CalendarDateMath.dateOnly(date);
    final interval = CalendarVisibleInterval(
      day,
      CalendarDateMath.addDays(day, 1),
    );
    final source = eventSource;
    if (source != null) {
      return CalendarEventConsumer<T>(
        source: source,
        interval: interval,
        builder: (context, snapshot) => DayTimeline<T>(
          date: date,
          events: [...events, ...snapshot.events],
          configuration: configuration,
          appearance: appearance,
          builders: builders,
          onEventTap: onEventTap,
          onEventLongPress: onEventLongPress,
          now: now,
        ),
      );
    }
    final segments = CalendarEventLayout.segment(events, interval);
    final allDay = segments
        .where((segment) => segment.isAllDay)
        .map((segment) => segment.event)
        .toList();
    final positioned = CalendarEventLayout.positionTimed(segments);
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (configuration.showAllDayEvents && allDay.isNotEmpty)
          _AllDayBand<T>(
            events: allDay,
            theme: theme,
            builders: builders,
            motion: appearance.motion,
            onTap: onEventTap,
            onLongPress: onEventLongPress,
          ),
        SizedBox(
          height: configuration.viewportHeight,
          child: _TimelineClock(
            fixedNow: now,
            builder: (context, resolvedNow) => _TimedScrollView(
              configuration: configuration,
              date: day,
              now: resolvedNow,
              motion: appearance.motion,
              child: _TimedDay(
                date: day,
                layouts: positioned,
                configuration: configuration,
                theme: theme,
                motion: appearance.motion,
                builders: builders,
                onTap: onEventTap,
                onLongPress: onEventLongPress,
                now: resolvedNow,
                locale: locale,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Opens a timed region centred on the current time and settles it smoothly.
class _TimedScrollView extends StatefulWidget {
  const _TimedScrollView({
    required this.configuration,
    required this.date,
    required this.now,
    required this.motion,
    required this.child,
  });

  final CalendarTimelineConfiguration configuration;
  final DateTime date;
  final DateTime now;
  final CalendarMotion? motion;
  final Widget child;

  @override
  State<_TimedScrollView> createState() => _TimedScrollViewState();
}

class _TimedScrollViewState extends State<_TimedScrollView> {
  final ScrollController _controller = ScrollController();
  bool _aligned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _alignToNow());
  }

  void _alignToNow() {
    if (_aligned || !mounted || !_controller.hasClients) return;
    final configuration = widget.configuration;
    if (!configuration.autoScrollToNow) return;
    if (!CalendarDateMath.isSameDay(widget.now, widget.date)) return;
    if (widget.now.hour < configuration.startHour ||
        widget.now.hour >= configuration.endHour) {
      return;
    }
    _aligned = true;
    final minutes =
        (widget.now.hour - configuration.startHour) * 60.0 + widget.now.minute;
    final target = (minutes / 60 * configuration.hourHeight -
            configuration.viewportHeight / 3)
        .clamp(
      _controller.position.minScrollExtent,
      _controller.position.maxScrollExtent,
    );
    _controller.jumpTo(target);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      child: widget.child,
    );
  }
}

/// Seven-column timeline beginning at [startDate].
class WeekTimeline<T> extends StatelessWidget {
  /// Creates a week timeline.
  const WeekTimeline({
    super.key,
    required this.startDate,
    this.dayCount = 7,
    this.events = const [],
    this.eventSource,
    this.configuration = const CalendarTimelineConfiguration(),
    this.appearance = const CalendarAppearance(),
    this.builders = const CalendarTimelineBuilders(),
    this.onEventTap,
    this.onEventLongPress,
    this.now,
  }) : assert(dayCount >= 1 && dayCount <= 14);

  /// First chronological date shown.
  final DateTime startDate;

  /// Number of contiguous day columns.
  final int dayCount;

  /// Typed events shared by the day columns.
  final List<CalendarEvent<T>> events;

  /// Optional asynchronous event source for the visible day columns.
  final CalendarEventSource<T>? eventSource;

  /// Timeline geometry and visible hours.
  final CalendarTimelineConfiguration configuration;

  /// Shared visual configuration.
  final CalendarAppearance appearance;

  /// Timeline builder overrides.
  final CalendarTimelineBuilders<T> builders;

  /// Called with the original event.
  final ValueChanged<CalendarEvent<T>>? onEventTap;

  /// Called with the original event on long press.
  final ValueChanged<CalendarEvent<T>>? onEventLongPress;

  /// Clock override used by deterministic previews and tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final start = CalendarDateMath.dateOnly(startDate);
    final dates = CalendarDateMath.days(start, dayCount);
    final interval = CalendarVisibleInterval(
      start,
      CalendarDateMath.addDays(start, dayCount),
    );
    final source = eventSource;
    if (source != null) {
      return CalendarEventConsumer<T>(
        source: source,
        interval: interval,
        builder: (context, snapshot) => WeekTimeline<T>(
          startDate: startDate,
          dayCount: dayCount,
          events: [...events, ...snapshot.events],
          configuration: configuration,
          appearance: appearance,
          builders: builders,
          onEventTap: onEventTap,
          onEventLongPress: onEventLongPress,
          now: now,
        ),
      );
    }
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final labelWidth = 56.0;
    final allDayById = <Object, CalendarEvent<T>>{};
    for (final segment in CalendarEventLayout.segment(events, interval)) {
      if (segment.isAllDay) {
        allDayById.putIfAbsent(segment.event.id, () => segment.event);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (configuration.showAllDayEvents && allDayById.isNotEmpty)
          _AllDayBand<T>(
            events: allDayById.values.toList(),
            theme: theme,
            builders: builders,
            motion: appearance.motion,
            onTap: onEventTap,
            onLongPress: onEventLongPress,
          ),
        SizedBox(
          height: configuration.viewportHeight + 58,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: labelWidth + configuration.dayColumnWidth * dates.length,
              child: Column(
                children: [
                  SizedBox(
                    height: 58,
                    child: Row(
                      children: [
                        SizedBox(width: labelWidth),
                        for (final date in dates)
                          SizedBox(
                            width: configuration.dayColumnWidth,
                            child: Center(
                              child: Text(
                                DateFormat.MMMEd(locale).format(date),
                                style: theme.weekdayTextStyle.copyWith(
                                  color: theme.textColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: configuration.viewportHeight,
                    child: _TimelineClock(
                      fixedNow: now,
                      builder: (context, resolvedNow) => _TimedScrollView(
                        configuration: configuration,
                        date: start,
                        now: resolvedNow,
                        motion: appearance.motion,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TimeAxis(
                              date: start,
                              configuration: configuration,
                              theme: theme,
                              builder: builders.timeLabelBuilder,
                              locale: locale,
                            ),
                            for (final date in dates)
                              SizedBox(
                                width: configuration.dayColumnWidth,
                                child: _TimedDay<T>(
                                  date: date,
                                  events: events,
                                  configuration: configuration,
                                  theme: theme,
                                  motion: appearance.motion,
                                  builders: builders,
                                  onTap: onEventTap,
                                  onLongPress: onEventLongPress,
                                  now: resolvedNow,
                                  locale: locale,
                                  showTimeAxis: false,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimedDay<T> extends StatelessWidget {
  const _TimedDay({
    required this.date,
    this.events,
    this.layouts,
    required this.configuration,
    required this.theme,
    required this.builders,
    required this.onTap,
    required this.onLongPress,
    required this.now,
    required this.locale,
    this.motion,
    this.showTimeAxis = true,
  }) : assert(events != null || layouts != null);

  final DateTime date;
  final List<CalendarEvent<T>>? events;
  final List<CalendarTimedEventLayout<T>>? layouts;
  final CalendarTimelineConfiguration configuration;
  final HorizontalCalendarThemeData theme;
  final CalendarTimelineBuilders<T> builders;
  final ValueChanged<CalendarEvent<T>>? onTap;
  final ValueChanged<CalendarEvent<T>>? onLongPress;
  final DateTime now;
  final String? locale;
  final CalendarMotion? motion;
  final bool showTimeAxis;

  @override
  Widget build(BuildContext context) {
    final dayLayouts = layouts ?? _layoutsForDay();
    final labelWidth = showTimeAxis ? 56.0 : 0.0;
    final contentHeight = (configuration.endHour - configuration.startHour) *
        configuration.hourHeight;
    return SizedBox(
      height: contentHeight,
      child: LayoutBuilder(builder: (context, constraints) {
        final eventWidth = math.max(0.0, constraints.maxWidth - labelWidth);
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (showTimeAxis)
              _TimeAxis(
                date: date,
                configuration: configuration,
                theme: theme,
                builder: builders.timeLabelBuilder,
                locale: locale,
              ),
            PositionedDirectional(
              start: labelWidth,
              top: 0,
              bottom: 0,
              width: eventWidth,
              child: _TimelineGrid(
                configuration: configuration,
                color: theme.borderColor,
              ),
            ),
            for (final layout in dayLayouts)
              _positionedEvent(context, layout, labelWidth, eventWidth),
            if (_showNow)
              // The line glides to each new minute rather than jumping, which
              // keeps a live timeline calm while it is on screen.
              AnimatedPositionedDirectional(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : motion?.duration ?? theme.motionDuration,
                curve: motion?.curve ?? theme.motionCurve,
                start: labelWidth,
                end: 0,
                top: _minuteOffset(now) / 60 * configuration.hourHeight,
                child: CalendarNowIndicator(
                  label:
                      showTimeAxis ? DateFormat.jm(locale).format(now) : null,
                  color: theme.todayColor,
                ),
              ),
          ],
        );
      }),
    );
  }

  List<CalendarTimedEventLayout<T>> _layoutsForDay() {
    final interval = CalendarVisibleInterval(
      date,
      CalendarDateMath.addDays(date, 1),
    );
    return CalendarEventLayout.positionTimed(
      CalendarEventLayout.segment(events!, interval),
    );
  }

  Widget _positionedEvent(
    BuildContext context,
    CalendarTimedEventLayout<T> layout,
    double labelWidth,
    double eventWidth,
  ) {
    final startMinutes = _minuteOffset(layout.segment.clippedStart).clamp(
      0,
      (configuration.endHour - configuration.startHour) * 60,
    );
    final endMinutes = _minuteOffset(layout.segment.clippedEnd).clamp(
      0,
      (configuration.endHour - configuration.startHour) * 60,
    );
    if (endMinutes <= startMinutes) return const SizedBox.shrink();
    const gap = 2.0;
    final columnWidth = eventWidth / layout.columnCount;
    return PositionedDirectional(
      start: labelWidth + layout.column * columnWidth + gap,
      width: math.max(0, columnWidth - gap * 2),
      top: startMinutes / 60 * configuration.hourHeight + gap,
      height: math.max(
        24,
        (endMinutes - startMinutes) / 60 * configuration.hourHeight - gap * 2,
      ),
      child: builders.timedEventBuilder?.call(context, layout) ??
          CalendarEventTile<T>(
            event: layout.segment.event,
            theme: theme,
            compact: true,
            motion: motion,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
    );
  }

  double _minuteOffset(DateTime time) {
    return time.hour * 60.0 + time.minute - configuration.startHour * 60;
  }

  bool get _showNow {
    return configuration.showNowIndicator &&
        CalendarDateMath.isSameDay(now, date) &&
        now.hour >= configuration.startHour &&
        now.hour < configuration.endHour;
  }
}

class _TimeAxis extends StatelessWidget {
  const _TimeAxis({
    required this.date,
    required this.configuration,
    required this.theme,
    required this.builder,
    required this.locale,
  });

  final DateTime date;
  final CalendarTimelineConfiguration configuration;
  final HorizontalCalendarThemeData theme;
  final CalendarTimeLabelBuilder? builder;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (configuration.endHour - configuration.startHour) * 60;
    final intervalMinutes = math.max(1, configuration.timeInterval.inMinutes);
    final count = totalMinutes ~/ intervalMinutes + 1;
    final height = totalMinutes / 60 * configuration.hourHeight;
    return SizedBox(
      width: 56,
      height: height,
      child: Stack(
        children: [
          for (var index = 0; index < count; index += 1)
            Positioned(
              top: index * intervalMinutes / 60 * configuration.hourHeight,
              left: 0,
              right: 4,
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: builder?.call(
                      context,
                      date.add(Duration(
                        hours: configuration.startHour,
                        minutes: index * intervalMinutes,
                      )),
                    ) ??
                    Text(
                      DateFormat.jm(locale).format(date.add(Duration(
                        hours: configuration.startHour,
                        minutes: index * intervalMinutes,
                      ))),
                      style: theme.eventTextStyle.copyWith(
                        color: theme.mutedTextColor,
                        fontSize: 10,
                      ),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineGrid extends StatelessWidget {
  const _TimelineGrid({required this.configuration, required this.color});

  final CalendarTimelineConfiguration configuration;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (configuration.endHour - configuration.startHour) * 60;
    final intervalMinutes = math.max(1, configuration.timeInterval.inMinutes);
    final count = totalMinutes ~/ intervalMinutes + 1;
    return Stack(
      children: [
        for (var index = 0; index < count; index += 1)
          Positioned(
            top: index * intervalMinutes / 60 * configuration.hourHeight,
            left: 0,
            right: 0,
            child: Divider(height: 1, thickness: 1, color: color),
          ),
      ],
    );
  }
}

class _AllDayBand<T> extends StatelessWidget {
  const _AllDayBand({
    required this.events,
    required this.theme,
    required this.builders,
    required this.onTap,
    required this.onLongPress,
    this.motion,
  });

  final List<CalendarEvent<T>> events;
  final HorizontalCalendarThemeData theme;
  final CalendarTimelineBuilders<T> builders;
  final ValueChanged<CalendarEvent<T>>? onTap;
  final ValueChanged<CalendarEvent<T>>? onLongPress;
  final CalendarMotion? motion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: theme.minimumInteractiveDimension + 16,
      child: ListView.separated(
        padding: EdgeInsets.all(theme.daySpacing),
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, __) => SizedBox(width: theme.daySpacing),
        itemBuilder: (context, index) {
          final event = events[index];
          return builders.allDayEventBuilder?.call(context, event) ??
              SizedBox(
                width: 180,
                child: CalendarEventTile<T>(
                  event: event,
                  theme: theme,
                  compact: true,
                  motion: motion,
                  onTap: onTap,
                  onLongPress: onLongPress,
                ),
              );
        },
      ),
    );
  }
}
