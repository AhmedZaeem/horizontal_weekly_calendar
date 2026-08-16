import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  group('CalendarDateRange', () {
    test('normalizes endpoints and includes both boundaries', () {
      final range = CalendarDateRange(
        DateTime(2026, 8, 4, 19),
        DateTime(2026, 8, 10, 7),
      );

      expect(range.start, DateTime(2026, 8, 4));
      expect(range.end, DateTime(2026, 8, 10));
      expect(range.contains(DateTime(2026, 8, 4, 23)), isTrue);
      expect(range.contains(DateTime(2026, 8, 10, 23)), isTrue);
      expect(range.contains(DateTime(2026, 8, 11)), isFalse);
    });

    test('supports a one-day inclusive range', () {
      final range = CalendarDateRange(
        DateTime(2026, 8, 4, 1),
        DateTime(2026, 8, 4, 23),
      );

      expect(range.dayCount, 1);
      expect(range.dates, [DateTime(2026, 8, 4)]);
    });

    test('rejects a reversed range', () {
      expect(
        () => CalendarDateRange(DateTime(2026, 8, 10), DateTime(2026, 8, 4)),
        throwsArgumentError,
      );
    });
  });

  group('CalendarSelection', () {
    // FR-11: all supported controlled modes normalize input.
    test('single selection normalizes its selected date', () {
      final selection = CalendarSelection.single(DateTime(2026, 8, 4, 23));

      expect(selection.mode, CalendarSelectionMode.single);
      expect(selection.selectedDate, DateTime(2026, 8, 4));
      expect(selection.contains(DateTime(2026, 8, 4, 1)), isTrue);
    });

    test('empty single selection contains no date', () {
      final selection = CalendarSelection.single(null);

      expect(selection.selectedDate, isNull);
      expect(selection.contains(DateTime(2026, 8, 4)), isFalse);
    });

    test('multiple selection normalizes and deduplicates civil dates', () {
      final selection = CalendarSelection.multiple({
        DateTime(2026, 8, 4, 1),
        DateTime(2026, 8, 4, 23),
        DateTime(2026, 8, 6, 12),
      });

      expect(selection.mode, CalendarSelectionMode.multiple);
      expect(selection.selectedDates, {
        DateTime(2026, 8, 4),
        DateTime(2026, 8, 6),
      });
    });

    test('multiple selection exposes an immutable set', () {
      final selection = CalendarSelection.multiple({DateTime(2026, 8, 4)});

      expect(
        () => selection.selectedDates.add(DateTime(2026, 8, 5)),
        throwsUnsupportedError,
      );
    });

    test('range selection uses inclusive civil-date containment', () {
      final selection = CalendarSelection.range(
        CalendarDateRange(DateTime(2026, 8, 4), DateTime(2026, 8, 6)),
      );

      expect(selection.mode, CalendarSelectionMode.range);
      expect(selection.contains(DateTime(2026, 8, 4, 22)), isTrue);
      expect(selection.contains(DateTime(2026, 8, 5, 22)), isTrue);
      expect(selection.contains(DateTime(2026, 8, 6, 22)), isTrue);
      expect(selection.contains(DateTime(2026, 8, 7)), isFalse);
    });

    test('equal selections have stable value equality and hash codes', () {
      final first = CalendarSelection.multiple({
        DateTime(2026, 8, 4, 1),
        DateTime(2026, 8, 6, 1),
      });
      final second = CalendarSelection.multiple({
        DateTime(2026, 8, 6, 23),
        DateTime(2026, 8, 4, 23),
      });

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('selection mode constructors expose only their relevant value', () {
      final single = CalendarSelection.single(DateTime(2026, 8, 4));
      final multiple = CalendarSelection.multiple({DateTime(2026, 8, 4)});
      final range = CalendarSelection.range(
        CalendarDateRange(DateTime(2026, 8, 4), DateTime(2026, 8, 5)),
      );

      expect(single.selectedDates, isEmpty);
      expect(single.selectedRange, isNull);
      expect(multiple.selectedDate, isNull);
      expect(multiple.selectedRange, isNull);
      expect(range.selectedDate, isNull);
      expect(range.selectedDates, isEmpty);
    });
  });

  test('multiple selection treats local and UTC values as one civil date', () {
    final selection = CalendarSelection.multiple([
      DateTime(2026, 8, 5, 23),
      DateTime.utc(2026, 8, 5, 1),
    ]);

    expect(selection.selectedDates, hasLength(1));
    expect(selection.contains(DateTime.utc(2026, 8, 5, 12)), isTrue);
    expect(
      selection,
      CalendarSelection.multiple([DateTime.utc(2026, 8, 5)]),
    );
  });
}
