import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/weekly_calendar.dart';

void main() {
  group('generateWeeks', () {
    for (int startDay = 1; startDay <= 7; startDay++) {
      final dayName = const [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][startDay];

      group('starting $dayName', () {
        for (int year = 2024; year <= 2028; year++) {
          for (int month = 1; month <= 12; month++) {
            test('$year-${month.toString().padLeft(2, '0')} has all days', () {
              final weeks = generateWeeks(DateTime(year, month, 1), startDay);
              final lastDay = DateTime(year, month + 1, 0).day;

              final daysInMonth = weeks
                  .expand((w) => w)
                  .where((d) => d.month == month && d.year == year)
                  .toList();

              final dayNumbers = daysInMonth.map((d) => d.day).toSet();

              expect(dayNumbers.length, lastDay,
                  reason: 'Should have $lastDay unique days');
              expect(daysInMonth.length, lastDay,
                  reason: 'Should have no duplicate days in month');

              for (int d = 1; d <= lastDay; d++) {
                expect(dayNumbers.contains(d), true,
                    reason: 'Day $d should be present');
              }
            });
          }
        }

        test('every week has exactly 7 days', () {
          for (int year = 2024; year <= 2028; year++) {
            for (int month = 1; month <= 12; month++) {
              final weeks = generateWeeks(DateTime(year, month, 1), startDay);
              for (int w = 0; w < weeks.length; w++) {
                expect(weeks[w].length, 7,
                    reason:
                        'Week $w of $year-$month should have 7 days');
              }
            }
          }
        });

        test('first day of each week matches startDay', () {
          for (int year = 2024; year <= 2028; year++) {
            for (int month = 1; month <= 12; month++) {
              final weeks = generateWeeks(DateTime(year, month, 1), startDay);
              for (int w = 0; w < weeks.length; w++) {
                expect(weeks[w].first.weekday, startDay,
                    reason:
                        'Week $w of $year-$month should start on $dayName');
              }
            }
          }
        });

        test('days are consecutive within weeks', () {
          for (int year = 2025; year <= 2027; year++) {
            for (int month = 1; month <= 12; month++) {
              final weeks = generateWeeks(DateTime(year, month, 1), startDay);
              final allDays = weeks.expand((w) => w).toList();
              for (int i = 1; i < allDays.length; i++) {
                final diff = DateTime.utc(
                        allDays[i].year, allDays[i].month, allDays[i].day)
                    .difference(DateTime.utc(allDays[i - 1].year,
                        allDays[i - 1].month, allDays[i - 1].day))
                    .inDays;
                expect(diff, 1,
                    reason:
                        'Day $i should be 1 day after day ${i - 1} in $year-$month');
              }
            }
          }
        });
      });
    }
  });

  group('generateWeeksChunked', () {
    for (int year = 2024; year <= 2028; year++) {
      for (int month = 1; month <= 12; month++) {
        test('$year-${month.toString().padLeft(2, '0')} has all days', () {
          final weeks = generateWeeksChunked(DateTime(year, month, 1));
          final lastDay = DateTime(year, month + 1, 0).day;
          final allDays = weeks.expand((w) => w).toList();

          expect(allDays.length, lastDay);

          final dayNumbers = allDays.map((d) => d.day).toSet();
          for (int d = 1; d <= lastDay; d++) {
            expect(dayNumbers.contains(d), true,
                reason: 'Day $d should be present');
          }
        });
      }
    }

    test('last week may have fewer than 7 days', () {
      final weeks = generateWeeksChunked(DateTime(2026, 2, 1));
      expect(weeks.last.length, 7);

      final weeks31 = generateWeeksChunked(DateTime(2026, 3, 1));
      expect(weeks31.last.length, lessThanOrEqualTo(7));
    });
  });

  group('March 2026 specific (user-reported bug)', () {
    test('Saturday start shows all 31 days', () {
      final weeks = generateWeeks(DateTime(2026, 3, 1), 6);
      final marchDays = weeks
          .expand((w) => w)
          .where((d) => d.month == 3 && d.year == 2026)
          .toList();
      expect(marchDays.length, 31);
      expect(marchDays.first.day, 1);
      expect(marchDays.last.day, 31);
    });

    test('Monday start shows all 31 days', () {
      final weeks = generateWeeks(DateTime(2026, 3, 1), 1);
      final marchDays = weeks
          .expand((w) => w)
          .where((d) => d.month == 3 && d.year == 2026)
          .toList();
      expect(marchDays.length, 31);
    });

    test('Sunday start shows all 31 days', () {
      final weeks = generateWeeks(DateTime(2026, 3, 1), 7);
      final marchDays = weeks
          .expand((w) => w)
          .where((d) => d.month == 3 && d.year == 2026)
          .toList();
      expect(marchDays.length, 31);
    });
  });

  group('DST-prone months', () {
    test('April 2025 all starting days', () {
      for (int s = 1; s <= 7; s++) {
        final weeks = generateWeeks(DateTime(2025, 4, 1), s);
        final aprilDays = weeks
            .expand((w) => w)
            .where((d) => d.month == 4 && d.year == 2025)
            .toList();
        expect(aprilDays.length, 30,
            reason: 'April 2025 with start=$s should have 30 days');
      }
    });

    test('October 2025 all starting days', () {
      for (int s = 1; s <= 7; s++) {
        final weeks = generateWeeks(DateTime(2025, 10, 1), s);
        final octDays = weeks
            .expand((w) => w)
            .where((d) => d.month == 10 && d.year == 2025)
            .toList();
        expect(octDays.length, 31,
            reason: 'October 2025 with start=$s should have 31 days');
      }
    });

    test('November 2025 all starting days', () {
      for (int s = 1; s <= 7; s++) {
        final weeks = generateWeeks(DateTime(2025, 11, 1), s);
        final novDays = weeks
            .expand((w) => w)
            .where((d) => d.month == 11 && d.year == 2025)
            .toList();
        expect(novDays.length, 30,
            reason: 'November 2025 with start=$s should have 30 days');
      }
    });
  });

  group('February edge cases', () {
    test('leap year 2024 has 29 days', () {
      for (int s = 1; s <= 7; s++) {
        final weeks = generateWeeks(DateTime(2024, 2, 1), s);
        final febDays = weeks
            .expand((w) => w)
            .where((d) => d.month == 2 && d.year == 2024)
            .toList();
        expect(febDays.length, 29);
      }
    });

    test('non-leap year 2025 has 28 days', () {
      for (int s = 1; s <= 7; s++) {
        final weeks = generateWeeks(DateTime(2025, 2, 1), s);
        final febDays = weeks
            .expand((w) => w)
            .where((d) => d.month == 2 && d.year == 2025)
            .toList();
        expect(febDays.length, 28);
      }
    });
  });
}

