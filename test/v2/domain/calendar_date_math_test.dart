import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/src/domain/calendar_date_math.dart';

void main() {
  group('CalendarDateMath', () {
    // AC-1, FR-8: time-of-day never changes civil-date identity.
    test('normalizes local and UTC values without retaining time fields', () {
      final local = CalendarDateMath.dateOnly(DateTime(2026, 8, 4, 23, 59, 59));
      final utc =
          CalendarDateMath.dateOnly(DateTime.utc(2026, 8, 4, 23, 59, 59));

      expect(local, DateTime(2026, 8, 4));
      expect(local.isUtc, isFalse);
      expect(utc, DateTime.utc(2026, 8, 4));
      expect(utc.isUtc, isTrue);
    });

    test('compares civil dates independently of time-of-day', () {
      expect(
        CalendarDateMath.isSameDay(
          DateTime(2026, 8, 4, 0, 1),
          DateTime(2026, 8, 4, 23, 59),
        ),
        isTrue,
      );
      expect(
        CalendarDateMath.isSameDay(
          DateTime(2026, 8, 4, 23, 59),
          DateTime(2026, 8, 5, 0, 1),
        ),
        isFalse,
      );
    });

    // AC-1, EC-5: constructor-based arithmetic handles leap boundaries.
    test('adds civil days across leap day and year boundaries', () {
      expect(
        CalendarDateMath.addDays(DateTime(2024, 2, 28, 17), 1),
        DateTime(2024, 2, 29),
      );
      expect(
        CalendarDateMath.addDays(DateTime(2024, 12, 31, 17), 1),
        DateTime(2025, 1, 1),
      );
      expect(
        CalendarDateMath.addDays(DateTime(2025, 1, 1, 17), -1),
        DateTime(2024, 12, 31),
      );
    });

    test('preserves UTC when adding civil days', () {
      expect(
        CalendarDateMath.addDays(DateTime.utc(2026, 12, 31, 23), 1),
        DateTime.utc(2027, 1, 1),
      );
    });

    // FR-15: any valid first weekday produces the correct week anchor.
    test('finds start of week for every configured first weekday', () {
      final date = DateTime(2026, 8, 5);

      for (var firstWeekday = DateTime.monday;
          firstWeekday <= DateTime.sunday;
          firstWeekday++) {
        final start = CalendarDateMath.startOfWeek(date, firstWeekday);
        expect(start.weekday, firstWeekday);
        expect(
          CalendarDateMath.days(start, 7).any(
            (candidate) => CalendarDateMath.isSameDay(candidate, date),
          ),
          isTrue,
        );
      }
    });

    test('rejects invalid first weekday values', () {
      expect(
        () => CalendarDateMath.startOfWeek(DateTime(2026, 8, 4), 0),
        throwsArgumentError,
      );
      expect(
        () => CalendarDateMath.startOfWeek(DateTime(2026, 8, 4), 8),
        throwsArgumentError,
      );
    });

    // NFR-COR-1: exhaustive 1900-2100 month matrix has no gaps or duplicates.
    test('generates every month from 1900 through 2100 without gaps', () {
      for (var year = 1900; year <= 2100; year++) {
        for (var month = 1; month <= 12; month++) {
          final count = CalendarDateMath.daysInMonth(year, month);
          final days =
              CalendarDateMath.days(DateTime(year, month, 1, 18), count);

          expect(days, hasLength(count));
          for (var index = 0; index < days.length; index++) {
            // Compared by civil identity rather than by DateTime equality:
            // a zone can have no instant at all on a given civil date —
            // Pacific/Apia skipped 2011-12-30 when it crossed the date line —
            // so `DateTime(year, month, day)` is not a sound expectation.
            final date = days[index];
            expect(date.year, year, reason: 'year of $year-$month day $index');
            expect(date.month, month, reason: 'month of $year-$month');
            expect(date.day, index + 1, reason: 'day of $year-$month');
          }
          expect(
            days.map(CalendarDateMath.dayNumber).toSet(),
            hasLength(count),
            reason: 'duplicate civil dates in $year-$month',
          );
        }
      }
    });

    test('returns an empty list for zero days and rejects negative counts', () {
      expect(CalendarDateMath.days(DateTime(2026, 8, 4), 0), isEmpty);
      expect(
        () => CalendarDateMath.days(DateTime(2026, 8, 4), -1),
        throwsArgumentError,
      );
    });

    // FR-30, EC-14: month grids have only the rows the month needs.
    test('builds four, five, and six-row month grids when required', () {
      expect(
        CalendarDateMath.monthGrid(DateTime(2026, 2), DateTime.sunday),
        hasLength(28),
      );
      expect(
        CalendarDateMath.monthGrid(DateTime(2026, 4), DateTime.monday),
        hasLength(35),
      );
      expect(
        CalendarDateMath.monthGrid(DateTime(2026, 8), DateTime.monday),
        hasLength(42),
      );
    });

    test('six-week month grids always contain 42 contiguous unique dates', () {
      for (var month = 1; month <= 12; month++) {
        final days = CalendarDateMath.monthGrid(
          DateTime(2026, month),
          DateTime.monday,
          fixedSixWeeks: true,
        );

        expect(days, hasLength(42));
        expect(days.toSet(), hasLength(42));
        for (var index = 1; index < days.length; index++) {
          expect(days[index], CalendarDateMath.addDays(days[index - 1], 1));
        }
      }
    });

    // EC-1 and EC-3: inclusive bounds clamp by civil date.
    test('clamps before/after bounds and removes time from in-range values',
        () {
      final minimum = DateTime(2026, 8, 4, 12);
      final maximum = DateTime(2026, 8, 10, 12);

      expect(
        CalendarDateMath.clamp(DateTime(2026, 8, 1), minimum, maximum),
        DateTime(2026, 8, 4),
      );
      expect(
        CalendarDateMath.clamp(DateTime(2026, 8, 20), minimum, maximum),
        DateTime(2026, 8, 10),
      );
      expect(
        CalendarDateMath.clamp(DateTime(2026, 8, 7, 23), minimum, maximum),
        DateTime(2026, 8, 7),
      );
    });

    // EC-2: invalid bounds are rejected clearly.
    test('rejects bounds where minimum is after maximum', () {
      expect(
        () => CalendarDateMath.clamp(
          DateTime(2026, 8, 7),
          DateTime(2026, 8, 10),
          DateTime(2026, 8, 4),
        ),
        throwsArgumentError,
      );
    });
  });
}
