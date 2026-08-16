import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/weekly_calendar.dart';

void main() {
  group('isSameDay', () {
    test('same date returns true', () {
      expect(isSameDay(DateTime(2026, 3, 15), DateTime(2026, 3, 15)), true);
    });

    test('different day returns false', () {
      expect(isSameDay(DateTime(2026, 3, 15), DateTime(2026, 3, 16)), false);
    });

    test('different month returns false', () {
      expect(isSameDay(DateTime(2026, 3, 15), DateTime(2026, 4, 15)), false);
    });

    test('different year returns false', () {
      expect(isSameDay(DateTime(2026, 3, 15), DateTime(2027, 3, 15)), false);
    });

    test('ignores time component', () {
      expect(
          isSameDay(
              DateTime(2026, 3, 15, 10, 30), DateTime(2026, 3, 15, 22, 0)),
          true);
    });
  });

  group('isDateDisabled', () {
    test('returns false when no bounds', () {
      expect(isDateDisabled(DateTime(2026, 3, 15), null, null), false);
    });

    test('returns true when before minDate', () {
      expect(isDateDisabled(DateTime(2026, 3, 10), DateTime(2026, 3, 15), null),
          true);
    });

    test('returns false when equal to minDate', () {
      expect(isDateDisabled(DateTime(2026, 3, 15), DateTime(2026, 3, 15), null),
          false);
    });

    test('returns false when after minDate', () {
      expect(isDateDisabled(DateTime(2026, 3, 20), DateTime(2026, 3, 15), null),
          false);
    });

    test('returns true when after maxDate', () {
      expect(isDateDisabled(DateTime(2026, 3, 20), null, DateTime(2026, 3, 15)),
          true);
    });

    test('returns false when equal to maxDate', () {
      expect(isDateDisabled(DateTime(2026, 3, 15), null, DateTime(2026, 3, 15)),
          false);
    });

    test('returns false when before maxDate', () {
      expect(isDateDisabled(DateTime(2026, 3, 10), null, DateTime(2026, 3, 15)),
          false);
    });

    test('returns false when within range', () {
      expect(
          isDateDisabled(DateTime(2026, 3, 15), DateTime(2026, 3, 10),
              DateTime(2026, 3, 20)),
          false);
    });

    test('returns true when outside range (before)', () {
      expect(
          isDateDisabled(DateTime(2026, 3, 5), DateTime(2026, 3, 10),
              DateTime(2026, 3, 20)),
          true);
    });

    test('returns true when outside range (after)', () {
      expect(
          isDateDisabled(DateTime(2026, 3, 25), DateTime(2026, 3, 10),
              DateTime(2026, 3, 20)),
          true);
    });
  });

  group('canNavigateToPreviousMonth', () {
    test('returns true when no minDate', () {
      expect(canNavigateToPreviousMonth(DateTime(2026, 3, 1), null), true);
    });

    test('returns true when previous month has selectable days', () {
      expect(
          canNavigateToPreviousMonth(
              DateTime(2026, 3, 1), DateTime(2026, 2, 15)),
          true);
    });

    test('returns false when previous month is fully before minDate', () {
      expect(
          canNavigateToPreviousMonth(
              DateTime(2026, 3, 1), DateTime(2026, 3, 1)),
          false);
    });

    test('returns true when minDate is in previous month', () {
      expect(
          canNavigateToPreviousMonth(
              DateTime(2026, 3, 1), DateTime(2026, 2, 28)),
          true);
    });
  });

  group('canNavigateToNextMonth', () {
    test('returns true when no maxDate', () {
      expect(canNavigateToNextMonth(DateTime(2026, 3, 1), null), true);
    });

    test('returns true when next month has selectable days', () {
      expect(
          canNavigateToNextMonth(DateTime(2026, 3, 1), DateTime(2026, 4, 15)),
          true);
    });

    test('returns false when next month starts after maxDate', () {
      expect(
          canNavigateToNextMonth(DateTime(2026, 3, 1), DateTime(2026, 3, 31)),
          false);
    });

    test('returns true when maxDate is in next month', () {
      expect(canNavigateToNextMonth(DateTime(2026, 3, 1), DateTime(2026, 4, 1)),
          true);
    });
  });
}
