import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/weekly_calendar.dart';

void main() {
  group('HorizontalWeeklyCalendar', () {
    testWidgets('renders with required parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(HorizontalWeeklyCalendar), findsOneWidget);
    });

    testWidgets('shows month header by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.text('March 2026'), findsOneWidget);
    });

    testWidgets('hides month header when showMonthHeader is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
              showMonthHeader: false,
            ),
          ),
        ),
      );

      expect(find.text('March 2026'), findsNothing);
    });

    testWidgets('disables next month button when at maxDate boundary',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
              maxDate: DateTime(2026, 3, 31),
            ),
          ),
        ),
      );

      final nextButton = find.byIcon(Icons.chevron_right);
      expect(nextButton, findsOneWidget);
      final iconButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.chevron_right));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('disables previous month button when at minDate boundary',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
              minDate: DateTime(2026, 3, 1),
            ),
          ),
        ),
      );

      final prevButton = find.byIcon(Icons.chevron_left);
      expect(prevButton, findsOneWidget);
      final iconButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.chevron_left));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('renders outlined variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar.outlined(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(HorizontalWeeklyCalendar), findsOneWidget);
    });

    testWidgets('renders minimal variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar.minimal(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(HorizontalWeeklyCalendar), findsOneWidget);
    });

    testWidgets('calls onDateSelected when a day is tapped', (tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 1),
              onDateSelected: (date) => selectedDate = date,
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('2').first);
      await tester.pumpAndSettle();
      expect(selectedDate, isNotNull);
    });

    testWidgets('does not call onDateSelected for disabled dates',
        (tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 5),
              onDateSelected: (date) => selectedDate = date,
              onNextMonth: () {},
              onPreviousMonth: () {},
              minDate: DateTime(2026, 3, 3),
            ),
          ),
        ),
      );

      await tester.tap(find.text('1').first);
      await tester.pumpAndSettle();
      expect(selectedDate, isNull);
    });
  });

  group('TableWeeklyCalendar', () {
    testWidgets('renders with required parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onMonthChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(TableWeeklyCalendar), findsOneWidget);
    });

    testWidgets('shows month header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onMonthChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('March 2026'), findsOneWidget);
    });

    testWidgets('disables next month button when at maxDate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onMonthChanged: (_) {},
              maxDate: DateTime(2026, 3, 31),
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.chevron_right));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('uses custom header builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onMonthChanged: (_) {},
              headerBuilder: (context, date, onPrev, onNext) {
                return Text('Custom: ${date.month}/${date.year}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Custom: 3/2026'), findsOneWidget);
    });

    testWidgets('renders with focus dates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableWeeklyCalendar(
              initialDate: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              onDateSelected: (_) {},
              onMonthChanged: (_) {},
              focusDates: [
                FocusDate(
                  date: DateTime(2026, 3, 10),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TableWeeklyCalendar), findsOneWidget);
    });
  });

  group('EventCalendar', () {
    testWidgets('renders with required parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCalendar(
              currentMonth: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              events: const [],
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.byType(EventCalendar), findsOneWidget);
    });

    testWidgets('renders events on selected date', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCalendar(
              currentMonth: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              events: [
                CalendarEvent(
                  id: '1',
                  title: 'Test Event',
                  startTime: DateTime(2026, 3, 15, 10, 0),
                  endTime: DateTime(2026, 3, 15, 11, 0),
                ),
              ],
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Event'), findsOneWidget);
    });

    testWidgets('renders overlapping events side by side', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCalendar(
              currentMonth: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              events: [
                CalendarEvent(
                  id: '1',
                  title: 'Event A',
                  startTime: DateTime(2026, 3, 15, 10, 0),
                  endTime: DateTime(2026, 3, 15, 12, 0),
                  backgroundColor: Colors.blue,
                ),
                CalendarEvent(
                  id: '2',
                  title: 'Event B',
                  startTime: DateTime(2026, 3, 15, 11, 0),
                  endTime: DateTime(2026, 3, 15, 13, 0),
                  backgroundColor: Colors.red,
                ),
              ],
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.text('Event A'), findsOneWidget);
      expect(find.text('Event B'), findsOneWidget);
    });

    testWidgets('renders three overlapping events', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCalendar(
              currentMonth: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              events: [
                CalendarEvent(
                  id: '1',
                  title: 'E1',
                  startTime: DateTime(2026, 3, 15, 10, 0),
                  endTime: DateTime(2026, 3, 15, 12, 0),
                ),
                CalendarEvent(
                  id: '2',
                  title: 'E2',
                  startTime: DateTime(2026, 3, 15, 10, 30),
                  endTime: DateTime(2026, 3, 15, 11, 30),
                ),
                CalendarEvent(
                  id: '3',
                  title: 'E3',
                  startTime: DateTime(2026, 3, 15, 11, 0),
                  endTime: DateTime(2026, 3, 15, 13, 0),
                ),
              ],
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      expect(find.text('E1'), findsOneWidget);
      expect(find.text('E2'), findsOneWidget);
      expect(find.text('E3'), findsOneWidget);
    });

    testWidgets('respects minDate and maxDate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventCalendar(
              currentMonth: DateTime(2026, 3, 1),
              selectedDate: DateTime(2026, 3, 15),
              events: const [],
              onDateSelected: (_) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
              minDate: DateTime(2026, 3, 1),
              maxDate: DateTime(2026, 3, 31),
            ),
          ),
        ),
      );

      expect(find.byType(EventCalendar), findsOneWidget);
    });
  });
}
