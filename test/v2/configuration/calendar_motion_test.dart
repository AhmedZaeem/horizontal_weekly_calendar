import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  group('CalendarMotion', () {
    test('ships five complete and distinct motion presets', () {
      final presets = [
        CalendarMotion.none(),
        CalendarMotion.subtle(),
        CalendarMotion.fluid(),
        CalendarMotion.spring(),
        CalendarMotion.playful(),
      ];

      expect(presets.first.duration, Duration.zero);
      expect(
        presets.skip(1).every((motion) => motion.duration > Duration.zero),
        isTrue,
      );
      expect(
        presets.map((motion) => motion.selectionTransition).toSet().length,
        greaterThanOrEqualTo(4),
      );
      expect(
        presets.map((motion) => motion.pageTransition).toSet().length,
        greaterThanOrEqualTo(3),
      );
    });

    test('rejects unsafe duration, stagger, and hover values', () {
      expect(
        () => CalendarMotion(
          duration: const Duration(milliseconds: -1),
        ),
        throwsAssertionError,
      );
      expect(
        () => CalendarMotion(stagger: const Duration(milliseconds: -1)),
        throwsAssertionError,
      );
      expect(() => CalendarMotion(hoverScale: .9), throwsAssertionError);
    });

    test('appearance retains motion independently from theme and density', () {
      final motion = CalendarMotion.spring();
      final appearance = CalendarAppearance(
        density: CalendarDensity.spacious,
        motion: motion,
      );

      expect(appearance.motion, same(motion));
      expect(appearance.copyWith(density: CalendarDensity.compact).motion,
          same(motion));
    });

    test('custom page geometry validates and copies independently', () {
      final motion = CalendarMotion(
        pageTransition: CalendarPageTransition.flip,
        pageOffset: .24,
        pageScale: .91,
        pagePerspective: .002,
      );
      final copy = motion.copyWith(
        pageTransition: CalendarPageTransition.sharedAxis,
        pageOffset: .12,
      );

      expect(motion.pageTransition, CalendarPageTransition.flip);
      expect(motion.pageScale, .91);
      expect(copy.pageTransition, CalendarPageTransition.sharedAxis);
      expect(copy.pageOffset, .12);
      expect(copy.pagePerspective, .002);
    });
  });

  test('showcase motion presets and page treatments are complete', () {
    final presets = [
      CalendarMotion.snappy(),
      CalendarMotion.gentle(),
      CalendarMotion.cinematic(),
      CalendarMotion.premium(),
    ];

    expect(presets.every((motion) => motion.duration > Duration.zero), isTrue);
    expect(
      CalendarPageTransition.values,
      containsAll([
        CalendarPageTransition.parallax,
        CalendarPageTransition.coverFlow,
        CalendarPageTransition.verticalReveal,
        CalendarPageTransition.blurThrough,
      ]),
    );
    final motion = CalendarMotion(
      pageRotation: .12,
      pageBlur: 8,
      outgoingPageScale: .92,
    );
    expect(motion.copyWith(pageBlur: 4).pageBlur, 4);
    expect(motion.pageRotation, .12);
    expect(motion.outgoingPageScale, .92);
  });

  testWidgets(
      'motion remains layout-safe and settles immediately when disabled',
      (tester) async {
    var selected = DateTime(2026, 8, 4);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StatefulBuilder(
            builder: (context, setState) => HorizontalCalendar(
              selectedDate: selected,
              onDateSelected: (date) => setState(() => selected = date),
              appearance: CalendarAppearance(
                motion: CalendarMotion.playful(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-08-05')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(selected, DateTime(2026, 8, 5));
    final context = tester.element(
      find.byWidgetPredicate((widget) => widget is HorizontalCalendar),
    );
    expect(CalendarMotion.playful().effectiveDuration(context), Duration.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('playful page motion tolerates overshoot curves', (tester) async {
    final controller = HorizontalCalendarController(
      focusedDate: DateTime(2026, 8, 3),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HorizontalCalendar(
            controller: controller,
            selectedDate: DateTime(2026, 8, 3),
            onDateSelected: (_) {},
            appearance: CalendarAppearance(
              motion: CalendarMotion.playful(),
            ),
          ),
        ),
      ),
    );

    await controller.next();
    await tester.pump(const Duration(milliseconds: 140));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('header buttons retain both week pages during every transition',
      (tester) async {
    for (final transition in CalendarPageTransition.values
        .where((value) => value != CalendarPageTransition.none)) {
      final controller = HorizontalCalendarController(
        focusedDate: DateTime(2026, 8, 3),
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HorizontalCalendar<Object?>(
            key: ValueKey(transition),
            controller: controller,
            selectedDate: DateTime(2026, 8, 3),
            onDateSelected: (_) {},
            appearance: CalendarAppearance(
              motion: CalendarMotion(
                pageTransition: transition,
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.byKey(const ValueKey('calendar-header-next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const ValueKey('calendar-day-2026-08-03')),
        findsOneWidget,
        reason: transition.name,
      );
      expect(
        find.byKey(const ValueKey('calendar-day-2026-08-10')),
        findsOneWidget,
        reason: transition.name,
      );
      expect(tester.takeException(), isNull, reason: transition.name);
      await tester.pumpAndSettle();
      controller.dispose();
    }
  });
}
