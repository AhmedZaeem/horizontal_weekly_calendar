import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('celestial picker skips disabled dates consistently',
      (tester) async {
    DateTime? changed;
    await tester.pumpWidget(_material(CelestialDatePicker(
      value: DateTime(2026, 8, 4),
      onChanged: (value) => changed = value,
      bounds: CalendarDateRange(
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 31),
      ),
      selectableDayPredicate: (date) => date.day != 5,
    )));

    await tester.tap(find.byKey(const ValueKey('celestial-next-day')));
    await tester.pumpAndSettle();

    expect(changed, DateTime(2026, 8, 6));
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cupertino wheel renders inline and modal cancellation is null',
      (tester) async {
    DateTime? value;
    await tester.pumpWidget(CupertinoApp(
      home: CupertinoPageScaffold(
        child: Builder(
          builder: (context) => Column(
            children: [
              SizedBox(
                height: 240,
                child: CalendarCupertinoDatePicker(
                  value: DateTime(2026, 8, 4),
                  onChanged: (next) => value = next,
                  configuration: const CalendarCupertinoPickerConfiguration(
                    mode: CalendarCupertinoPickerMode.date,
                    showDayOfWeek: true,
                  ),
                ),
              ),
              CupertinoButton(
                onPressed: () async {
                  value = await showCalendarCupertinoDatePicker(
                    context: context,
                    initialValue: DateTime(2026, 8, 4),
                  );
                },
                child: const Text('Open wheel'),
              ),
            ],
          ),
        ),
      ),
    ));

    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    await tester.tap(find.text('Open wheel'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoDatePicker), findsNWidgets(2));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(value, isNull);
  });

  testWidgets('Cupertino wheel supports every native mode and custom extent',
      (tester) async {
    for (final mode in CalendarCupertinoPickerMode.values) {
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: CalendarCupertinoDatePicker(
            value: DateTime(2026, 8, 4, 10, 30),
            onChanged: (_) {},
            configuration: CalendarCupertinoPickerConfiguration(
              mode: mode,
              itemExtent: 40,
              minuteInterval: 5,
              use24HourFormat: true,
            ),
          ),
        ),
      ));
      expect(
          tester
              .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
              .itemExtent,
          40);
      expect(tester.takeException(), isNull, reason: mode.name);
    }
  });

  testWidgets('Cupertino modal confirms its provisional value', (tester) async {
    DateTime? value;
    await tester.pumpWidget(CupertinoApp(
      home: CupertinoPageScaffold(
        child: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () async {
              value = await showCalendarCupertinoDatePicker(
                context: context,
                initialValue: DateTime(2026, 8, 4),
                showToday: false,
              );
            },
            child: const Text('Confirm wheel'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Confirm wheel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(value, DateTime(2026, 8, 4));
  });

  testWidgets('date rail and availability return typed payloads',
      (tester) async {
    String? railPayload;
    String? slotPayload;
    final slot = CalendarAvailabilitySlot(
      id: 'slot',
      start: DateTime(2026, 8, 4, 9),
      end: DateTime(2026, 8, 4, 9, 30),
      data: 'availability',
    );

    await tester.pumpWidget(_material(Column(
      children: [
        Expanded(
          child: CalendarDateRail<String>(
            startDate: DateTime(2026, 8, 3),
            dayCount: 3,
            selectedDate: DateTime(2026, 8, 3),
            onDateSelected: (_) {},
            onItemSelected: (item) => railPayload = item?.data,
            items: [
              CalendarCarouselItem(
                date: DateTime(2026, 8, 4),
                data: 'rail',
              ),
            ],
          ),
        ),
        CalendarAvailabilityStrip<String>(
          slots: [slot],
          onSlotSelected: (value) => slotPayload = value.data,
        ),
      ],
    )));

    await tester.tap(find.byKey(const ValueKey('calendar-rail-2026-08-04')));
    await tester.tap(find.byKey(const ValueKey('availability-slot-slot')));
    expect(railPayload, 'rail');
    expect(slotPayload, 'availability');
  });

  testWidgets('schedule ribbon and milestones preserve typed originals',
      (tester) async {
    String? intervalPayload;
    String? milestonePayload;
    final interval = CalendarScheduleInterval(
      id: 'meeting',
      start: DateTime(2026, 8, 4, 9),
      end: DateTime(2026, 8, 4, 10),
      data: 'schedule',
    );
    final milestone = CalendarMilestone(
      id: 'launch',
      date: DateTime(2026, 8, 5),
      title: 'Launch',
      data: 'milestone',
    );

    await tester.pumpWidget(_material(ListView(
      children: [
        CalendarScheduleRibbon<String>(
          date: DateTime(2026, 8, 4),
          intervals: [interval],
          onIntervalTap: (value) => intervalPayload = value.data,
        ),
        SizedBox(
          height: 130,
          child: CalendarMilestoneTimeline<String>(
            milestones: [milestone],
            currentDate: DateTime(2026, 8, 4),
            onMilestoneTap: (value) => milestonePayload = value.data,
          ),
        ),
      ],
    )));

    await tester.tap(find.byKey(const ValueKey('schedule-interval-meeting')));
    await tester.tap(find.byKey(const ValueKey('calendar-milestone-launch')));
    expect(intervalPayload, 'schedule');
    expect(milestonePayload, 'milestone');
  });

  testWidgets('new date surfaces survive compact width and large text',
      (tester) async {
    tester.view.physicalSize = const Size(280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final surfaces = <(String, Widget)>[
      (
        'celestial',
        CelestialDatePicker(
          value: DateTime(2026, 8, 4),
          onChanged: (_) {},
        )
      ),
      (
        'cupertino',
        CalendarCupertinoDatePicker(
          value: DateTime(2026, 8, 4),
          onChanged: (_) {},
        )
      ),
      (
        'rail',
        SizedBox(
          height: 320,
          child: CalendarDateRail<Object?>(
            startDate: DateTime(2026, 8, 1),
            dayCount: 20,
            selectedDate: DateTime(2026, 8, 4),
            onDateSelected: (_) {},
          ),
        )
      ),
      (
        'ribbon',
        CalendarScheduleRibbon<Object?>(
          date: DateTime(2026, 8, 4),
          intervals: [
            CalendarScheduleInterval(
              id: 'long',
              title: 'Long translated schedule title',
              start: DateTime(2026, 8, 4, 9),
              end: DateTime(2026, 8, 4, 10),
            ),
          ],
          startHour: 8,
          endHour: 12,
        )
      ),
      (
        'milestone',
        SizedBox(
          height: 150,
          child: CalendarMilestoneTimeline<Object?>(
            milestones: [
              CalendarMilestone(
                id: 'long',
                date: DateTime(2026, 8, 4),
                title: 'Long translated milestone title',
              ),
            ],
            currentDate: DateTime(2026, 8, 4),
          ),
        )
      ),
      (
        'availability',
        CalendarAvailabilityStrip<Object?>(
          slots: [
            CalendarAvailabilitySlot(
              id: 'long',
              start: DateTime(2026, 8, 4, 9),
              end: DateTime(2026, 8, 4, 9, 30),
              label: 'Long localized slot label',
            ),
          ],
        )
      ),
    ];

    for (final direction in TextDirection.values) {
      for (final surface in surfaces) {
        await tester.pumpWidget(MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: _material(surface.$2, direction: direction),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: '${surface.$1} ${direction.name}');
      }
    }
  });

  testWidgets('large rail and availability sources build lazily',
      (tester) async {
    tester.view.physicalSize = const Size(320, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var railBuilds = 0;

    await tester.pumpWidget(_material(SizedBox(
      height: 240,
      child: CalendarDateRail<Object?>(
        startDate: DateTime(2026, 1, 1),
        dayCount: 366,
        selectedDate: DateTime(2026, 1, 1),
        onDateSelected: (_) {},
        itemBuilder: (context, state) {
          railBuilds += 1;
          return Text('${state.date.day}');
        },
      ),
    )));
    expect(railBuilds, inInclusiveRange(1, 12));

    var slotBuilds = 0;
    final slots = [
      for (var index = 0; index < 366; index += 1)
        CalendarAvailabilitySlot<Object?>(
          id: 'slot-$index',
          start: DateTime(2026, 1, 1).add(Duration(minutes: index * 30)),
          end: DateTime(2026, 1, 1).add(Duration(minutes: index * 30 + 30)),
        ),
    ];
    await tester.pumpWidget(_material(CalendarAvailabilityStrip<Object?>(
      slots: slots,
      itemBuilder: (context, state) {
        slotBuilds += 1;
        return Text(state.slot.id);
      },
    )));
    expect(slotBuilds, inInclusiveRange(1, 12));
  });
}

Widget _material(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
}) {
  return MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: Scaffold(body: child),
    ),
  );
}
