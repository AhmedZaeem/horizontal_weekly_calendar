import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  group('CalendarVisibleInterval', () {
    test('normalizes civil boundaries and treats the end as exclusive', () {
      final interval = CalendarVisibleInterval(
        DateTime(2026, 8, 4, 18, 30),
        DateTime(2026, 8, 11, 9),
      );

      expect(interval.start, DateTime(2026, 8, 4));
      expect(interval.end, DateTime(2026, 8, 11));
      expect(interval.dayCount, 7);
      expect(interval.contains(DateTime(2026, 8, 4, 23, 59)), isTrue);
      expect(interval.contains(DateTime(2026, 8, 11)), isFalse);
    });

    test('rejects an empty or reversed interval', () {
      expect(
        () => CalendarVisibleInterval(
          DateTime(2026, 8, 4),
          DateTime(2026, 8, 4),
        ),
        throwsArgumentError,
      );
      expect(
        () => CalendarVisibleInterval(
          DateTime(2026, 8, 5),
          DateTime(2026, 8, 4),
        ),
        throwsArgumentError,
      );
    });
  });

  group('CalendarEvent', () {
    test('preserves its typed payload and presentation metadata', () {
      final event = CalendarEvent<int>(
        id: 'planning',
        start: DateTime(2026, 8, 4, 10),
        end: DateTime(2026, 8, 4, 11),
        title: 'Planning',
        data: 42,
        isAllDay: false,
      );

      expect(event.id, 'planning');
      expect(event.title, 'Planning');
      expect(event.data, 42);
      expect(event.isAllDay, isFalse);
    });

    test('rejects zero-length and reversed events', () {
      expect(
        () => CalendarEvent<void>(
          id: 'empty',
          start: DateTime(2026, 8, 4, 10),
          end: DateTime(2026, 8, 4, 10),
        ),
        throwsArgumentError,
      );
      expect(
        () => CalendarEvent<void>(
          id: 'reversed',
          start: DateTime(2026, 8, 4, 11),
          end: DateTime(2026, 8, 4, 10),
        ),
        throwsArgumentError,
      );
    });
  });
}
