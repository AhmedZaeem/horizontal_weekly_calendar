import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('every refined carousel layout survives compact large text',
      (tester) async {
    tester.view.physicalSize = const Size(280, 620);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final layout in CalendarCarouselLayout.values) {
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _material(CalendarDateCarousel<String>(
          startDate: DateTime(2026, 8, 1),
          dayCount: 12,
          selectedDate: DateTime(2026, 8, 4),
          onDateSelected: (_) {},
          visualStyle: CalendarCarouselVisualStyle(layout: layout),
          items: [
            CalendarCarouselItem(
              date: DateTime(2026, 8, 4),
              title: 'Long production milestone',
              subtitle: 'Three appointments and a design review',
              badge: 'LIMITED AVAILABILITY',
              data: 'typed',
            ),
          ],
          events: [
            for (var index = 0; index < 3; index += 1)
              CalendarEvent(
                id: 'event-$index',
                start: DateTime(2026, 8, 4, 9 + index),
                end: DateTime(2026, 8, 4, 10 + index),
              ),
          ],
        )),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: layout.name);
      expect(
        find.byKey(const ValueKey('calendar-carousel-day-2026-08-04')),
        findsOneWidget,
      );
    }
  });

  testWidgets('horizon exposes continuous retargetable motion state',
      (tester) async {
    var date = DateTime(2026, 8, 4);
    late StateSetter update;
    final samples = <double>[];
    await tester.pumpWidget(_material(StatefulBuilder(
      builder: (context, setState) {
        update = setState;
        return CelestialDatePicker(
          value: date,
          onChanged: (_) {},
          celestialMotion: const CelestialMotion(
            duration: Duration(milliseconds: 600),
            trailLength: .7,
            starTwinkle: .8,
          ),
          style: const CelestialDatePickerStyle(
            skyStyle: CelestialSkyStyle.aurora,
            showClouds: true,
            showConstellations: true,
            showPhaseOrbit: true,
            showDateProgress: true,
          ),
          skyBuilder: (context, state) {
            samples.add(state.transitionProgress);
            return SizedBox(
              key: const ValueKey('custom-continuous-sky'),
              height: 190,
            );
          },
        );
      },
    )));

    update(() => date = DateTime(2026, 8, 20));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    final firstProgress = samples.last;
    update(() => date = DateTime(2026, 9, 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(firstProgress, inExclusiveRange(0, 1));
    expect(samples.last, inExclusiveRange(0, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('heatmap designs and contribution grid remain interactive',
      (tester) async {
    for (final design in CalendarHeatmapDesign.values) {
      DateTime? tapped;
      await tester.pumpWidget(_material(CalendarHeatmapStrip(
        startDate: DateTime(2026, 8, 1),
        dayCount: 8,
        selectedDate: DateTime(2026, 8, 4),
        values: {DateTime(2026, 8, 4): .8},
        onDateTap: (date) => tapped = date,
        style: CalendarHeatmapStyle(
          design: design,
          animate: true,
          showPercentage: true,
        ),
      )));
      await tester.tap(
        find.byKey(const ValueKey('calendar-heatmap-day-2026-08-04')),
      );
      expect(tapped, DateTime(2026, 8, 4), reason: design.name);
      expect(tester.takeException(), isNull, reason: design.name);
    }

    await tester.pumpWidget(_material(SizedBox(
      height: 280,
      child: CalendarContributionHeatmap(
        startDate: DateTime(2026, 1, 1),
        dayCount: 366,
        values: {DateTime(2026, 8, 4): .8},
      ),
    )));
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fold button and new date widgets preserve typed callbacks',
      (tester) async {
    CalendarFoldState? fold;
    DateTime? weekDate;
    String? payload;
    await tester.pumpWidget(_material(ListView(
      children: [
        FoldableCalendar<Object?>(
          focusedDate: DateTime(2026, 8, 4),
          selection: CalendarSelection.single(DateTime(2026, 8, 4)),
          foldControl: CalendarFoldControl.button,
          onFoldStateChanged: (value) => fold = value,
          onFocusedDateChanged: (_) {},
          onSelectionChanged: (_, __) {},
        ),
        CalendarCountdownCard<String>(
          targetDate: DateTime(2026, 8, 10),
          referenceDate: DateTime(2026, 8, 4),
          data: 'countdown',
          onTap: (state) => payload = state.data,
        ),
        CalendarWeekProgress(
          startDate: DateTime(2026, 8, 3),
          currentDate: DateTime(2026, 8, 5),
          selectedDate: DateTime(2026, 8, 4),
          onDateTap: (date) => weekDate = date,
        ),
        CalendarDateRangeSummary<String>(
          range: CalendarDateRange(
            DateTime(2026, 8, 3),
            DateTime(2026, 8, 9),
          ),
          referenceDate: DateTime(2026, 8, 5),
          data: 'range',
          onTap: (state) => payload = state.data,
        ),
      ],
    )));

    await tester.tap(find.byKey(const ValueKey('calendar-fold-button')));
    await tester.tap(find.byKey(const ValueKey('calendar-countdown-card')));
    await tester.tap(
      find.byKey(const ValueKey('calendar-week-progress-2026-08-04')),
    );
    expect(fold, CalendarFoldState.expanded);
    expect(payload, 'countdown');
    expect(weekDate, DateTime(2026, 8, 4));

    await tester.tap(find.byKey(const ValueKey('calendar-range-summary')));
    expect(payload, 'range');
    expect(tester.takeException(), isNull);
  });

  testWidgets('additional date widgets work without a Material app',
      (tester) async {
    await tester.pumpWidget(CupertinoApp(
      home: CupertinoPageScaffold(
        child: ListView(
          children: [
            CalendarCountdownCard<Object?>(
              targetDate: DateTime(2026, 8, 10),
              referenceDate: DateTime(2026, 8, 4),
            ),
            CalendarWeekProgress(
              startDate: DateTime(2026, 8, 3),
              currentDate: DateTime(2026, 8, 5),
            ),
            CalendarDateRangeSummary<Object?>(
              range: CalendarDateRange(
                DateTime(2026, 8, 3),
                DateTime(2026, 8, 3),
              ),
              referenceDate: DateTime(2026, 8, 3),
            ),
          ],
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });
}

Widget _material(Widget child) => MaterialApp(home: Scaffold(body: child));
