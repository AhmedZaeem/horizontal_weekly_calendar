import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('day timeline lays out overlaps and returns original events',
      (tester) async {
    final tapped = <CalendarEvent<String>>[];
    final events = [
      _event('first', 9, 11),
      _event('second', 10, 12),
      _event('third', 12, 13),
    ];
    await tester.pumpWidget(_app(DayTimeline<String>(
      date: DateTime(2026, 8, 4),
      events: events,
      configuration: const CalendarTimelineConfiguration(
        startHour: 8,
        endHour: 14,
        viewportHeight: 420,
      ),
      onEventTap: tapped.add,
      now: DateTime(2026, 8, 4, 10, 30),
    )));

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.byType(CalendarNowIndicator), findsOneWidget);
    await tester.tap(find.text('second'));
    expect(tapped.single.id, 'second');
    expect(tester.takeException(), isNull);
  });

  testWidgets('all-day events use their dedicated band', (tester) async {
    await tester.pumpWidget(_app(DayTimeline<Object?>(
      date: DateTime(2026, 8, 4),
      events: [
        CalendarEvent(
          id: 'all-day',
          title: 'Release day',
          start: DateTime(2026, 8, 4),
          end: DateTime(2026, 8, 5),
          isAllDay: true,
        ),
      ],
      configuration: const CalendarTimelineConfiguration(
        viewportHeight: 300,
      ),
    )));

    expect(find.text('Release day'), findsOneWidget);
  });

  testWidgets('week timeline renders contiguous day columns without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(280, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(WeekTimeline<String>(
      startDate: DateTime(2026, 8, 3),
      events: [_event('first', 9, 11)],
      configuration: const CalendarTimelineConfiguration(
        startHour: 8,
        endHour: 14,
        viewportHeight: 420,
      ),
    )));

    expect(find.text('first'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('day timeline accepts asynchronous event sources',
      (tester) async {
    await tester.pumpWidget(_app(DayTimeline<String>(
      date: DateTime(2026, 8, 4),
      eventSource: _TimelineSource(),
      configuration: const CalendarTimelineConfiguration(
        startHour: 8,
        endHour: 14,
        viewportHeight: 420,
      ),
    )));
    await tester.pump();

    expect(find.text('remote'), findsOneWidget);
  });

  testWidgets('week timeline exposes unique all-day events above the grid',
      (tester) async {
    await tester.pumpWidget(_app(WeekTimeline<Object?>(
      startDate: DateTime(2026, 8, 3),
      events: [
        CalendarEvent(
          id: 'sprint',
          title: 'Build sprint',
          start: DateTime(2026, 8, 4),
          end: DateTime(2026, 8, 7),
          isAllDay: true,
        ),
      ],
      configuration: const CalendarTimelineConfiguration(
        startHour: 8,
        endHour: 14,
        viewportHeight: 420,
      ),
    )));

    expect(find.text('Build sprint'), findsOneWidget);
  });
}

class _TimelineSource implements CalendarEventSource<String> {
  @override
  Future<List<CalendarEvent<String>>> load(
    CalendarVisibleInterval interval,
  ) async {
    return [_event('remote', 9, 10)];
  }
}

CalendarEvent<String> _event(String id, int startHour, int endHour) {
  return CalendarEvent(
    id: id,
    title: id,
    data: '$id-payload',
    start: DateTime(2026, 8, 4, startHour),
    end: DateTime(2026, 8, 4, endHour),
  );
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));
