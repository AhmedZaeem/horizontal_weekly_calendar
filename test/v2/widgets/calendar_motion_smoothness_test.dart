import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  group('CalendarMotion gesture tokens', () {
    test('defaults enable gesture following and press feedback', () {
      final motion = CalendarMotion();

      expect(motion.followGestures, isTrue);
      expect(motion.pressScale, lessThan(1));
      expect(motion.spring, isNull);
      expect(motion.settleSpring.stiffness, greaterThan(0));
    });

    test('the immediate preset disables every gesture-driven effect', () {
      final motion = CalendarMotion.none();

      expect(motion.followGestures, isFalse);
      expect(motion.pressScale, 1);
      expect(motion.hoverScale, 1);
    });

    test('copyWith carries the new tokens', () {
      final motion = CalendarMotion().copyWith(
        pressScale: .9,
        followGestures: false,
      );

      expect(motion.pressScale, .9);
      expect(motion.followGestures, isFalse);
    });

    testWidgets('isEnabled follows the ambient animation preference',
        (tester) async {
      late bool enabled;
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(builder: (context) {
          enabled = CalendarMotion.fluid().isEnabled(context);
          return const SizedBox();
        }),
      ));

      expect(enabled, isFalse);
    });
  });

  group('HorizontalCalendar drag following', () {
    testWidgets('a short drag settles back without changing the page',
        (tester) async {
      final focused = <DateTime>[];
      await tester.pumpWidget(_app(
        HorizontalCalendar<Object?>.controlled(
          focusedDate: DateTime(2026, 8, 3),
          selection: CalendarSelection.single(null),
          onFocusedDateChanged: focused.add,
          onSelectionChanged: (_, __) {},
          appearance: CalendarAppearance(motion: CalendarMotion.fluid()),
        ),
      ));

      await tester.drag(
        find.byType(HorizontalCalendar<Object?>),
        const Offset(-24, 0),
      );
      await tester.pumpAndSettle();

      expect(focused, isEmpty);
    });

    testWidgets('a fling below the distance threshold still steps a page',
        (tester) async {
      final focused = <DateTime>[];
      await tester.pumpWidget(_app(
        HorizontalCalendar<Object?>.controlled(
          focusedDate: DateTime(2026, 8, 3),
          selection: CalendarSelection.single(null),
          onFocusedDateChanged: focused.add,
          onSelectionChanged: (_, __) {},
          appearance: CalendarAppearance(motion: CalendarMotion.fluid()),
        ),
      ));

      await tester.fling(
        find.byType(HorizontalCalendar<Object?>),
        const Offset(-40, 0),
        1200,
      );
      await tester.pumpAndSettle();

      expect(focused, [DateTime(2026, 8, 10)]);
    });

    testWidgets('bounds block a step the calendar cannot take', (tester) async {
      final focused = <DateTime>[];
      await tester.pumpWidget(_app(
        HorizontalCalendar<Object?>.controlled(
          focusedDate: DateTime(2026, 8, 3),
          selection: CalendarSelection.single(null),
          onFocusedDateChanged: focused.add,
          onSelectionChanged: (_, __) {},
          bounds: CalendarDateRange(DateTime(2026, 8, 3), DateTime(2026, 8, 9)),
          appearance: CalendarAppearance(motion: CalendarMotion.fluid()),
        ),
      ));

      await tester.drag(
        find.byType(HorizontalCalendar<Object?>),
        const Offset(240, 0),
      );
      await tester.pumpAndSettle();

      expect(focused, isEmpty);
    });

    testWidgets('a tap still selects while gesture following is enabled',
        (tester) async {
      DateTime? selected;
      await tester.pumpWidget(_app(
        HorizontalCalendar(
          selectedDate: DateTime(2026, 8, 3),
          onDateSelected: (date) => selected = date,
          appearance: CalendarAppearance(motion: CalendarMotion.spring()),
        ),
      ));

      await tester.tap(find.byKey(const ValueKey('calendar-day-2026-08-05')));
      await tester.pumpAndSettle();

      expect(selected, DateTime(2026, 8, 5));
    });
  });

  group('FoldableCalendar continuous fold', () {
    testWidgets('mounts both surfaces while a drag is in flight',
        (tester) async {
      await tester.pumpWidget(_app(FoldableCalendar<Object?>(
        focusedDate: DateTime(2026, 8, 12),
        selection: CalendarSelection.single(null),
        onFoldStateChanged: (_) {},
        onFocusedDateChanged: (_) {},
        onSelectionChanged: (_, __) {},
        appearance: CalendarAppearance(motion: CalendarMotion.fluid()),
      )));

      expect(find.byType(MonthCalendar<Object?>), findsNothing);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(FoldableCalendar<Object?>)),
      );
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();

      expect(
        find.byWidgetPredicate((widget) => widget is HorizontalCalendar),
        findsOneWidget,
      );
      expect(find.byType(MonthCalendar<Object?>), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('settles back to one surface when the drag is abandoned',
        (tester) async {
      final states = <CalendarFoldState>[];
      await tester.pumpWidget(_app(FoldableCalendar<Object?>(
        focusedDate: DateTime(2026, 8, 12),
        selection: CalendarSelection.single(null),
        onFoldStateChanged: states.add,
        onFocusedDateChanged: (_) {},
        onSelectionChanged: (_, __) {},
        dragThreshold: 120,
        appearance: CalendarAppearance(motion: CalendarMotion.fluid()),
      )));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(FoldableCalendar<Object?>)),
      );
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(states, isEmpty);
      expect(find.byType(MonthCalendar<Object?>), findsNothing);
    });
  });

  group('HorizontalCalendar strip layout', () {
    testWidgets('a week that fits is laid out edge to edge', (tester) async {
      await tester.pumpWidget(_app(
        SizedBox(
          width: 400,
          child: HorizontalCalendar<Object?>.controlled(
            focusedDate: DateTime(2026, 8, 12),
            selection: CalendarSelection.single(null),
            onFocusedDateChanged: (_) {},
            onSelectionChanged: (_, __) {},
          ),
        ),
      ));

      expect(find.byType(ListView), findsNothing);
      final first = tester.getRect(
        find.byKey(const ValueKey('calendar-day-2026-08-10')),
      );
      final last = tester.getRect(
        find.byKey(const ValueKey('calendar-day-2026-08-16')),
      );
      expect(last.right, greaterThan(first.right));
      expect(last.right, lessThanOrEqualTo(400));
    });

    testWidgets('a surfaceless calendar drops its own card and padding',
        (tester) async {
      await tester.pumpWidget(_app(
        SizedBox(
          width: 360,
          child: HorizontalCalendar<Object?>.controlled(
            focusedDate: DateTime(2026, 8, 12),
            selection: CalendarSelection.single(null),
            onFocusedDateChanged: (_) {},
            onSelectionChanged: (_, __) {},
            appearance: const CalendarAppearance(
              showHeader: false,
              showSurface: false,
            ),
          ),
        ),
      ));

      final first = tester.getRect(
        find.byKey(const ValueKey('calendar-day-2026-08-10')),
      );
      // Without the surface the leading date starts at the container edge.
      expect(first.left, lessThan(2));
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('a week that cannot fit still scrolls', (tester) async {
      await tester.pumpWidget(_app(
        SizedBox(
          width: 240,
          child: HorizontalCalendar<Object?>.controlled(
            focusedDate: DateTime(2026, 8, 12),
            selection: CalendarSelection.single(null),
            onFocusedDateChanged: (_) {},
            onSelectionChanged: (_, __) {},
          ),
        ),
      ));

      expect(find.byType(ListView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('CalendarCupertinoDatePicker configuration', () {
    testWidgets('weekday labels outside date mode degrade instead of throwing',
        (tester) async {
      await tester.pumpWidget(_app(
        CalendarCupertinoDatePicker(
          value: DateTime(2026, 8, 12, 18, 30),
          onChanged: (_) {},
          configuration: const CalendarCupertinoPickerConfiguration(
            mode: CalendarCupertinoPickerMode.dateAndTime,
            showDayOfWeek: true,
          ),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('CalendarAgenda state transitions', () {
    testWidgets('empty and populated agendas render through one switcher',
        (tester) async {
      await tester.pumpWidget(_app(SizedBox(
        height: 400,
        child: CalendarAgenda<Object?>(
          interval: CalendarVisibleInterval(
            DateTime(2026, 8, 3),
            DateTime(2026, 8, 10),
          ),
        ),
      )));
      await tester.pumpAndSettle();

      expect(find.text('No events'), findsOneWidget);
      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });
  });
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));
