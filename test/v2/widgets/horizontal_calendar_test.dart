import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('renders seven contiguous unique civil dates', (tester) async {
    await tester.pumpWidget(_app(
      HorizontalCalendar<Object?>.controlled(
        focusedDate: DateTime(2026, 8, 5),
        selection: CalendarSelection.single(DateTime(2026, 8, 5)),
        onFocusedDateChanged: (_) {},
        onSelectionChanged: (_, __) {},
      ),
    ));

    final keys = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .map((widget) => widget.properties.identifier)
        .whereType<String>()
        .where((identifier) => identifier.startsWith('calendar-day-'))
        .toList();

    expect(keys, hasLength(7));
    expect(keys.toSet(), hasLength(7));
    expect(keys.first, 'calendar-day-2026-08-03');
    expect(keys.last, 'calendar-day-2026-08-09');
  });

  testWidgets('proposes one normalized selection per accepted tap',
      (tester) async {
    final changes = <(CalendarSelection, CalendarSelection)>[];
    await tester.pumpWidget(_app(
      HorizontalCalendar<Object?>.controlled(
        focusedDate: DateTime(2026, 8, 3),
        selection: CalendarSelection.single(DateTime(2026, 8, 3)),
        onFocusedDateChanged: (_) {},
        onSelectionChanged: (previous, next) {
          changes.add((previous, next));
        },
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-08-05')));
    await tester.pump();

    expect(changes, hasLength(1));
    expect(changes.single.$1.selectedDate, DateTime(2026, 8, 3));
    expect(changes.single.$2.selectedDate, DateTime(2026, 8, 5));
  });

  testWidgets('does not select disabled dates', (tester) async {
    var calls = 0;
    await tester.pumpWidget(_app(
      HorizontalCalendar<Object?>.controlled(
        focusedDate: DateTime(2026, 8, 3),
        selection: CalendarSelection.single(null),
        onFocusedDateChanged: (_) {},
        onSelectionChanged: (_, __) => calls += 1,
        behavior: CalendarBehavior(
          selectableDayPredicate: (date) => date.day != 5,
        ),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-08-05')));
    await tester.pump();

    expect(calls, 0);
  });

  testWidgets('controller navigation proposes the resolved focused date once',
      (tester) async {
    final controller = HorizontalCalendarController(
      focusedDate: DateTime(2026, 8, 3),
    );
    addTearDown(controller.dispose);
    final focusedDates = <DateTime>[];
    await tester.pumpWidget(_app(
      HorizontalCalendar<Object?>.controlled(
        controller: controller,
        focusedDate: DateTime(2026, 8, 3),
        selection: CalendarSelection.single(null),
        onFocusedDateChanged: focusedDates.add,
        onSelectionChanged: (_, __) {},
      ),
    ));

    await controller.next(animate: false);
    await tester.pump();

    expect(focusedDates, [DateTime(2026, 8, 10)]);
  });

  testWidgets('has no overflow at 280 pixels and text scale 2', (tester) async {
    tester.view.physicalSize = const Size(280, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _app(
          HorizontalCalendar<Object?>.controlled(
            focusedDate: DateTime(2026, 8, 3),
            selection: CalendarSelection.single(null),
            onFocusedDateChanged: (_) {},
            onSelectionChanged: (_, __) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('page swipe proposes the next chronological page',
      (tester) async {
    final focused = <DateTime>[];
    await tester.pumpWidget(_app(
      HorizontalCalendar<Object?>.controlled(
        focusedDate: DateTime(2026, 8, 3),
        selection: CalendarSelection.single(null),
        onFocusedDateChanged: focused.add,
        onSelectionChanged: (_, __) {},
      ),
    ));

    await tester.drag(
      find.byType(HorizontalCalendar<Object?>),
      const Offset(-180, 0),
    );
    await tester.pump();

    expect(focused, [DateTime(2026, 8, 10)]);
  });

  testWidgets('RTL reverses the visual gesture for chronological next',
      (tester) async {
    final focused = <DateTime>[];
    await tester.pumpWidget(_app(
      Directionality(
        textDirection: TextDirection.rtl,
        child: HorizontalCalendar<Object?>.controlled(
          focusedDate: DateTime(2026, 8, 3),
          selection: CalendarSelection.single(null),
          onFocusedDateChanged: focused.add,
          onSelectionChanged: (_, __) {},
        ),
      ),
    ));

    await tester.drag(
      find.byType(HorizontalCalendar<Object?>),
      const Offset(180, 0),
    );
    await tester.pump();

    expect(focused, [DateTime(2026, 8, 10)]);
  });

  testWidgets('keyboard arrows move focus by one civil day', (tester) async {
    final focused = <DateTime>[];
    await tester.pumpWidget(_app(
      HorizontalCalendar<Object?>.controlled(
        focusedDate: DateTime(2026, 8, 3),
        selection: CalendarSelection.single(null),
        onFocusedDateChanged: focused.add,
        onSelectionChanged: (_, __) {},
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-08-03')));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(focused, [DateTime(2026, 8, 4)]);
  });

  testWidgets('page keyboard shortcuts move by the visible day count',
      (tester) async {
    final focused = <DateTime>[];
    await tester.pumpWidget(_app(
      HorizontalCalendar<Object?>.controlled(
        focusedDate: DateTime(2026, 8, 3),
        selection: CalendarSelection.single(null),
        onFocusedDateChanged: focused.add,
        onSelectionChanged: (_, __) {},
        behavior: const CalendarBehavior(visibleDayCount: 5),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-08-03')));
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();

    expect(focused, [DateTime(2026, 8, 8)]);
  });

  testWidgets('range builder state identifies both boundaries and middle',
      (tester) async {
    final positions = <int, CalendarRangePosition>{};
    await tester.pumpWidget(_app(
      HorizontalCalendar<Object?>.controlled(
        focusedDate: DateTime(2026, 8, 3),
        selection: CalendarSelection.range(
          CalendarDateRange(DateTime(2026, 8, 3), DateTime(2026, 8, 5)),
        ),
        onFocusedDateChanged: (_) {},
        onSelectionChanged: (_, __) {},
        builders: CalendarBuilders<Object?>(
          dayBuilder: (context, state) {
            positions[state.date.day] = state.rangePosition;
            return Text('${state.date.day}');
          },
        ),
      ),
    ));

    expect(positions[3], CalendarRangePosition.start);
    expect(positions[4], CalendarRangePosition.middle);
    expect(positions[5], CalendarRangePosition.end);
  });

  testWidgets('external controlled focus synchronizes imperative navigation',
      (tester) async {
    final controller = HorizontalCalendarController(
      focusedDate: DateTime(2026, 8, 3),
    );
    final focus = ValueNotifier(DateTime(2026, 8, 3));
    final proposals = <DateTime>[];
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);

    await tester.pumpWidget(_app(ValueListenableBuilder<DateTime>(
      valueListenable: focus,
      builder: (context, value, _) => HorizontalCalendar<Object?>.controlled(
        controller: controller,
        focusedDate: value,
        selection: CalendarSelection.single(null),
        onFocusedDateChanged: proposals.add,
        onSelectionChanged: (_, __) {},
      ),
    )));
    focus.value = DateTime(2026, 8, 17);
    await tester.pump();
    expect(proposals, isEmpty);

    await controller.next(animate: false);
    await tester.pump();
    expect(proposals, [DateTime(2026, 8, 24)]);
  });

  testWidgets('asynchronous event sources populate the same day state',
      (tester) async {
    final states = <CalendarDayState<String>>[];
    await tester.pumpWidget(_app(
      HorizontalCalendar<String>.controlled(
        focusedDate: DateTime(2026, 8, 3),
        selection: CalendarSelection.single(null),
        onFocusedDateChanged: (_) {},
        onSelectionChanged: (_, __) {},
        eventSource: _ImmediateSource(),
        builders: CalendarBuilders<String>(
          dayBuilder: (context, state) {
            states.add(state);
            return Text('${state.date.day}');
          },
        ),
      ),
    ));
    await tester.pump();

    final fifth = states.lastWhere((state) => state.date.day == 5);
    expect(fifth.events.single.data, 'loaded');
  });
}

class _ImmediateSource implements CalendarEventSource<String> {
  @override
  Future<List<CalendarEvent<String>>> load(
    CalendarVisibleInterval interval,
  ) async {
    return [
      CalendarEvent(
        id: 'loaded',
        start: DateTime(2026, 8, 5, 9),
        end: DateTime(2026, 8, 5, 10),
        data: 'loaded',
      ),
    ];
  }
}

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}
