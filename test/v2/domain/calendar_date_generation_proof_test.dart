import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';
import 'package:horizontal_weekly_calendar/weekly_calendar.dart' as legacy;

/// Years covered by the exhaustive sweeps.
///
/// Wide enough to include every Gregorian leap rule (`%4`, `%100`, `%400`),
/// the epoch, and the full range of dates a product realistically renders.
const int _firstYear = 1900;
const int _lastYear = 2100;

/// Independent oracle for a civil day number.
///
/// Deliberately computed a different way from the implementation — via UTC
/// epoch milliseconds — so a mistake in one is not mirrored in the other.
int _oracleDayNumber(int year, int month, int day) {
  const millisecondsPerDay = 24 * 60 * 60 * 1000;
  final utc = DateTime.utc(year, month, day);
  return utc.millisecondsSinceEpoch ~/ millisecondsPerDay;
}

String _label(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Asserts a run of dates is strictly contiguous, unique, and gap-free.
void _expectContiguous(List<DateTime> dates, String reason) {
  final seen = <String>{};
  for (var index = 0; index < dates.length; index += 1) {
    final date = dates[index];
    expect(
      seen.add(_label(date)),
      isTrue,
      reason: 'duplicated ${_label(date)} in $reason',
    );
    if (index == 0) continue;
    expect(
      CalendarDateMath.civilDayDifference(dates[index - 1], date),
      1,
      reason: 'gap between ${_label(dates[index - 1])} and '
          '${_label(date)} in $reason',
    );
  }
}

void main() {
  group('day-number arithmetic', () {
    test('matches an independent oracle for every day from 1900 to 2100', () {
      for (var year = _firstYear; year <= _lastYear; year += 1) {
        for (var month = 1; month <= 12; month += 1) {
          final length = CalendarDateMath.daysInMonth(year, month);
          for (var day = 1; day <= length; day += 1) {
            expect(
              CalendarDateMath.daysFromCivil(year, month, day),
              _oracleDayNumber(year, month, day),
              reason: 'day number for $year-$month-$day',
            );
          }
        }
      }
    });

    test('round-trips through civilFromDays across four centuries', () {
      final first = CalendarDateMath.daysFromCivil(_firstYear, 1, 1);
      final last = CalendarDateMath.daysFromCivil(_lastYear, 12, 31);
      for (var number = first; number <= last; number += 1) {
        final (year, month, day) = CalendarDateMath.civilFromDays(number);
        expect(
          CalendarDateMath.daysFromCivil(year, month, day),
          number,
          reason: 'round trip for day number $number',
        );
        expect(month, inInclusiveRange(1, 12));
        expect(day, inInclusiveRange(1, 31));
      }
    });

    test('round-trips far outside the epoch, in both directions', () {
      for (final number in [-3000000, -800000, -1, 0, 1, 800000, 3000000]) {
        final (year, month, day) = CalendarDateMath.civilFromDays(number);
        expect(CalendarDateMath.daysFromCivil(year, month, day), number);
      }
    });

    test('normalizes out-of-range months and days like DateTime does', () {
      final cases = <(int, int, int)>[
        (2026, 13, 1),
        (2026, 0, 1),
        (2026, -1, 15),
        (2026, 25, 1),
        (2026, 1, 0),
        (2026, 1, 32),
        (2026, 2, 30),
        (2024, 2, 30),
        (2026, 12, 62),
      ];
      for (final (year, month, day) in cases) {
        final normalized = DateTime.utc(year, month, day);
        expect(
          CalendarDateMath.daysFromCivil(year, month, day),
          _oracleDayNumber(normalized.year, normalized.month, normalized.day),
          reason: 'normalization of $year-$month-$day',
        );
      }
    });

    test('weekday is derived arithmetically and matches DateTime', () {
      final first = CalendarDateMath.daysFromCivil(_firstYear, 1, 1);
      final last = CalendarDateMath.daysFromCivil(_lastYear, 12, 31);
      for (var number = first; number <= last; number += 1) {
        final (year, month, day) = CalendarDateMath.civilFromDays(number);
        expect(
          CalendarDateMath.weekdayOf(number),
          DateTime.utc(year, month, day).weekday,
          reason: 'weekday for $year-$month-$day',
        );
      }
    });

    test('leap rules and month lengths are exact', () {
      const lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      for (var year = _firstYear; year <= _lastYear; year += 1) {
        expect(
          CalendarDateMath.isLeapYear(year),
          DateTime.utc(year, 3, 1).difference(DateTime.utc(year, 2, 1)).inDays >
              28,
          reason: 'leap rule for $year',
        );
        for (var month = 1; month <= 12; month += 1) {
          final expected = month == 2 && CalendarDateMath.isLeapYear(year)
              ? 29
              : lengths[month - 1];
          expect(
            CalendarDateMath.daysInMonth(year, month),
            expected,
            reason: 'length of $year-$month',
          );
        }
      }
    });
  });

  group('month grids', () {
    test(
        'every month from 1900 to 2100 and every first day of week produces a '
        'complete, contiguous, duplicate-free grid', () {
      for (var year = _firstYear; year <= _lastYear; year += 1) {
        for (var month = 1; month <= 12; month += 1) {
          final length = CalendarDateMath.daysInMonth(year, month);
          for (var firstDay = DateTime.monday;
              firstDay <= DateTime.sunday;
              firstDay += 1) {
            final grid = CalendarDateMath.monthGrid(
              DateTime(year, month),
              firstDay,
            );
            final where = '$year-$month first day $firstDay';

            expect(grid.length % 7, 0, reason: 'row alignment for $where');
            expect(
              grid.length ~/ 7,
              inInclusiveRange(4, 6),
              reason: 'row count for $where',
            );
            _expectContiguous(grid, 'grid for $where');
            expect(
              grid.first.weekday,
              firstDay,
              reason: 'grid start weekday for $where',
            );

            // Every day of the month appears exactly once.
            final inMonth = grid
                .where((date) => date.year == year && date.month == month)
                .toList();
            expect(inMonth, hasLength(length), reason: 'month days in $where');
            expect(inMonth.first.day, 1, reason: 'first of month in $where');
            expect(inMonth.last.day, length, reason: 'last of month in $where');

            // Leading and trailing padding never spills past one row.
            final leading =
                CalendarDateMath.civilDayDifference(grid.first, inMonth.first);
            final trailing =
                CalendarDateMath.civilDayDifference(inMonth.last, grid.last);
            expect(leading, inInclusiveRange(0, 6), reason: 'lead in $where');
            expect(trailing, inInclusiveRange(0, 6), reason: 'trail in $where');
          }
        }
      }
    });

    test('the fixed six-week grid always covers the month in 42 cells', () {
      for (var year = 2020; year <= 2040; year += 1) {
        for (var month = 1; month <= 12; month += 1) {
          for (var firstDay = DateTime.monday;
              firstDay <= DateTime.sunday;
              firstDay += 1) {
            final grid = CalendarDateMath.monthGrid(
              DateTime(year, month),
              firstDay,
              fixedSixWeeks: true,
            );
            expect(grid, hasLength(42));
            _expectContiguous(grid, 'fixed grid $year-$month/$firstDay');
            expect(grid.first.weekday, firstDay);
            expect(
              grid
                  .where((date) => date.year == year && date.month == month)
                  .length,
              CalendarDateMath.daysInMonth(year, month),
            );
          }
        }
      }
    });

    test('grids honour UTC and local mode without changing the civil dates',
        () {
      for (var month = 1; month <= 12; month += 1) {
        final local = CalendarDateMath.monthGrid(
          DateTime(2026, month),
          DateTime.monday,
        );
        final utc = CalendarDateMath.monthGrid(
          DateTime.utc(2026, month),
          DateTime.monday,
        );
        expect(local, hasLength(utc.length));
        for (var index = 0; index < local.length; index += 1) {
          expect(utc[index].isUtc, isTrue);
          // A local grid stays local unless the zone has no instant at all on
          // that civil date, in which case it is materialized in UTC. Either
          // way the civil date must agree.
          expect(
            CalendarDateMath.isSameDay(local[index], utc[index]),
            isTrue,
            reason: 'civil mismatch at index $index of month $month',
          );
        }
      }
    });
  });

  group('day runs', () {
    test('every start date in a 40-year window generates contiguous runs', () {
      final first = CalendarDateMath.daysFromCivil(2000, 1, 1);
      final last = CalendarDateMath.daysFromCivil(2040, 1, 1);
      for (var number = first; number <= last; number += 1) {
        final (year, month, day) = CalendarDateMath.civilFromDays(number);
        final run = CalendarDateMath.days(DateTime(year, month, day), 7);
        expect(run, hasLength(7));
        _expectContiguous(run, 'run from $year-$month-$day');
        expect(
          CalendarDateMath.civilDayDifference(run.first, run.last),
          6,
          reason: 'span of run from $year-$month-$day',
        );
      }
    });

    test('long runs stay contiguous across year and leap boundaries', () {
      for (final start in [
        DateTime(2023, 12, 20),
        DateTime(2024, 2, 20),
        DateTime(2100, 2, 20),
        DateTime(2000, 2, 20),
        DateTime(1900, 2, 20),
      ]) {
        final run = CalendarDateMath.days(start, 400);
        _expectContiguous(run, 'long run from ${_label(start)}');
        expect(
          CalendarDateMath.civilDayDifference(run.first, run.last),
          399,
        );
      }
    });

    test('addDays is exact in both directions over long spans', () {
      final origin = DateTime(2026, 8, 12);
      for (var offset = -4000; offset <= 4000; offset += 1) {
        final moved = CalendarDateMath.addDays(origin, offset);
        expect(
          CalendarDateMath.civilDayDifference(origin, moved),
          offset,
          reason: 'offset $offset',
        );
        expect(
          CalendarDateMath.isSameDay(
            CalendarDateMath.addDays(moved, -offset),
            origin,
          ),
          isTrue,
          reason: 'return trip for offset $offset',
        );
      }
    });

    test('every generated date reports the civil date it was asked for', () {
      // Guards two zone traps at once:
      //
      //  * a zone that begins summer time at 00:00 has no local midnight on
      //    that date;
      //  * a zone can skip a civil date entirely — Pacific/Apia never had a
      //    30 December 2011, and Pacific/Kiritimati never had a 31 December
      //    1994.
      //
      // The run is generated by the engine rather than from locally
      // constructed dates, because a local constructor can already have lost
      // the date before the engine ever sees it.
      final first = CalendarDateMath.daysFromCivil(1990, 1, 1);
      final last = CalendarDateMath.daysFromCivil(2060, 1, 1);
      final run = CalendarDateMath.days(
        DateTime(1990, 1, 1),
        last - first + 1,
      );

      for (var index = 0; index < run.length; index += 1) {
        final number = first + index;
        final (year, month, day) = CalendarDateMath.civilFromDays(number);
        final materialized = run[index];
        expect(materialized.year, year, reason: 'year for day $number');
        expect(materialized.month, month, reason: 'month for day $number');
        expect(materialized.day, day, reason: 'day for day $number');
        expect(CalendarDateMath.dayNumber(materialized), number);
      }
      _expectContiguous(run, 'seventy-year run');
    });
  });

  group('week alignment', () {
    test('startOfWeek lands on the requested weekday for 30 years of dates',
        () {
      final first = CalendarDateMath.daysFromCivil(2010, 1, 1);
      final last = CalendarDateMath.daysFromCivil(2040, 1, 1);
      for (var number = first; number <= last; number += 1) {
        final (year, month, day) = CalendarDateMath.civilFromDays(number);
        final date = DateTime(year, month, day);
        for (var firstDay = DateTime.monday;
            firstDay <= DateTime.sunday;
            firstDay += 1) {
          final start = CalendarDateMath.startOfWeek(date, firstDay);
          expect(
            start.weekday,
            firstDay,
            reason: 'weekday of week start for ${_label(date)}/$firstDay',
          );
          final offset = CalendarDateMath.civilDayDifference(start, date);
          expect(
            offset,
            inInclusiveRange(0, 6),
            reason: 'offset into week for ${_label(date)}/$firstDay',
          );
        }
      }
    });
  });

  group('1.x compatibility surface', () {
    test('generateWeeks matches the 2.0 month grid everywhere', () {
      for (var year = 1990; year <= 2060; year += 1) {
        for (var month = 1; month <= 12; month += 1) {
          for (var firstDay = DateTime.monday;
              firstDay <= DateTime.sunday;
              firstDay += 1) {
            // ignore: deprecated_member_use
            final weeks = legacy.generateWeeks(DateTime(year, month), firstDay);
            final flattened = weeks.expand((week) => week).toList();
            final grid = CalendarDateMath.monthGrid(
              DateTime(year, month),
              firstDay,
            );

            expect(
              flattened,
              hasLength(grid.length),
              reason: 'week count for $year-$month/$firstDay',
            );
            for (final week in weeks) {
              expect(week, hasLength(7));
            }
            _expectContiguous(flattened, 'legacy weeks $year-$month/$firstDay');
            for (var index = 0; index < grid.length; index += 1) {
              expect(
                CalendarDateMath.isSameDay(flattened[index], grid[index]),
                isTrue,
                reason: 'legacy mismatch at $index for $year-$month/$firstDay',
              );
            }
          }
        }
      }
    });

    test('generateWeeksChunked covers each month exactly once', () {
      for (var year = 1990; year <= 2060; year += 1) {
        for (var month = 1; month <= 12; month += 1) {
          // ignore: deprecated_member_use
          final chunks = legacy.generateWeeksChunked(DateTime(year, month));
          final flattened = chunks.expand((chunk) => chunk).toList();
          final length = CalendarDateMath.daysInMonth(year, month);

          expect(
            flattened,
            hasLength(length),
            reason: 'chunked length for $year-$month',
          );
          _expectContiguous(flattened, 'chunks for $year-$month');
          expect(flattened.first.day, 1);
          expect(flattened.last.day, length);
          expect(
            flattened.every(
              (date) => date.year == year && date.month == month,
            ),
            isTrue,
            reason: 'chunk stayed inside $year-$month',
          );
        }
      }
    });
  });
}
