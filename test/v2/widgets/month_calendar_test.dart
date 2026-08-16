import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('single constructor reports one easy normalized selection',
      (tester) async {
    DateTime? selected;
    await tester.pumpWidget(_app(MonthCalendar<Object?>.single(
      month: DateTime(2026, 8),
      selectedDate: DateTime(2026, 8, 3),
      onDateSelected: (date) => selected = date,
    )));

    await tester.tap(find.byKey(const ValueKey('month-day-2026-08-05')));
    expect(selected, DateTime(2026, 8, 5));
  });

  testWidgets('uses the exact natural row count for four and six-row months',
      (tester) async {
    await tester.pumpWidget(_app(MonthCalendar<Object?>(
      month: DateTime(2026, 2),
      focusedDate: DateTime(2026, 2),
      selection: CalendarSelection.single(null),
      behavior: const CalendarBehavior(firstDayOfWeek: DateTime.sunday),
      onFocusedDateChanged: (_) {},
      onSelectionChanged: (_, __) {},
    )));
    expect(_dayIdentifiers(tester), hasLength(28));

    await tester.pumpWidget(_app(_month(DateTime(2026, 8))));
    expect(_dayIdentifiers(tester), hasLength(42));
    expect(tester.takeException(), isNull);
  });

  testWidgets('hidden outside-month dates keep grid geometry but not controls',
      (tester) async {
    await tester.pumpWidget(_app(_month(
      DateTime(2026, 4),
      outside: OutsideMonthVisibility.hidden,
    )));

    expect(find.byType(CalendarGridPlaceholder), findsNWidgets(5));
    expect(_dayIdentifiers(tester), hasLength(30));
  });

  testWidgets('visible-disabled outside dates cannot be selected',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(_app(MonthCalendar<Object?>(
      month: DateTime(2026, 4),
      focusedDate: DateTime(2026, 4, 1),
      selection: CalendarSelection.single(null),
      behavior: const CalendarBehavior(firstDayOfWeek: DateTime.monday),
      outsideMonthVisibility: OutsideMonthVisibility.visibleDisabled,
      onFocusedDateChanged: (_) {},
      onSelectionChanged: (_, __) => calls += 1,
    )));

    await tester.tap(find.byKey(const ValueKey('month-day-2026-03-30')));
    await tester.pump();

    expect(calls, 0);
  });

  testWidgets('does not overflow at compact width and text scale 2',
      (tester) async {
    tester.view.physicalSize = const Size(280, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: _app(_month(DateTime(2026, 8))),
    ));

    expect(tester.takeException(), isNull);
  });

  testWidgets('shares multiple and range transitions with the flagship',
      (tester) async {
    final changes = <CalendarSelection>[];
    await tester.pumpWidget(_app(MonthCalendar<Object?>(
      month: DateTime(2026, 8),
      focusedDate: DateTime(2026, 8, 3),
      selection: CalendarSelection.multiple([
        DateTime(2026, 8, 3),
        DateTime(2026, 8, 5),
      ]),
      onFocusedDateChanged: (_) {},
      onSelectionChanged: (_, next) => changes.add(next),
    )));
    await tester.tap(find.byKey(const ValueKey('month-day-2026-08-05')));
    expect(changes.single.contains(DateTime(2026, 8, 5)), isFalse);

    final positions = <int, CalendarRangePosition>{};
    await tester.pumpWidget(_app(MonthCalendar<Object?>(
      month: DateTime(2026, 8),
      focusedDate: DateTime(2026, 8, 3),
      selection: CalendarSelection.range(
        CalendarDateRange(DateTime(2026, 8, 3), DateTime(2026, 8, 5)),
      ),
      onFocusedDateChanged: (_) {},
      onSelectionChanged: (_, __) {},
      builders: CalendarBuilders<Object?>(
        dayBuilder: (context, state) {
          if (state.date.month == 8) {
            positions[state.date.day] = state.rangePosition;
          }
          return Text('${state.date.day}');
        },
      ),
    )));
    expect(positions[3], CalendarRangePosition.start);
    expect(positions[4], CalendarRangePosition.middle);
    expect(positions[5], CalendarRangePosition.end);
  });

  testWidgets('passes unique date events to custom day builders',
      (tester) async {
    CalendarDayState<String>? fifth;
    await tester.pumpWidget(_app(MonthCalendar<String>(
      month: DateTime(2026, 8),
      focusedDate: DateTime(2026, 8, 3),
      selection: CalendarSelection.single(null),
      onFocusedDateChanged: (_) {},
      onSelectionChanged: (_, __) {},
      events: [
        CalendarEvent(
          id: 'event',
          start: DateTime(2026, 8, 5, 9),
          end: DateTime(2026, 8, 5, 10),
          data: 'payload',
        ),
      ],
      builders: CalendarBuilders<String>(
        dayBuilder: (context, state) {
          if (state.date.month == 8 && state.date.day == 5) fifth = state;
          return Text('${state.date.day}');
        },
      ),
    )));

    expect(fifth!.events.single.data, 'payload');
  });

  testWidgets('loads asynchronous events through the same day builder',
      (tester) async {
    CalendarDayState<String>? fifth;
    await tester.pumpWidget(_app(MonthCalendar<String>(
      month: DateTime(2026, 8),
      focusedDate: DateTime(2026, 8, 3),
      selection: CalendarSelection.single(null),
      onFocusedDateChanged: (_) {},
      onSelectionChanged: (_, __) {},
      eventSource: _MonthSource(),
      builders: CalendarBuilders<String>(
        dayBuilder: (context, state) {
          if (state.date.month == 8 && state.date.day == 5) fifth = state;
          return Text('${state.date.day}');
        },
      ),
    )));
    await tester.pump();

    expect(fifth!.events.single.data, 'async');
  });

  testWidgets('animates chronological month changes with every page motion',
      (tester) async {
    for (final transition in CalendarPageTransition.values) {
      var month = DateTime(2026, 8);
      late StateSetter update;
      await tester.pumpWidget(_app(StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return MonthCalendar<Object?>(
            month: month,
            focusedDate: month,
            selection: CalendarSelection.single(month),
            onFocusedDateChanged: (_) {},
            onSelectionChanged: (_, __) {},
            appearance: CalendarAppearance(
              showHeader: false,
              motion: CalendarMotion(
                pageTransition: transition,
                duration: const Duration(milliseconds: 240),
              ),
            ),
          );
        },
      )));
      await tester.pumpAndSettle();

      update(() => month = DateTime(2026, 9));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.takeException(), isNull, reason: transition.name);
      expect(
        find.byKey(const ValueKey('month-day-2026-08-01')),
        transition == CalendarPageTransition.none
            ? findsNothing
            : findsOneWidget,
        reason: transition.name,
      );
      expect(
        find.byKey(const ValueKey('month-day-2026-09-15')),
        findsOneWidget,
        reason: transition.name,
      );
      await tester.pumpAndSettle();
    }
  });
}

class _MonthSource implements CalendarEventSource<String> {
  @override
  Future<List<CalendarEvent<String>>> load(
    CalendarVisibleInterval interval,
  ) async {
    return [
      CalendarEvent(
        id: 'async',
        start: DateTime(2026, 8, 5, 9),
        end: DateTime(2026, 8, 5, 10),
        data: 'async',
      ),
    ];
  }
}

MonthCalendar<Object?> _month(
  DateTime month, {
  OutsideMonthVisibility outside = OutsideMonthVisibility.visible,
}) {
  return MonthCalendar<Object?>(
    month: month,
    focusedDate: month,
    selection: CalendarSelection.single(null),
    behavior: const CalendarBehavior(firstDayOfWeek: DateTime.monday),
    outsideMonthVisibility: outside,
    onFocusedDateChanged: (_) {},
    onSelectionChanged: (_, __) {},
  );
}

List<String> _dayIdentifiers(WidgetTester tester) {
  return tester
      .widgetList<Semantics>(find.byType(Semantics))
      .map((widget) => widget.properties.identifier)
      .whereType<String>()
      .where((identifier) => identifier.startsWith('month-day-'))
      .toList();
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));
