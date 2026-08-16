import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('heatmap clamps invalid values and reports the tapped civil date',
      (tester) async {
    DateTime? tapped;
    await tester.pumpWidget(_app(
      CalendarHeatmapStrip(
        startDate: DateTime(2026, 8, 3),
        dayCount: 5,
        values: {
          DateTime(2026, 8, 3): -2,
          DateTime(2026, 8, 4): .42,
          DateTime(2026, 8, 5): 9,
          DateTime(2026, 8, 6): double.nan,
        },
        onDateTap: (date) => tapped = date,
      ),
    ));

    expect(_semanticsEndingWith(tester, ', 0% intensity'), hasLength(3));
    expect(_semanticsEndingWith(tester, ', 42% intensity'), hasLength(1));
    expect(_semanticsEndingWith(tester, ', 100% intensity'), hasLength(1));

    await tester.tap(
      find.byKey(const ValueKey('calendar-heatmap-day-2026-08-05')),
    );
    expect(tapped, DateTime(2026, 8, 5));
  });

  testWidgets('streak exposes completed, missed, today, and future states',
      (tester) async {
    DateTime? tapped;
    await tester.pumpWidget(_app(
      CalendarStreakStrip(
        startDate: DateTime(2026, 8, 3),
        dayCount: 5,
        today: DateTime(2026, 8, 5),
        selectedDate: DateTime(2026, 8, 4),
        completedDates: {DateTime(2026, 8, 3)},
        onDateTap: (date) => tapped = date,
      ),
    ));

    expect(find.bySemanticsLabel(RegExp('completed')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('missed')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('today')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('future')), findsNWidgets(2));

    await tester.tap(
      find.byKey(const ValueKey('calendar-streak-day-2026-08-03')),
    );
    expect(tapped, DateTime(2026, 8, 3));
  });

  testWidgets('insight strips remain overflow-free at 280px and text scale 2',
      (tester) async {
    tester.view.physicalSize = const Size(280, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _app(Column(
          children: [
            CalendarHeatmapStrip(
              startDate: DateTime(2026, 1, 1),
              dayCount: 366,
            ),
            CalendarStreakStrip(
              startDate: DateTime(2026, 1, 1),
              dayCount: 31,
            ),
          ],
        )),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

List<Semantics> _semanticsEndingWith(WidgetTester tester, String suffix) {
  return tester
      .widgetList<Semantics>(find.byType(Semantics))
      .where((widget) => widget.properties.label?.endsWith(suffix) ?? false)
      .toList();
}
