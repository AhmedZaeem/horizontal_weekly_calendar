import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

import '../domain/calendar_date_math.dart';
import 'calendar_visible_interval.dart';

/// An immutable event rendered by calendar event widgets.
@immutable
class CalendarEvent<T> {
  /// Creates an event whose [end] must be strictly later than [start].
  CalendarEvent({
    required this.id,
    required this.start,
    required this.end,
    this.title,
    this.semanticLabel,
    this.data,
    this.color,
    this.isAllDay = false,
  }) {
    if (!end.isAfter(start)) {
      throw ArgumentError.value(
        end,
        'end',
        'must be later than start',
      );
    }
  }

  /// Stable identity used to deduplicate source results.
  final Object id;

  /// Event start instant, inclusive.
  final DateTime start;

  /// Event end instant, exclusive.
  final DateTime end;

  /// Optional display title.
  final String? title;

  /// Optional accessibility label when [title] is not sufficiently descriptive.
  final String? semanticLabel;

  /// Optional consumer payload returned unchanged by event callbacks.
  final T? data;

  /// Optional preferred presentation color.
  final Color? color;

  /// Whether this event belongs in an all-day presentation area.
  final bool isAllDay;
}

/// Loads events for a visible civil-date interval.
abstract interface class CalendarEventSource<T> {
  /// Returns events intersecting [interval].
  Future<List<CalendarEvent<T>>> load(CalendarVisibleInterval interval);
}

/// One event clipped to one intersected civil date.
@immutable
class CalendarEventSegment<T> {
  /// Creates a segment produced by the calendar event layout engine.
  const CalendarEventSegment({
    required this.event,
    required this.date,
    required this.clippedStart,
    required this.clippedEnd,
    required this.continuesBefore,
    required this.continuesAfter,
  });

  /// Original typed event.
  final CalendarEvent<T> event;

  /// Civil date occupied by this segment.
  final DateTime date;

  /// Segment start clipped to its civil day and visible interval.
  final DateTime clippedStart;

  /// Segment end clipped to its civil day and visible interval.
  final DateTime clippedEnd;

  /// Whether the original event starts before this segment.
  final bool continuesBefore;

  /// Whether the original event ends after this segment.
  final bool continuesAfter;

  /// Duration represented by this clipped segment.
  Duration get duration => clippedEnd.difference(clippedStart);

  /// Whether this segment represents an all-day event.
  bool get isAllDay => event.isAllDay;

  /// Whether this segment belongs to [date] by civil-date identity.
  bool isOn(DateTime date) => CalendarDateMath.isSameDay(this.date, date);
}

/// Horizontal placement assigned to a timed event segment.
@immutable
class CalendarTimedEventLayout<T> {
  /// Creates a deterministic timed-event placement.
  const CalendarTimedEventLayout({
    required this.segment,
    required this.column,
    required this.columnCount,
    required this.collisionGroup,
  });

  /// Segment being positioned.
  final CalendarEventSegment<T> segment;

  /// Zero-based horizontal column.
  final int column;

  /// Total columns needed by this segment's collision group.
  final int columnCount;

  /// Zero-based connected collision-group index.
  final int collisionGroup;
}
