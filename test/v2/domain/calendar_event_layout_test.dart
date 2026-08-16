import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  group('CalendarEventLayout.segment', () {
    test('clips events to the visible interval', () {
      final event = CalendarEvent<void>(
        id: 'trip',
        start: DateTime(2026, 8, 3, 12),
        end: DateTime(2026, 8, 6, 12),
      );
      final interval = CalendarVisibleInterval(
        DateTime(2026, 8, 4),
        DateTime(2026, 8, 6),
      );

      final segments = CalendarEventLayout.segment([event], interval);

      expect(segments, hasLength(2));
      expect(segments.map((segment) => segment.date), [
        DateTime(2026, 8, 4),
        DateTime(2026, 8, 5),
      ]);
      expect(segments.first.clippedStart, DateTime(2026, 8, 4));
      expect(segments.last.clippedEnd, DateTime(2026, 8, 6));
      expect(segments.every((segment) => segment.continuesBefore), isTrue);
      expect(segments.every((segment) => segment.continuesAfter), isTrue);
    });

    test('assigns a cross-midnight event to each intersected day once', () {
      final event = CalendarEvent<void>(
        id: 'night-shift',
        start: DateTime(2026, 8, 4, 23, 30),
        end: DateTime(2026, 8, 5, 1, 15),
      );

      final segments = CalendarEventLayout.segment(
        [event],
        CalendarVisibleInterval(
          DateTime(2026, 8, 4),
          DateTime(2026, 8, 6),
        ),
      );

      expect(segments, hasLength(2));
      expect(segments[0].clippedStart, event.start);
      expect(segments[0].clippedEnd, DateTime(2026, 8, 5));
      expect(segments[1].clippedStart, DateTime(2026, 8, 5));
      expect(segments[1].clippedEnd, event.end);
    });

    test('does not assign an event ending at midnight to the next day', () {
      final event = CalendarEvent<void>(
        id: 'until-midnight',
        start: DateTime(2026, 8, 4, 22),
        end: DateTime(2026, 8, 5),
      );

      final segments = CalendarEventLayout.segment(
        [event],
        CalendarVisibleInterval(
          DateTime(2026, 8, 4),
          DateTime(2026, 8, 6),
        ),
      );

      expect(segments, hasLength(1));
      expect(segments.single.date, DateTime(2026, 8, 4));
    });

    test('deduplicates duplicate event IDs before segmenting', () {
      final first = CalendarEvent<String>(
        id: 7,
        start: DateTime(2026, 8, 4, 9),
        end: DateTime(2026, 8, 4, 10),
        data: 'first',
      );
      final duplicate = CalendarEvent<String>(
        id: 7,
        start: DateTime(2026, 8, 4, 11),
        end: DateTime(2026, 8, 4, 12),
        data: 'duplicate',
      );

      final segments = CalendarEventLayout.segment(
        [first, duplicate],
        CalendarVisibleInterval(
          DateTime(2026, 8, 4),
          DateTime(2026, 8, 5),
        ),
      );

      expect(segments, hasLength(1));
      expect(segments.single.event, same(first));
    });

    test('returns segments in stable chronological and ID order', () {
      final events = [
        CalendarEvent<void>(
          id: 'b',
          start: DateTime(2026, 8, 4, 9),
          end: DateTime(2026, 8, 4, 10),
        ),
        CalendarEvent<void>(
          id: 'a',
          start: DateTime(2026, 8, 4, 9),
          end: DateTime(2026, 8, 4, 10),
        ),
      ];

      final segments = CalendarEventLayout.segment(
        events,
        CalendarVisibleInterval(
          DateTime(2026, 8, 4),
          DateTime(2026, 8, 5),
        ),
      );

      expect(segments.map((segment) => segment.event.id), ['a', 'b']);
    });
  });

  group('CalendarEventLayout.positionTimed', () {
    test('uses the smallest free column and reuses it after an event ends', () {
      final layouts = CalendarEventLayout.positionTimed(_segments([
        _event('a', 9, 11),
        _event('b', 10, 12),
        _event('c', 11, 13),
      ]));

      expect(layouts.map((layout) => layout.column), [0, 1, 0]);
      expect(layouts.map((layout) => layout.columnCount), [2, 2, 2]);
      expect(layouts.map((layout) => layout.collisionGroup), [0, 0, 0]);
    });

    test('keeps chained overlaps in one collision group', () {
      final layouts = CalendarEventLayout.positionTimed(_segments([
        _event('a', 9, 10),
        _event('b', 9, 11),
        _event('c', 10, 12),
        _event('d', 13, 14),
      ]));

      expect(layouts.map((layout) => layout.collisionGroup), [0, 0, 0, 1]);
      expect(
          layouts.take(3).every((layout) => layout.columnCount == 2), isTrue);
      expect(layouts.last.columnCount, 1);
    });

    test('is deterministic regardless of input ordering', () {
      final forward = _segments([
        _event('a', 9, 12),
        _event('b', 9, 10),
        _event('c', 10, 11),
      ]);
      final reverse = forward.reversed.toList();

      final first = CalendarEventLayout.positionTimed(forward);
      final second = CalendarEventLayout.positionTimed(reverse);

      expect(
        second.map((layout) => (
              layout.segment.event.id,
              layout.column,
              layout.columnCount,
              layout.collisionGroup,
            )),
        first.map((layout) => (
              layout.segment.event.id,
              layout.column,
              layout.columnCount,
              layout.collisionGroup,
            )),
      );
    });

    test('segments and positions one thousand weekly events within budget', () {
      final week = CalendarVisibleInterval(
        DateTime(2026, 8, 3),
        DateTime(2026, 8, 10),
      );
      final events = <CalendarEvent<void>>[
        for (var index = 0; index < 1000; index += 1)
          CalendarEvent<void>(
            id: index,
            start: DateTime(2026, 8, 3)
                .add(Duration(minutes: (index * 17) % (7 * 24 * 60))),
            end: DateTime(2026, 8, 3).add(
              Duration(minutes: (index * 17) % (7 * 24 * 60) + 45),
            ),
          ),
      ];
      final stopwatch = Stopwatch()..start();
      final segments = CalendarEventLayout.segment(events, week);
      final layouts = CalendarEventLayout.positionTimed(segments);
      stopwatch.stop();

      expect(segments, isNotEmpty);
      expect(layouts, hasLength(segments.length));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}

CalendarEvent<void> _event(String id, int startHour, int endHour) {
  return CalendarEvent<void>(
    id: id,
    start: DateTime(2026, 8, 4, startHour),
    end: DateTime(2026, 8, 4, endHour),
  );
}

List<CalendarEventSegment<void>> _segments(List<CalendarEvent<void>> events) {
  return CalendarEventLayout.segment(
    events,
    CalendarVisibleInterval(
      DateTime(2026, 8, 4),
      DateTime(2026, 8, 5),
    ),
  );
}
