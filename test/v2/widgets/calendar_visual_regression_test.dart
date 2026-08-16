import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('horizon sky clips every painted layer to its viewport',
      (tester) async {
    await tester.pumpWidget(_app(
      SizedBox(
        width: 360,
        child: CelestialDatePicker(
          value: DateTime(2026, 8, 19),
          onChanged: (_) {},
          style: const CelestialDatePickerStyle(
            skyStyle: CelestialSkyStyle.aurora,
            composition: CelestialComposition.cinematic,
            showClouds: true,
            showConstellations: true,
            showPhaseOrbit: true,
            showDateProgress: true,
          ),
        ),
      ),
    ));

    expect(
      find.byKey(const ValueKey('celestial-sky-viewport')),
      findsOneWidget,
    );
  });

  testWidgets('insight dashboard fits two columns after outer padding',
      (tester) async {
    await tester.pumpWidget(_app(
      SizedBox(
        width: 360,
        child: CalendarInsightsDashboard<void>(
          metrics: _metrics,
          padding: const EdgeInsets.all(12),
          spacing: 10,
          minimumMetricWidth: 132,
        ),
      ),
    ));

    final first = tester.getTopLeft(
      find.byKey(const ValueKey('calendar-insight-one')),
    );
    final second = tester.getTopLeft(
      find.byKey(const ValueKey('calendar-insight-two')),
    );
    expect(second.dy, first.dy);
    expect(second.dx, greaterThan(first.dx));
  });

  testWidgets('ring heatmap keeps labels readable on a dark surface',
      (tester) async {
    await tester.pumpWidget(_app(
      SizedBox(
        width: 120,
        child: CalendarHeatmapStrip(
          startDate: DateTime(2026, 8, 1),
          dayCount: 1,
          values: {DateTime(2026, 8, 1): .85},
          appearance: const CalendarAppearance(style: CalendarStyle.neon),
          style: const CalendarHeatmapStyle(
            design: CalendarHeatmapDesign.ring,
            showPercentage: true,
          ),
        ),
      ),
    ));

    final percentage = tester.widget<Text>(find.text('85%'));
    expect(percentage.style!.color!.computeLuminance(), greaterThan(.4));
  });

  testWidgets('contribution weeks use compact chronological spacing',
      (tester) async {
    await tester.pumpWidget(_app(
      SizedBox(
        width: 360,
        height: 260,
        child: CalendarContributionHeatmap(
          startDate: DateTime(2026, 1, 1),
          dayCount: 14,
          values: {
            DateTime(2026, 1, 1): .4,
            DateTime(2026, 1, 8): .8,
          },
        ),
      ),
    ));

    final first = tester.getCenter(
      find.byKey(
        const ValueKey('calendar-contribution-day-2026-01-01'),
      ),
    );
    final nextWeek = tester.getCenter(
      find.byKey(
        const ValueKey('calendar-contribution-day-2026-01-08'),
      ),
    );
    expect(nextWeek.dx - first.dx, lessThanOrEqualTo(48));
  });

  testWidgets('spotlight carousel caps inherited pill corner radius',
      (tester) async {
    await tester.pumpWidget(_app(
      SizedBox(
        width: 390,
        child: CalendarDateCarousel<void>(
          startDate: DateTime(2026, 8, 3),
          dayCount: 7,
          selectedDate: DateTime(2026, 8, 5),
          onDateSelected: (_) {},
          appearance: const CalendarAppearance(style: CalendarStyle.pill),
          visualStyle: const CalendarCarouselVisualStyle(
            layout: CalendarCarouselLayout.spotlight,
          ),
        ),
      ),
    ));

    final card = find.descendant(
      of: find.byKey(
        const ValueKey('calendar-carousel-day-2026-08-05'),
      ),
      matching: find.byType(AnimatedContainer),
    );
    final decoration =
        tester.widget<AnimatedContainer>(card).decoration! as BoxDecoration;
    final radius = decoration.borderRadius! as BorderRadius;
    expect(radius.topLeft.x, lessThanOrEqualTo(32));
  });

  testWidgets('spotlight carousel centers its controlled selection',
      (tester) async {
    await tester.pumpWidget(_app(
      SizedBox(
        width: 390,
        child: CalendarDateCarousel<void>(
          startDate: DateTime(2026, 8, 1),
          dayCount: 18,
          selectedDate: DateTime(2026, 8, 5),
          onDateSelected: (_) {},
          scrolling: CalendarScrollBehavior.page,
          visualStyle: const CalendarCarouselVisualStyle(
            layout: CalendarCarouselLayout.spotlight,
            spacing: 12,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final viewportCenter = tester.getCenter(find.byType(ListView));
    final selectedCenter = tester.getCenter(
      find.byKey(const ValueKey('calendar-carousel-day-2026-08-05')),
    );
    expect((selectedCenter.dx - viewportCenter.dx).abs(), lessThan(2));
  });
}

final _metrics = <CalendarInsightMetric<void>>[
  for (final id in ['one', 'two', 'three', 'four'])
    CalendarInsightMetric<void>(
      id: id,
      label: 'Metric $id',
      value: '42',
      progress: .5,
    ),
];

Widget _app(Widget child) => MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );
