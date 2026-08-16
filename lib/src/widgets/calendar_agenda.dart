import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configuration/calendar_configuration.dart';
import '../controller/calendar_event_coordinator.dart';
import '../domain/calendar_date_math.dart';
import '../domain/calendar_event_layout.dart';
import '../models/calendar_event.dart';
import '../models/calendar_visible_interval.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';
import 'calendar_components.dart';

/// Builds an agenda state such as loading or empty content.
typedef CalendarAgendaStateBuilder = Widget Function(BuildContext context);

/// Builds an agenda error with a retry action.
typedef CalendarAgendaErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  VoidCallback retry,
);

/// Builds a civil-date section header.
typedef CalendarAgendaSectionBuilder = Widget Function(
  BuildContext context,
  DateTime date,
  int eventCount,
);

/// Builds a typed agenda event tile.
typedef CalendarAgendaEventBuilder<T> = Widget Function(
  BuildContext context,
  CalendarEvent<T> event,
);

/// Focused builder overrides for [CalendarAgenda].
@immutable
class CalendarAgendaBuilders<T> {
  /// Creates agenda builder overrides.
  const CalendarAgendaBuilders({
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.sectionBuilder,
    this.eventBuilder,
  });

  /// Replaces the default progress presentation.
  final CalendarAgendaStateBuilder? loadingBuilder;

  /// Replaces the default empty presentation.
  final CalendarAgendaStateBuilder? emptyBuilder;

  /// Replaces the default error presentation.
  final CalendarAgendaErrorBuilder? errorBuilder;

  /// Replaces each date section header.
  final CalendarAgendaSectionBuilder? sectionBuilder;

  /// Replaces each event tile.
  final CalendarAgendaEventBuilder<T>? eventBuilder;
}

/// Date-grouped event agenda for synchronous lists or asynchronous sources.
class CalendarAgenda<T> extends StatefulWidget {
  /// Creates an agenda.
  const CalendarAgenda({
    super.key,
    required this.interval,
    this.events = const [],
    this.eventSource,
    this.appearance = const CalendarAppearance(),
    this.builders = const CalendarAgendaBuilders(),
    this.onEventTap,
    this.onEventLongPress,
    this.showEmptyDays = false,
    this.padding,
  });

  /// Half-open civil-date interval represented by the agenda.
  final CalendarVisibleInterval interval;

  /// Synchronous typed events.
  final List<CalendarEvent<T>> events;

  /// Optional asynchronous event source.
  final CalendarEventSource<T>? eventSource;

  /// Shared theme and style configuration.
  final CalendarAppearance appearance;

  /// Agenda-specific builder overrides.
  final CalendarAgendaBuilders<T> builders;

  /// Called with the original typed event.
  final ValueChanged<CalendarEvent<T>>? onEventTap;

  /// Called on a long press with the original typed event.
  final ValueChanged<CalendarEvent<T>>? onEventLongPress;

  /// Whether civil dates with no events remain visible.
  final bool showEmptyDays;

  /// Optional list padding.
  final EdgeInsetsGeometry? padding;

  @override
  State<CalendarAgenda<T>> createState() => _CalendarAgendaState<T>();
}

class _CalendarAgendaState<T> extends State<CalendarAgenda<T>> {
  CalendarEventCoordinator<T>? _coordinator;

  @override
  void initState() {
    super.initState();
    _attachSource();
  }

  @override
  void didUpdateWidget(covariant CalendarAgenda<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventSource != widget.eventSource) {
      _detachSource();
      _attachSource();
    } else if (oldWidget.interval != widget.interval) {
      _coordinator?.load(widget.interval);
    }
  }

  void _attachSource() {
    final source = widget.eventSource;
    if (source == null) return;
    _coordinator = CalendarEventCoordinator<T>(source: source)
      ..addListener(_sourceChanged)
      ..load(widget.interval);
  }

  void _detachSource() {
    _coordinator
      ?..removeListener(_sourceChanged)
      ..dispose();
    _coordinator = null;
  }

  void _sourceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _detachSource();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, widget.appearance);
    final motion = widget.appearance.motion;
    final duration = motion?.effectiveDuration(context) ??
        (MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : theme.motionDuration);
    // Loading, error, empty, and populated agendas cross-fade through one
    // switcher, so a source that resolves quickly never flashes.
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: motion?.curve ?? theme.motionCurve,
      switchOutCurve: motion?.reverseCurve ?? theme.motionCurve,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.passthrough,
        children: [...previous, if (current != null) current],
      ),
      child: _buildBody(context, theme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HorizontalCalendarThemeData theme,
  ) {
    final snapshot = _coordinator?.snapshot;
    if (snapshot?.status == CalendarEventLoadStatus.loading &&
        snapshot!.events.isEmpty &&
        widget.events.isEmpty) {
      return KeyedSubtree(
        key: const ValueKey('calendar-agenda-loading'),
        child: widget.builders.loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (snapshot?.hasError == true &&
        snapshot!.events.isEmpty &&
        widget.events.isEmpty) {
      return KeyedSubtree(
        key: const ValueKey('calendar-agenda-error'),
        child: widget.builders.errorBuilder?.call(
              context,
              snapshot.error!,
              _refresh,
            ) ??
            _AgendaError(error: snapshot.error!, onRetry: _refresh),
      );
    }

    final allEvents = [...widget.events, ...?snapshot?.events];
    final sections = _sections(allEvents);
    if (sections.isEmpty) {
      return KeyedSubtree(
        key: const ValueKey('calendar-agenda-empty'),
        child: widget.builders.emptyBuilder?.call(context) ??
            const Center(child: Text('No events')),
      );
    }

    final locale = Localizations.maybeLocaleOf(context)?.toString();
    return RefreshIndicator.adaptive(
      key: ValueKey('calendar-agenda-${widget.interval.start}'),
      onRefresh: () async => _coordinator?.refresh(),
      child: ListView.builder(
        padding: widget.padding ?? EdgeInsets.all(theme.contentPadding),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Padding(
            padding: EdgeInsets.only(bottom: theme.daySpacing * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                widget.builders.sectionBuilder?.call(
                      context,
                      section.date,
                      section.events.length,
                    ) ??
                    Text(
                      DateFormat.yMMMMEEEEd(locale).format(section.date),
                      style: theme.headerTextStyle.copyWith(
                        color: theme.textColor,
                      ),
                    ),
                SizedBox(height: theme.daySpacing),
                if (section.events.isEmpty)
                  Text(
                    'No events',
                    style: theme.eventTextStyle.copyWith(
                      color: theme.mutedTextColor,
                    ),
                  )
                else
                  for (var eventIndex = 0;
                      eventIndex < section.events.length;
                      eventIndex += 1) ...[
                    widget.builders.eventBuilder?.call(
                          context,
                          section.events[eventIndex],
                        ) ??
                        CalendarEventTile<T>(
                          event: section.events[eventIndex],
                          theme: theme,
                          motion: widget.appearance.motion,
                          onTap: widget.onEventTap,
                          onLongPress: widget.onEventLongPress,
                          trailing: Text(
                            _timeLabel(section.events[eventIndex], locale),
                            style: theme.eventTextStyle.copyWith(
                              color: theme.mutedTextColor,
                            ),
                          ),
                        ),
                    if (eventIndex != section.events.length - 1)
                      SizedBox(height: theme.daySpacing),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _refresh() => _coordinator?.refresh();

  List<_AgendaSection<T>> _sections(Iterable<CalendarEvent<T>> events) {
    final grouped = <int, _AgendaSection<T>>{};
    if (widget.showEmptyDays) {
      for (var offset = 0; offset < widget.interval.dayCount; offset += 1) {
        final date = CalendarDateMath.addDays(widget.interval.start, offset);
        grouped[_civilKey(date)] = _AgendaSection(date, []);
      }
    }
    for (final segment
        in CalendarEventLayout.segment(events, widget.interval)) {
      final key = _civilKey(segment.date);
      final section = grouped.putIfAbsent(
        key,
        () => _AgendaSection(segment.date, []),
      );
      if (section.events.every((event) => event.id != segment.event.id)) {
        section.events.add(segment.event);
      }
    }
    final result = grouped.values.toList()
      ..sort((first, second) =>
          _civilKey(first.date).compareTo(_civilKey(second.date)));
    for (final section in result) {
      section.events.sort((first, second) {
        final start = first.start.compareTo(second.start);
        if (start != 0) return start;
        return first.id.toString().compareTo(second.id.toString());
      });
    }
    return UnmodifiableListView(result);
  }

  String _timeLabel(CalendarEvent<T> event, String? locale) {
    if (event.isAllDay) return 'All day';
    final format = DateFormat.jm(locale);
    return '${format.format(event.start)} – ${format.format(event.end)}';
  }
}

class _AgendaSection<T> {
  _AgendaSection(this.date, this.events);

  final DateTime date;
  final List<CalendarEvent<T>> events;
}

class _AgendaError extends StatelessWidget {
  const _AgendaError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Could not load events: $error'),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

int _civilKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;
