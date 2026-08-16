import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('snapping carousel keeps adjacent cards visible', (tester) async {
    tester.view.physicalSize = const Size(430, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(CalendarDateCarousel<Object?>(
      startDate: DateTime(2026, 8, 1),
      dayCount: 10,
      selectedDate: DateTime(2026, 8, 1),
      onDateSelected: (_) {},
      scrolling: CalendarScrollBehavior.page,
      cardExtent: 152,
    )));

    expect(find.byType(ListView), findsOneWidget);
    expect(
      tester
          .getTopLeft(
            find.byKey(
              const ValueKey('calendar-carousel-day-2026-08-02'),
            ),
          )
          .dx,
      lessThan(430),
    );
  });

  testWidgets('controlled selection and controller reveal visible dates',
      (tester) async {
    final selected = ValueNotifier(DateTime(2026, 8, 1));
    final controller = CalendarDateCarouselController();
    var callbacks = 0;
    addTearDown(selected.dispose);
    addTearDown(controller.dispose);

    await tester.pumpWidget(_app(ValueListenableBuilder<DateTime>(
      valueListenable: selected,
      builder: (context, value, _) => CalendarDateCarousel<Object?>(
        controller: controller,
        startDate: DateTime(2026, 8, 1),
        dayCount: 31,
        selectedDate: value,
        onDateSelected: (_) => callbacks += 1,
      ),
    )));

    selected.value = DateTime(2026, 8, 20);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('calendar-carousel-day-2026-08-20')),
      findsOneWidget,
    );
    expect(callbacks, 0);

    await controller.revealDate(DateTime(2026, 8, 28), animate: false);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('calendar-carousel-day-2026-08-28')),
      findsOneWidget,
    );
    expect(callbacks, 0);
  });

  testWidgets('controlled carousel shares multiple selection logic',
      (tester) async {
    CalendarSelection? proposal;
    await tester.pumpWidget(_app(CalendarDateCarousel<Object?>.controlled(
      startDate: DateTime(2026, 8, 1),
      dayCount: 7,
      selection: CalendarSelection.multiple([DateTime(2026, 8, 3)]),
      onSelectionChanged: (_, next) => proposal = next,
    )));

    await tester.tap(
      find.byKey(const ValueKey('calendar-carousel-day-2026-08-05')),
    );
    expect(proposal!.contains(DateTime(2026, 8, 3)), isTrue);
    expect(proposal!.contains(DateTime(2026, 8, 5)), isTrue);
  });

  testWidgets('full carousel metadata survives compact large text',
      (tester) async {
    tester.view.physicalSize = const Size(280, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? payload;

    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: _app(CalendarDateCarousel<String>(
        startDate: DateTime(2026, 8, 1),
        dayCount: 3,
        selectedDate: DateTime(2026, 8, 1),
        onDateSelected: (_) {},
        onItemSelected: (item) => payload = item?.data,
        items: [
          CalendarCarouselItem(
            date: DateTime(2026, 8, 2),
            title: 'A deliberately long milestone title',
            subtitle: 'Three appointments and a follow-up',
            badge: 'Limited',
            data: 'typed',
          ),
        ],
        events: [
          for (var index = 0; index < 3; index += 1)
            CalendarEvent(
              id: 'event-$index',
              start: DateTime(2026, 8, 2, 9 + index),
              end: DateTime(2026, 8, 2, 10 + index),
            ),
        ],
      )),
    ));

    expect(tester.takeException(), isNull);
    await tester.tap(
      find.byKey(const ValueKey('calendar-carousel-day-2026-08-02')),
    );
    expect(payload, 'typed');
    expect(tester.takeException(), isNull);
  });

  testWidgets('366-card sources build only the visible neighborhood',
      (tester) async {
    tester.view.physicalSize = const Size(320, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var builds = 0;

    await tester.pumpWidget(_app(CalendarDateCarousel<Object?>(
      startDate: DateTime(2026, 1, 1),
      dayCount: 366,
      selectedDate: DateTime(2026, 1, 1),
      onDateSelected: (_) {},
      cardBuilder: (context, state) {
        builds += 1;
        return Text('${state.date.day}');
      },
    )));

    expect(builds, inInclusiveRange(1, 12));
  });
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));
