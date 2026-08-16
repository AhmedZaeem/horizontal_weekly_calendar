import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  group('HorizontalCalendar public API', () {
    testWidgets('quick start needs only selected date and callback',
        (tester) async {
      DateTime? selected;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HorizontalCalendar(
            selectedDate: DateTime(2026, 8, 4),
            onDateSelected: (date) => selected = date,
          ),
        ),
      ));

      await tester.tap(
        find.byKey(const ValueKey('calendar-day-2026-08-05')),
      );

      expect(selected, DateTime(2026, 8, 5));
      expect(
        find.byWidgetPredicate((widget) => widget is HorizontalCalendar),
        findsOneWidget,
      );
    });

    testWidgets('controlled constructor accepts grouped advanced options',
        (tester) async {
      final event = CalendarEvent<String>(
        id: 'launch',
        start: DateTime(2026, 8, 4, 10),
        end: DateTime(2026, 8, 4, 11),
        data: 'payload',
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HorizontalCalendar<String>.controlled(
            focusedDate: DateTime(2026, 8, 4),
            selection: CalendarSelection.multiple([DateTime(2026, 8, 4)]),
            onFocusedDateChanged: (_) {},
            onSelectionChanged: (_, __) {},
            bounds: CalendarDateRange(
              DateTime(2026, 1, 1),
              DateTime(2026, 12, 31),
            ),
            behavior: const CalendarBehavior(
              visibleDayCount: 5,
              firstDayOfWeek: DateTime.sunday,
              scrolling: CalendarScrollBehavior.free,
              enableHaptics: false,
            ),
            appearance: const CalendarAppearance(
              style: CalendarStyle.neutral,
              density: CalendarDensity.compact,
              eventIndicatorStyle: EventIndicatorStyle.count,
            ),
            events: [event],
            builders: CalendarBuilders<String>(
              dayBuilder: (context, state) => Text('${state.date.day}'),
            ),
          ),
        ),
      ));

      final widget = tester.widget<HorizontalCalendar<String>>(
        find.byType(HorizontalCalendar<String>),
      );
      expect(widget.behavior.visibleDayCount, 5);
      expect(widget.appearance.density, CalendarDensity.compact);
      expect(widget.events.single.data, 'payload');
    });
  });

  group('Grouped configuration', () {
    test('behavior defaults express the flagship product defaults', () {
      const behavior = CalendarBehavior();

      expect(behavior.visibleDayCount, 7);
      expect(behavior.firstDayOfWeek, DateTime.monday);
      expect(behavior.scrolling, CalendarScrollBehavior.page);
      expect(behavior.enableGestures, isTrue);
      expect(behavior.enableKeyboard, isTrue);
      expect(behavior.enableHaptics, isTrue);
    });

    test('appearance keeps density independent from visual style', () {
      const appearance = CalendarAppearance(
        style: CalendarStyle.cupertino,
        density: CalendarDensity.spacious,
        eventIndicatorStyle: EventIndicatorStyle.stack,
      );

      expect(appearance.style, CalendarStyle.cupertino);
      expect(appearance.density, CalendarDensity.spacious);
      expect(appearance.eventIndicatorStyle, EventIndicatorStyle.stack);
    });

    test('behavior rejects unsupported date counts and weekdays', () {
      expect(
        () => CalendarBehavior(visibleDayCount: 0),
        throwsAssertionError,
      );
      expect(
        () => CalendarBehavior(visibleDayCount: 32),
        throwsAssertionError,
      );
      expect(
        () => CalendarBehavior(firstDayOfWeek: 0),
        throwsAssertionError,
      );
    });
  });

  group('Complete UI kit exports', () {
    test('new motion, style, carousel, and insight APIs are public', () {
      final motion = CalendarMotion.fluid();
      final item = CalendarCarouselItem<String>(
        date: DateTime(2026, 8, 4),
        data: 'typed',
      );
      const heatmapStyle = CalendarHeatmapStyle(levels: 6);
      const streakStyle = CalendarStreakStyle(cellExtent: 56);

      expect(motion.pageTransition, CalendarPageTransition.slide);
      expect(item.data, 'typed');
      expect(heatmapStyle.levels, 6);
      expect(streakStyle.cellExtent, 56);
      expect(CalendarStyle.values, contains(CalendarStyle.materialExpressive));
      expect(CalendarStyle.values, contains(CalendarStyle.cupertinoGlass));
    });

    test('selection, Cupertino, celestial, and planning APIs are public', () {
      const selectionBehavior = CalendarSelectionBehavior(
        maximumMultipleDates: 4,
        maximumRangeDays: 14,
      );
      const cupertino = CalendarCupertinoPickerConfiguration(
        mode: CalendarCupertinoPickerMode.monthYear,
      );
      const celestial = CelestialDatePickerStyle(showPhaseLabel: false);
      final interval = CalendarScheduleInterval<String>(
        id: 'interval',
        start: DateTime(2026, 8, 4, 9),
        end: DateTime(2026, 8, 4, 10),
        data: 'typed',
      );
      final milestone = CalendarMilestone<String>(
        id: 'milestone',
        date: DateTime(2026, 8, 10),
        title: 'Launch',
        data: 'typed',
      );
      final slot = CalendarAvailabilitySlot<String>(
        id: 'slot',
        start: DateTime(2026, 8, 4, 10),
        end: DateTime(2026, 8, 4, 10, 30),
        data: 'typed',
      );

      expect(selectionBehavior.maximumMultipleDates, 4);
      expect(cupertino.mode, CalendarCupertinoPickerMode.monthYear);
      expect(celestial.showPhaseLabel, isFalse);
      expect(interval.data, 'typed');
      expect(milestone.data, 'typed');
      expect(slot.data, 'typed');
      expect(CalendarStyle.values, contains(CalendarStyle.materialYou));
      expect(CalendarStyle.values, contains(CalendarStyle.cupertinoTinted));
    });
  });
}
