import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('CalendarDayCell is independently usable with a valid target',
      (tester) async {
    final theme = HorizontalCalendarThemeData.material3();
    var taps = 0;
    await tester.pumpWidget(_app(CalendarDayCell<void>(
      state: CalendarDayState<void>(
        date: DateTime(2026, 8, 4),
        isToday: false,
        isSelected: true,
        isFocused: true,
        isDisabled: false,
        isOutsideInterval: false,
        rangePosition: CalendarRangePosition.none,
        events: const [],
        semanticLabel: 'Tuesday, August 4, 2026, selected',
      ),
      theme: theme,
      onTap: () => taps += 1,
    )));

    expect(tester.getSize(find.byType(CalendarDayCell<void>)).width,
        greaterThanOrEqualTo(48));
    await tester.tap(find.byType(CalendarDayCell<void>));
    expect(taps, 1);
  });

  testWidgets('CalendarEventMarker renders every built-in indicator style',
      (tester) async {
    for (final style in EventIndicatorStyle.values) {
      await tester.pumpWidget(_app(CalendarEventMarker(
        count: 3,
        style: style,
        color: Colors.indigo,
      )));
      expect(find.byType(CalendarEventMarker), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('CalendarEventTile returns the original typed event',
      (tester) async {
    final event = CalendarEvent<String>(
      id: 'review',
      start: DateTime(2026, 8, 4, 10),
      end: DateTime(2026, 8, 4, 11),
      title: 'Design review',
      data: 'original',
    );
    CalendarEvent<String>? tapped;
    await tester.pumpWidget(_app(CalendarEventTile<String>(
      event: event,
      theme: HorizontalCalendarThemeData.material3(),
      onTap: (value) => tapped = value,
    )));

    await tester.tap(find.byType(CalendarEventTile<String>));
    expect(tapped, same(event));
    expect(find.text('Design review'), findsOneWidget);
  });

  testWidgets('CalendarHeader exposes previous, next, and today actions',
      (tester) async {
    final actions = <String>[];
    final interval = CalendarVisibleInterval(
      DateTime(2026, 8, 3),
      DateTime(2026, 8, 10),
    );
    await tester.pumpWidget(_app(CalendarHeader(
      state: CalendarHeaderState(
        focusedDate: DateTime(2026, 8, 4),
        visibleInterval: interval,
        canNavigateBackward: true,
        canNavigateForward: true,
        onPrevious: () => actions.add('previous'),
        onNext: () => actions.add('next'),
        onToday: () => actions.add('today'),
      ),
      theme: HorizontalCalendarThemeData.material3(),
    )));

    await tester.tap(find.byKey(const ValueKey('calendar-header-previous')));
    await tester.tap(find.byKey(const ValueKey('calendar-header-today')));
    await tester.tap(find.byKey(const ValueKey('calendar-header-next')));
    expect(actions, ['previous', 'today', 'next']);
  });

  testWidgets('CalendarFoldHandle toggles from its supplied state',
      (tester) async {
    CalendarFoldState? proposed;
    await tester.pumpWidget(_app(CalendarFoldHandle(
      state: CalendarFoldState.collapsed,
      onChanged: (state) => proposed = state,
      theme: HorizontalCalendarThemeData.cupertino(),
    )));

    await tester.tap(find.byType(CalendarFoldHandle));
    expect(proposed, CalendarFoldState.expanded);
  });

  testWidgets('CalendarNowIndicator is independently usable', (tester) async {
    await tester.pumpWidget(_app(const CalendarNowIndicator(label: '10:30')));
    expect(find.text('10:30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));
