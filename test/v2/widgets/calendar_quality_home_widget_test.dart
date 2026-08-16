import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  test('day visual roles preserve range-middle contrast', () {
    final theme = HorizontalCalendarThemeData.material3();
    final state = CalendarDayState<Object?>(
      date: DateTime(2026, 8, 10),
      isToday: true,
      isSelected: true,
      isFocused: true,
      isDisabled: false,
      isOutsideInterval: false,
      rangePosition: CalendarRangePosition.middle,
      events: [],
      semanticLabel: 'Monday, selected',
    );

    final visual = CalendarDayVisualResolver.resolve(state, theme);

    expect(visual.backgroundColor, isNot(Colors.transparent));
    expect(visual.foregroundColor, isNot(theme.onAccentColor));
    expect(visual.eventColor, theme.accentColor);
  });

  testWidgets('availability auto layout remains responsive at 180 pixels',
      (tester) async {
    final start = DateTime(2026, 8, 10, 9);
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: 180,
          child: CalendarAvailabilityStrip<void>(
            slots: List.generate(
              4,
              (index) => CalendarAvailabilitySlot<void>(
                id: '$index',
                start: start.add(Duration(minutes: index * 45)),
                end: start.add(Duration(minutes: index * 45 + 30)),
                label: 'Consultation window ${index + 1}',
              ),
            ),
            layout: CalendarAvailabilityLayout.auto,
            design: CalendarAvailabilityDesign.schedule,
          ),
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.byType(CalendarAvailabilityStrip<void>), findsOneWidget);
  });

  testWidgets('home widget data round-trips and renders every family',
      (tester) async {
    final data = CalendarHomeWidgetData(
      generatedAt: DateTime.utc(2026, 8, 10, 8),
      selectedDate: DateTime(2026, 8, 10),
      title: 'My week',
      subtitle: 'Three focused days',
      events: [
        CalendarHomeWidgetEvent(
          id: 'review',
          title: 'Design review',
          start: DateTime(2026, 8, 10, 9),
          end: DateTime(2026, 8, 10, 10),
          colorValue: 0xff6750a4,
        ),
      ],
      action: const CalendarHomeWidgetAction(
        uri: 'calendar-example://day/2026-08-10',
      ),
    );
    final decoded = CalendarHomeWidgetData.fromJson(data.toJson());
    expect(decoded.toJson(), data.toJson());

    for (final family in CalendarHomeWidgetFamily.values) {
      for (final content in CalendarHomeWidgetContent.values) {
        await tester.pumpWidget(MaterialApp(
          home: Center(
            child: SizedBox.fromSize(
              size: family.previewSize,
              child: CalendarHomeWidget(
                data: decoded,
                family: family,
                content: content,
              ),
            ),
          ),
        ));
        expect(
          tester.takeException(),
          isNull,
          reason: '${family.name}/${content.name}',
        );
      }
    }
  });

  testWidgets('home widget bridge sends the stable payload contract',
      (tester) async {
    const channel = MethodChannel('test.calendar.widgets');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    final bridge = CalendarHomeWidgetBridge(channel: channel);
    final data = CalendarHomeWidgetData(
      generatedAt: DateTime.utc(2026, 8, 10),
      selectedDate: DateTime(2026, 8, 10),
    );

    expect(await bridge.update(data), isTrue);
    expect(calls.single.method, 'update');
    expect(calls.single.arguments, containsPair('schemaVersion', 1));
  });

  testWidgets('celestial compositions survive compact large text',
      (tester) async {
    for (final composition in CelestialComposition.values) {
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Center(
            child: SizedBox(
              width: 280,
              child: CelestialDatePicker(
                value: DateTime(2026, 8, 10),
                onChanged: (_) {},
                style: CelestialDatePickerStyle(
                  compact: true,
                  composition: composition,
                  showDateProgress: true,
                ),
              ),
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull, reason: composition.name);
    }
  });

  testWidgets('milestone and insight design matrices stay responsive',
      (tester) async {
    final milestones = [
      CalendarMilestone<void>(
        id: 'one',
        date: DateTime(2026, 8, 8),
        title: 'Research complete',
      ),
      CalendarMilestone<void>(
        id: 'two',
        date: DateTime(2026, 8, 10),
        title: 'Blocked launch milestone with a long name',
        state: CalendarMilestoneState.blocked,
      ),
    ];
    for (final design in CalendarMilestoneDesign.values) {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: SizedBox(
            width: 280,
            height: 150,
            child: CalendarMilestoneTimeline<void>(
              milestones: milestones,
              currentDate: DateTime(2026, 8, 10),
              design: design,
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull, reason: design.name);
    }

    final metrics = [
      CalendarInsightMetric<void>(
        id: 'focus',
        label: 'Focus time this week',
        value: '14.5 hours',
        progress: double.nan,
        trend: CalendarInsightTrend.up,
      ),
    ];
    for (final design in CalendarInsightsDesign.values) {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: SizedBox(
            width: 240,
            child: CalendarInsightsDashboard<void>(
              metrics: metrics,
              design: design,
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull, reason: design.name);
    }
  });
}
