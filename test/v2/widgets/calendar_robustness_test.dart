import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('all style and motion families survive compact large text',
      (tester) async {
    tester.view.physicalSize = const Size(280, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final motions = <CalendarMotion?>[
      null,
      CalendarMotion.none(),
      CalendarMotion.subtle(),
      CalendarMotion.fluid(),
      CalendarMotion.spring(),
      CalendarMotion.playful(),
    ];

    for (final style in CalendarStyle.values) {
      for (final motion in motions) {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: MaterialApp(
              home: Scaffold(
                body: HorizontalCalendar(
                  selectedDate: DateTime(2026, 8, 4),
                  onDateSelected: (_) {},
                  appearance: CalendarAppearance(
                    style: style,
                    motion: motion,
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$style / $motion');
      }
    }
  });

  testWidgets('survives 500 deterministic horizontal layout combinations',
      (tester) async {
    final random = Random(20260804);
    const widths = [280.0, 320.0, 375.0, 430.0, 768.0, 1440.0];
    const scales = [1.0, 1.3, 1.6, 2.0];
    final themes = <HorizontalCalendarThemeData Function(Brightness)>[
      (brightness) =>
          HorizontalCalendarThemeData.material3(brightness: brightness),
      (brightness) =>
          HorizontalCalendarThemeData.cupertino(brightness: brightness),
      (brightness) =>
          HorizontalCalendarThemeData.neutral(brightness: brightness),
      (brightness) => HorizontalCalendarThemeData.glass(brightness: brightness),
      (brightness) =>
          HorizontalCalendarThemeData.editorial(brightness: brightness),
      (brightness) => HorizontalCalendarThemeData.bold(brightness: brightness),
    ];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (var iteration = 0; iteration < 500; iteration += 1) {
      final width = widths[random.nextInt(widths.length)];
      final scale = scales[random.nextInt(scales.length)];
      final brightness = random.nextBool() ? Brightness.light : Brightness.dark;
      final focus = DateTime(
        1900 + random.nextInt(201),
        1 + random.nextInt(12),
        1 + random.nextInt(28),
      );
      final visibleCount = 1 + random.nextInt(31);
      final selection = switch (random.nextInt(3)) {
        0 => CalendarSelection.single(focus),
        1 => CalendarSelection.multiple([
            focus,
            DateTime.utc(focus.year, focus.month, focus.day),
          ]),
        _ => CalendarSelection.range(CalendarDateRange(
            focus,
            DateTime(focus.year, focus.month, focus.day + random.nextInt(5)),
          )),
      };
      final events = <CalendarEvent<int>>[
        for (var index = 0; index < random.nextInt(5); index += 1)
          CalendarEvent(
            id: '$iteration-$index',
            title: 'Event $index with a deliberately useful title',
            start: DateTime(
              focus.year,
              focus.month,
              focus.day + index,
              9,
            ),
            end: DateTime(
              focus.year,
              focus.month,
              focus.day + index,
              10,
            ),
            data: index,
          ),
      ];
      tester.view.physicalSize = Size(width, 700);

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 700),
            textScaler: TextScaler.linear(scale),
            boldText: random.nextBool(),
            highContrast: random.nextBool(),
            disableAnimations: random.nextBool(),
          ),
          child: Directionality(
            textDirection:
                random.nextBool() ? TextDirection.ltr : TextDirection.rtl,
            child: Scaffold(
              body: HorizontalCalendar<int>.controlled(
                focusedDate: focus,
                selection: selection,
                onFocusedDateChanged: (_) {},
                onSelectionChanged: (_, __) {},
                behavior: CalendarBehavior(
                  visibleDayCount: visibleCount,
                  firstDayOfWeek: 1 + random.nextInt(7),
                  scrolling: random.nextBool()
                      ? CalendarScrollBehavior.page
                      : CalendarScrollBehavior.free,
                ),
                appearance: CalendarAppearance(
                  density: CalendarDensity
                      .values[random.nextInt(CalendarDensity.values.length)],
                  eventIndicatorStyle: EventIndicatorStyle.values[
                      random.nextInt(EventIndicatorStyle.values.length)],
                  theme: themes[random.nextInt(themes.length)](brightness),
                ),
                events: events,
              ),
            ),
          ),
        ),
      ));

      expect(
        tester.takeException(),
        isNull,
        reason: 'iteration $iteration, width $width, scale $scale',
      );
    }
  });

  testWidgets('foldable month survives compact high-accessibility settings',
      (tester) async {
    tester.view.physicalSize = const Size(280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(280, 900),
          textScaler: TextScaler.linear(2),
          boldText: true,
          highContrast: true,
          disableAnimations: true,
        ),
        child: Scaffold(
          body: FoldableCalendar<Object?>(
            focusedDate: DateTime(2026, 8, 5),
            selection: CalendarSelection.range(
              CalendarDateRange(DateTime(2026, 8, 5), DateTime(2026, 8, 12)),
            ),
            foldState: CalendarFoldState.expanded,
            onFocusedDateChanged: (_) {},
            onSelectionChanged: (_, __) {},
            events: [
              CalendarEvent(
                id: 'event',
                start: DateTime(2026, 8, 5, 9),
                end: DateTime(2026, 8, 5, 10),
              ),
            ],
          ),
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
  });
}
