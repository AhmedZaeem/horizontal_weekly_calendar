import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  final interval = CalendarVisibleInterval(
    DateTime(2026, 8, 3),
    DateTime(2026, 8, 10),
  );

  testWidgets('groups cross-midnight events and returns typed originals',
      (tester) async {
    final tapped = <CalendarEvent<String>>[];
    final event = CalendarEvent(
      id: 'overnight',
      title: 'Night shift',
      start: DateTime(2026, 8, 4, 22),
      end: DateTime(2026, 8, 5, 2),
      data: 'payload',
    );
    await tester.pumpWidget(_app(CalendarAgenda<String>(
      interval: interval,
      events: [event],
      onEventTap: tapped.add,
    )));

    expect(find.text('Night shift'), findsNWidgets(2));
    await tester.tap(find.text('Night shift').first);
    expect(tapped.single.data, 'payload');
  });

  testWidgets('supports empty-day sections and builder overrides',
      (tester) async {
    await tester.pumpWidget(_app(CalendarAgenda<Object?>(
      interval: interval,
      showEmptyDays: true,
      builders: CalendarAgendaBuilders<Object?>(
        sectionBuilder: (context, date, count) =>
            Text('day-${date.day}-$count'),
      ),
    )));

    expect(find.text('day-3-0'), findsOneWidget);
    expect(find.text('day-9-0'), findsOneWidget);
  });

  testWidgets('renders asynchronous loading, error, and retry states',
      (tester) async {
    final source = _AgendaSource();
    await tester.pumpWidget(_app(SizedBox(
      height: 400,
      child: CalendarAgenda<Object?>(
        interval: interval,
        eventSource: source,
      ),
    )));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    source.completers.single.completeError(StateError('offline'));
    await tester.pump();
    expect(find.textContaining('offline'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(source.completers, hasLength(2));
    source.completers.last.complete(const []);
    await tester.pump();
    expect(find.text('No events'), findsOneWidget);
  });
}

class _AgendaSource implements CalendarEventSource<Object?> {
  final completers = <Completer<List<CalendarEvent<Object?>>>>[];

  @override
  Future<List<CalendarEvent<Object?>>> load(
    CalendarVisibleInterval interval,
  ) {
    final completer = Completer<List<CalendarEvent<Object?>>>();
    completers.add(completer);
    return completer.future;
  }
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));
