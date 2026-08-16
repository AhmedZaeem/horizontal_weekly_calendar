import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../domain/calendar_event_layout.dart';
import '../models/calendar_event.dart';
import '../models/calendar_visible_interval.dart';

/// Stable state of an asynchronous calendar event request.
enum CalendarEventLoadStatus {
  /// No interval has been requested.
  idle,

  /// The current interval is loading.
  loading,

  /// The current interval loaded successfully.
  ready,

  /// The current interval failed to load.
  error,
}

/// Immutable result exposed by [CalendarEventCoordinator].
@immutable
class CalendarEventSnapshot<T> {
  /// Creates an event-loading snapshot.
  const CalendarEventSnapshot({
    required this.status,
    required this.events,
    this.interval,
    this.error,
    this.stackTrace,
  });

  /// Creates the initial empty snapshot.
  const CalendarEventSnapshot.idle()
      : status = CalendarEventLoadStatus.idle,
        events = const [],
        interval = null,
        error = null,
        stackTrace = null;

  /// Current loading state.
  final CalendarEventLoadStatus status;

  /// Deduplicated events from the latest successful request.
  final List<CalendarEvent<T>> events;

  /// Interval represented by this state.
  final CalendarVisibleInterval? interval;

  /// Error returned by the latest failed request.
  final Object? error;

  /// Stack trace associated with [error].
  final StackTrace? stackTrace;

  /// Whether a request is currently in flight.
  bool get isLoading => status == CalendarEventLoadStatus.loading;

  /// Whether this snapshot contains a failed request.
  bool get hasError => status == CalendarEventLoadStatus.error;
}

/// Latest-request-wins coordinator for a [CalendarEventSource].
class CalendarEventCoordinator<T> extends ChangeNotifier {
  /// Creates a coordinator for [source].
  CalendarEventCoordinator({required this.source});

  /// Event source used for every interval request.
  final CalendarEventSource<T> source;

  CalendarEventSnapshot<T> _snapshot = const CalendarEventSnapshot.idle();
  int _requestGeneration = 0;
  bool _disposed = false;

  /// Current immutable event-loading state.
  CalendarEventSnapshot<T> get snapshot => _snapshot;

  /// Loads [interval], deduplicating an unchanged ready or in-flight request.
  Future<void> load(
    CalendarVisibleInterval interval, {
    bool force = false,
  }) async {
    if (_disposed) return;
    if (!force &&
        _snapshot.interval == interval &&
        (_snapshot.status == CalendarEventLoadStatus.loading ||
            _snapshot.status == CalendarEventLoadStatus.ready)) {
      return;
    }

    final generation = ++_requestGeneration;
    _snapshot = CalendarEventSnapshot<T>(
      status: CalendarEventLoadStatus.loading,
      interval: interval,
      events: _snapshot.events,
    );
    notifyListeners();

    try {
      final loaded = await source.load(interval);
      if (_disposed || generation != _requestGeneration) return;
      _snapshot = CalendarEventSnapshot<T>(
        status: CalendarEventLoadStatus.ready,
        interval: interval,
        events: _deduplicateAndClip(loaded, interval),
      );
    } catch (error, stackTrace) {
      if (_disposed || generation != _requestGeneration) return;
      _snapshot = CalendarEventSnapshot<T>(
        status: CalendarEventLoadStatus.error,
        interval: interval,
        events: _snapshot.events,
        error: error,
        stackTrace: stackTrace,
      );
    }
    notifyListeners();
  }

  /// Retries the current interval, including after a successful load.
  Future<void> refresh() {
    final interval = _snapshot.interval;
    if (interval == null) return Future<void>.value();
    return load(interval, force: true);
  }

  List<CalendarEvent<T>> _deduplicateAndClip(
    Iterable<CalendarEvent<T>> events,
    CalendarVisibleInterval interval,
  ) {
    final unique = <Object, CalendarEvent<T>>{};
    for (final segment in CalendarEventLayout.segment(events, interval)) {
      unique.putIfAbsent(segment.event.id, () => segment.event);
    }
    final result = unique.values.toList()
      ..sort((first, second) {
        final start = first.start.compareTo(second.start);
        if (start != 0) return start;
        final end = first.end.compareTo(second.end);
        if (end != 0) return end;
        return first.id.toString().compareTo(second.id.toString());
      });
    return UnmodifiableListView(result);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _requestGeneration += 1;
    super.dispose();
  }
}
