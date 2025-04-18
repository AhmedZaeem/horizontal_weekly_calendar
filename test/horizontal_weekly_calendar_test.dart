import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  group('HorizontalWeeklyCalendar Widget Tests', () {
    late DateTime initialDate;
    late DateTime selectedDate;
    late bool onDateSelectedCalled;
    late bool onNextMonthCalled;
    late bool onPreviousMonthCalled;

    setUp(() {
      initialDate = DateTime(2023, 10, 1); // October 1, 2023 (Sunday)
      selectedDate =
          DateTime(2023, 10, 3); // Initial selected date is October 3
      onDateSelectedCalled = false;
      onNextMonthCalled = false;
      onPreviousMonthCalled = false;
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: HorizontalWeeklyCalendar(
            initialDate: initialDate,
            selectedDate: selectedDate,
            onDateSelected: (date) {
              onDateSelectedCalled = true;
              selectedDate = date;
            },
            onNextMonth: () {
              onNextMonthCalled = true;
            },
            onPreviousMonth: () {
              onPreviousMonthCalled = true;
            },
            calendarType: HorizontalCalendarType.standard,
            calendarStyle: const HorizontalCalendarStyle(
              activeDayColor: Colors.red,
              dayIndicatorColor: Colors.grey,
              dayIndicatorSize: 50,
            ),
          ),
        ),
      );
    }

    testWidgets('renders the widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify the month header is displayed
      expect(
          find.text(DateFormat('MMMM y').format(initialDate)), findsOneWidget);

      // Verify the days of the week are displayed
      for (int i = 0; i < 7; i++) {
        final day = initialDate.add(Duration(days: i));
        expect(find.text(DateFormat('E').format(day).substring(0, 2)),
            findsWidgets);
        expect(find.text(day.day.toString()), findsWidgets);
      }
    });

    testWidgets('calls onDateSelected when a day is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap on October 5 (different from initial selectedDate October 3)
      final dayToSelect = find.text('5');
      await tester.tap(dayToSelect);
      await tester.pumpAndSettle();

      expect(onDateSelectedCalled, isTrue);
      expect(selectedDate, DateTime(2023, 10, 5)); // Now changes from 3 to 5
    });

    testWidgets('calls onNextMonth when the next month icon is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap on the next month icon
      final nextMonthIcon = find.byIcon(Icons.arrow_forward_ios);
      await tester.tap(nextMonthIcon);
      await tester.pumpAndSettle();

      // Verify the callback is called
      expect(onNextMonthCalled, isTrue);
    });

    testWidgets('calls onPreviousMonth when the previous month icon is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap on the previous month icon
      final previousMonthIcon = find.byIcon(Icons.arrow_back_ios);
      await tester.tap(previousMonthIcon);
      await tester.pumpAndSettle();

      // Verify the callback is called
      expect(onPreviousMonthCalled, isTrue);
    });

    testWidgets('displays the correct styles for active and inactive days',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Active day (3) - October 3 is the initial selectedDate
      final activeDay = find.text('3');
      final activeIndicator = tester.widget<CircleAvatar>(find.ancestor(
        of: activeDay,
        matching: find.byType(CircleAvatar),
      ));
      expect(activeIndicator.backgroundColor, Colors.red);

      // Inactive day (4) - October 4 is not selected
      final inactiveDay = find.text('4');
      final inactiveIndicator = tester.widget<CircleAvatar>(find.ancestor(
        of: inactiveDay,
        matching: find.byType(CircleAvatar),
      ));
      expect(inactiveIndicator.backgroundColor, Colors.grey);
    });

    testWidgets('updates the week view when the selected date changes',
        (WidgetTester tester) async {
      DateTime testSelectedDate = DateTime(2023, 10, 3);

      // First build with initial selectedDate (October 3)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: DateTime(2023, 10, 1),
              selectedDate: testSelectedDate,
              onDateSelected: (date) => testSelectedDate = date,
              onNextMonth: () {},
              onPreviousMonth: () {},
              calendarType: HorizontalCalendarType.standard,
              calendarStyle: const HorizontalCalendarStyle(
                activeDayColor: Colors.red,
                dayIndicatorColor: Colors.grey,
                dayIndicatorSize: 50,
              ),
            ),
          ),
        ),
      );

      // Verify initial week (October 1-7)
      await tester.pumpAndSettle();
      for (int i = 1; i <= 7; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }

      // Rebuild with new selectedDate (October 12)
      testSelectedDate = DateTime(2023, 10, 12);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: DateTime(2023, 10, 1),
              selectedDate: testSelectedDate,
              onDateSelected: (date) => testSelectedDate = date,
              onNextMonth: () {},
              onPreviousMonth: () {},
              calendarType: HorizontalCalendarType.standard,
              calendarStyle: const HorizontalCalendarStyle(
                activeDayColor: Colors.red,
                dayIndicatorColor: Colors.grey,
                dayIndicatorSize: 50,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the second week (October 8-14)
      for (int i = 8; i <= 14; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }
    });
    testWidgets('handles minimal calendar type correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar.minimal(
              initialDate: DateTime(2023, 10, 1),
              selectedDate: DateTime(2023, 10, 5),
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
            ),
          ),
        ),
      );

      // Verify no two-letter day names (e.g., 'Su', 'Mo')
      expect(find.text('Su'), findsNothing);
      expect(find.text('Mo'), findsNothing);
    });

    testWidgets('handles outlined calendar type correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalWeeklyCalendar(
              initialDate: initialDate,
              selectedDate: selectedDate,
              onDateSelected: (date) {},
              onNextMonth: () {},
              onPreviousMonth: () {},
              calendarType: HorizontalCalendarType.outlined,
              calendarStyle: HorizontalCalendarStyle(
                dayIndicatorBorder: Border.all(color: Colors.green),
              ),
            ),
          ),
        ),
      );

      // Verify the outlined style is applied
      final dayIndicator = find.byType(Container).first;
      final containerWidget = tester.widget<Container>(dayIndicator);
      final decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect((decoration.border as Border).top.color, Colors.green);
    });
  });
}
