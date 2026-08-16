import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('single constructor keeps date selection simple', (tester) async {
    DateTime? selected;
    await tester.pumpWidget(_app(FoldableCalendar<Object?>.single(
      focusedDate: DateTime(2026, 8, 3),
      selectedDate: DateTime(2026, 8, 3),
      onDateSelected: (date) => selected = date,
    )));

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-08-05')));
    expect(selected, DateTime(2026, 8, 5));
  });

  testWidgets('shows one week collapsed and the complete month expanded',
      (tester) async {
    final controller = HorizontalCalendarController(
      focusedDate: DateTime(2026, 8, 12),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(_app(FoldableCalendar(
      controller: controller,
      focusedDate: DateTime(2026, 8, 12),
      selection: CalendarSelection.single(DateTime(2026, 8, 12)),
      onFocusedDateChanged: (_) {},
      onSelectionChanged: (_, __) {},
    )));
    expect(
      find.byWidgetPredicate((widget) => widget is HorizontalCalendar),
      findsOneWidget,
    );
    expect(find.byType(MonthCalendar), findsNothing);

    await controller.setFoldState(CalendarFoldState.expanded, animate: false);
    await tester.pump();

    expect(
      find.byWidgetPredicate((widget) => widget is HorizontalCalendar),
      findsNothing,
    );
    expect(find.byType(MonthCalendar), findsOneWidget);
    expect(
      tester.widget<MonthCalendar>(find.byType(MonthCalendar)).selection,
      CalendarSelection.single(DateTime(2026, 8, 12)),
    );
  });

  testWidgets('header action reports a controlled fold proposal once',
      (tester) async {
    final states = <CalendarFoldState>[];
    await tester.pumpWidget(_app(FoldableCalendar(
      focusedDate: DateTime(2026, 8, 12),
      selection: CalendarSelection.single(null),
      foldState: CalendarFoldState.collapsed,
      onFoldStateChanged: states.add,
      onFocusedDateChanged: (_) {},
      onSelectionChanged: (_, __) {},
    )));

    await tester.tap(find.byKey(const ValueKey('calendar-fold-toggle')));
    await tester.pump();

    expect(states, [CalendarFoldState.expanded]);
  });

  testWidgets('vertical drag proposes expansion and collapse', (tester) async {
    final states = <CalendarFoldState>[];
    var state = CalendarFoldState.collapsed;
    late StateSetter update;
    await tester.pumpWidget(_app(StatefulBuilder(
      builder: (context, setState) {
        update = setState;
        return FoldableCalendar<Object?>(
          focusedDate: DateTime(2026, 8, 12),
          selection: CalendarSelection.single(null),
          foldState: state,
          onFoldStateChanged: (next) {
            states.add(next);
            update(() => state = next);
          },
          onFocusedDateChanged: (_) {},
          onSelectionChanged: (_, __) {},
        );
      },
    )));

    await tester.drag(
        find.byType(FoldableCalendar<Object?>), const Offset(0, 90));
    await tester.pumpAndSettle();
    await tester.drag(
        find.byType(FoldableCalendar<Object?>), const Offset(0, -90));
    await tester.pumpAndSettle();

    expect(states, [CalendarFoldState.expanded, CalendarFoldState.collapsed]);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));
