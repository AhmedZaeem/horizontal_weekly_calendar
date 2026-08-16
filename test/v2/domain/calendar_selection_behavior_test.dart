import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';
import 'package:horizontal_weekly_calendar/src/domain/calendar_selection_logic.dart';

void main() {
  test('single selection can explicitly toggle to empty', () {
    final selected = CalendarSelection.single(DateTime(2026, 8, 5));
    final next = CalendarSelectionLogic.select(
      selected,
      DateTime(2026, 8, 5, 18),
      behavior: const CalendarSelectionBehavior(
        singleTap: CalendarSingleTapBehavior.toggle,
      ),
    );

    expect(next.mode, CalendarSelectionMode.single);
    expect(next.selectedDate, isNull);
  });

  test('multiple selection enforces limit but permits removal', () {
    const behavior = CalendarSelectionBehavior(maximumMultipleDates: 2);
    final selected = CalendarSelection.multiple([
      DateTime(2026, 8, 3),
      DateTime(2026, 8, 4),
    ]);

    final rejected = CalendarSelectionLogic.select(
      selected,
      DateTime(2026, 8, 5),
      behavior: behavior,
    );
    final removed = CalendarSelectionLogic.select(
      selected,
      DateTime(2026, 8, 4),
      behavior: behavior,
    );

    expect(rejected, selected);
    expect(removed.selectedDates, {DateTime(2026, 8, 3)});
  });

  test('range behavior extends and clamps a completed range', () {
    final selected = CalendarSelection.range(
      CalendarDateRange(DateTime(2026, 8, 3), DateTime(2026, 8, 5)),
    );
    final next = CalendarSelectionLogic.select(
      selected,
      DateTime(2026, 8, 12),
      behavior: const CalendarSelectionBehavior(
        completedRangeTap: CalendarCompletedRangeTap.extend,
        maximumRangeDays: 5,
      ),
    );

    expect(
      next.selectedRange,
      CalendarDateRange(DateTime(2026, 8, 3), DateTime(2026, 8, 7)),
    );
  });

  test('default selection behavior preserves 2.0 transitions', () {
    final selected = CalendarSelection.range(
      CalendarDateRange(DateTime(2026, 8, 3), DateTime(2026, 8, 5)),
    );
    final next = CalendarSelectionLogic.select(selected, DateTime(2026, 8, 9));

    expect(
      next.selectedRange,
      CalendarDateRange(DateTime(2026, 8, 9), DateTime(2026, 8, 9)),
    );
  });
}
