import 'dart:collection';

import '../models/calendar_event.dart';
import '../models/calendar_visible_interval.dart';
import 'calendar_date_math.dart';

/// Pure event segmentation and timed-event collision layout.
abstract final class CalendarEventLayout {
  /// Deduplicates [events] by ID and creates at most one segment per event ID
  /// for each intersected civil date in [interval].
  static List<CalendarEventSegment<T>> segment<T>(
    Iterable<CalendarEvent<T>> events,
    CalendarVisibleInterval interval,
  ) {
    final seenIds = <Object>{};
    final result = <CalendarEventSegment<T>>[];

    for (final event in events) {
      if (!seenIds.add(event.id)) continue;

      final eventStart = _inIntervalZone(event.start, interval);
      final eventEnd = _inIntervalZone(event.end, interval);
      if (!eventEnd.isAfter(interval.start) ||
          !eventStart.isBefore(interval.end)) {
        continue;
      }

      final visibleStart =
          eventStart.isAfter(interval.start) ? eventStart : interval.start;
      final visibleEnd =
          eventEnd.isBefore(interval.end) ? eventEnd : interval.end;
      var date = CalendarDateMath.dateOnly(visibleStart);

      while (date.isBefore(visibleEnd)) {
        final nextDate = CalendarDateMath.addDays(date, 1);
        final clippedStart = visibleStart.isAfter(date) ? visibleStart : date;
        final clippedEnd =
            visibleEnd.isBefore(nextDate) ? visibleEnd : nextDate;

        if (clippedEnd.isAfter(clippedStart)) {
          result.add(
            CalendarEventSegment<T>(
              event: event,
              date: date,
              clippedStart: clippedStart,
              clippedEnd: clippedEnd,
              continuesBefore: eventStart.isBefore(clippedStart),
              continuesAfter: eventEnd.isAfter(clippedEnd),
            ),
          );
        }
        date = nextDate;
      }
    }

    result.sort(_compareSegments);
    return UnmodifiableListView(result);
  }

  /// Assigns deterministic, non-overlapping columns to timed [segments].
  ///
  /// Segments that overlap directly or through a chain share a collision
  /// group and [CalendarTimedEventLayout.columnCount].
  static List<CalendarTimedEventLayout<T>> positionTimed<T>(
    Iterable<CalendarEventSegment<T>> segments,
  ) {
    final sorted = segments.where((segment) => !segment.isAllDay).toList()
      ..sort(_compareSegments);
    final result = <CalendarTimedEventLayout<T>>[];
    var groupStart = 0;
    var groupIndex = 0;

    while (groupStart < sorted.length) {
      var groupEnd = groupStart + 1;
      var latestEnd = sorted[groupStart].clippedEnd;
      while (groupEnd < sorted.length &&
          sorted[groupEnd].clippedStart.isBefore(latestEnd)) {
        final candidateEnd = sorted[groupEnd].clippedEnd;
        if (candidateEnd.isAfter(latestEnd)) latestEnd = candidateEnd;
        groupEnd += 1;
      }

      final columnEnds = <DateTime>[];
      final assignments = <(CalendarEventSegment<T>, int)>[];
      for (var index = groupStart; index < groupEnd; index += 1) {
        final segment = sorted[index];
        var column = 0;
        while (column < columnEnds.length &&
            columnEnds[column].isAfter(segment.clippedStart)) {
          column += 1;
        }
        if (column == columnEnds.length) {
          columnEnds.add(segment.clippedEnd);
        } else {
          columnEnds[column] = segment.clippedEnd;
        }
        assignments.add((segment, column));
      }

      for (final assignment in assignments) {
        result.add(
          CalendarTimedEventLayout<T>(
            segment: assignment.$1,
            column: assignment.$2,
            columnCount: columnEnds.length,
            collisionGroup: groupIndex,
          ),
        );
      }
      groupStart = groupEnd;
      groupIndex += 1;
    }

    return UnmodifiableListView(result);
  }

  static DateTime _inIntervalZone(
    DateTime value,
    CalendarVisibleInterval interval,
  ) {
    return interval.start.isUtc ? value.toUtc() : value.toLocal();
  }

  static int _compareSegments<T>(
    CalendarEventSegment<T> first,
    CalendarEventSegment<T> second,
  ) {
    final dateOrder = _civilKey(first.date).compareTo(_civilKey(second.date));
    if (dateOrder != 0) return dateOrder;
    final startOrder = first.clippedStart.compareTo(second.clippedStart);
    if (startOrder != 0) return startOrder;
    final endOrder = first.clippedEnd.compareTo(second.clippedEnd);
    if (endOrder != 0) return endOrder;
    return first.event.id.toString().compareTo(second.event.id.toString());
  }

  static int _civilKey(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }
}
