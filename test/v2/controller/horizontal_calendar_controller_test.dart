import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  group('HorizontalCalendarController', () {
    test('normalizes and clamps its initial focused date', () {
      final controller = HorizontalCalendarController(
        focusedDate: DateTime(2026, 8, 20, 19, 45),
        minimumDate: DateTime(2026, 8, 1, 12),
        maximumDate: DateTime(2026, 8, 10, 23, 59),
      );
      addTearDown(controller.dispose);

      expect(controller.focusedDate, DateTime(2026, 8, 10));
      expect(controller.minimumDate, DateTime(2026, 8, 1));
      expect(controller.maximumDate, DateTime(2026, 8, 10));
    });

    test('rejects reversed bounds and unsupported visible-day counts', () {
      expect(
        () => HorizontalCalendarController(
          minimumDate: DateTime(2026, 8, 2),
          maximumDate: DateTime(2026, 8, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => HorizontalCalendarController(visibleDayCount: 0),
        throwsRangeError,
      );
      expect(
        () => HorizontalCalendarController(visibleDayCount: 32),
        throwsRangeError,
      );
    });

    test('moves by one visible page using civil-date arithmetic', () async {
      final controller = HorizontalCalendarController(
        focusedDate: DateTime(2024, 2, 26),
        visibleDayCount: 7,
      );
      addTearDown(controller.dispose);

      await controller.next(animate: false);
      expect(controller.focusedDate, DateTime(2024, 3, 4));
      expect(controller.lastNavigationDirection,
          CalendarNavigationDirection.forward);
      expect(controller.shouldAnimateLastCommand, isFalse);

      await controller.previous();
      expect(controller.focusedDate, DateTime(2024, 2, 26));
      expect(
        controller.lastNavigationDirection,
        CalendarNavigationDirection.backward,
      );
      expect(controller.shouldAnimateLastCommand, isTrue);
    });

    test('reports actual direction after bounds resolution', () async {
      final controller = HorizontalCalendarController(
        focusedDate: DateTime(2026, 8, 8),
        minimumDate: DateTime(2026, 8, 1),
        maximumDate: DateTime(2026, 8, 10),
        visibleDayCount: 7,
      );
      addTearDown(controller.dispose);

      await controller.next();
      expect(controller.focusedDate, DateTime(2026, 8, 10));
      expect(controller.lastNavigationDirection,
          CalendarNavigationDirection.forward);

      await controller.focusDate(DateTime(2026, 7, 1));
      expect(controller.focusedDate, DateTime(2026, 8, 1));
      expect(
        controller.lastNavigationDirection,
        CalendarNavigationDirection.backward,
      );
    });

    test('notifies exactly once for a change and not for a no-op', () async {
      final controller = HorizontalCalendarController(
        focusedDate: DateTime(2026, 8, 4),
      );
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications += 1);

      await controller.focusDate(DateTime(2026, 8, 4, 22));
      expect(notifications, 0);

      await controller.focusDate(DateTime(2026, 8, 5));
      expect(notifications, 1);
    });

    test('changes fold state once and converges on the latest request',
        () async {
      final controller = HorizontalCalendarController(
        foldState: CalendarFoldState.collapsed,
      );
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications += 1);

      await controller.setFoldState(CalendarFoldState.expanded);
      await controller.setFoldState(CalendarFoldState.collapsed);
      await controller.setFoldState(CalendarFoldState.collapsed);

      expect(controller.foldState, CalendarFoldState.collapsed);
      expect(notifications, 2);
    });

    test('updates normalized selection without duplicate notifications', () {
      final controller = HorizontalCalendarController(
        selection: CalendarSelection.single(DateTime(2026, 8, 4, 20)),
      );
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications += 1);

      controller.updateSelection(
        CalendarSelection.single(DateTime(2026, 8, 4, 8)),
      );
      controller.updateSelection(
        CalendarSelection.multiple([
          DateTime(2026, 8, 5, 9),
          DateTime(2026, 8, 5, 18),
        ]),
      );

      expect(notifications, 1);
      expect(controller.selection.mode, CalendarSelectionMode.multiple);
      expect(controller.selection.selectedDates, {DateTime(2026, 8, 5)});
    });

    test('today honors bounds and removes time-of-day', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final controller = HorizontalCalendarController(
        focusedDate: DateTime(2000, 1, 1),
        minimumDate: today,
        maximumDate: today,
      );
      addTearDown(controller.dispose);

      await controller.today();

      expect(controller.focusedDate, today);
    });

    test('commands after disposal are safe no-ops', () async {
      final controller = HorizontalCalendarController(
        focusedDate: DateTime(2026, 8, 4),
      );
      controller.dispose();

      await controller.next();
      await controller.setFoldState(CalendarFoldState.expanded);

      expect(controller.focusedDate, DateTime(2026, 8, 4));
      expect(controller.foldState, CalendarFoldState.collapsed);
    });
  });
}
