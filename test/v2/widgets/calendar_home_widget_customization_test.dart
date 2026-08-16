import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  final data = CalendarHomeWidgetData(
    generatedAt: DateTime.utc(2026, 8, 15, 8),
    selectedDate: DateTime(2026, 8, 15),
    title: 'Launch week',
    subtitle: 'Four milestones ready',
    completedCount: 3,
    totalCount: 5,
    events: List.generate(
      6,
      (index) => CalendarHomeWidgetEvent(
        id: 'event-$index',
        title: 'Calendar event ${index + 1}',
        subtitle: 'Product work',
        location: 'Studio ${index + 1}',
        start: DateTime(2026, 8, 15, 9 + index),
        end: DateTime(2026, 8, 15, 10 + index),
        colorValue: 0xff55d6be + index,
      ),
    ),
  );

  test('configuration and every theme token round-trip through JSON', () {
    const configuration = CalendarHomeWidgetConfiguration(
      family: CalendarHomeWidgetFamily.extraLarge,
      content: CalendarHomeWidgetContent.agenda,
      theme: CalendarHomeWidgetTheme(
        backgroundColor: Color(0xff07111f),
        foregroundColor: Color(0xfff7fbff),
        secondaryColor: Color(0xff9fb1c7),
        accentColor: Color(0xff55d6be),
        dividerColor: Color(0x3355d6be),
        surfaceStyle: CalendarHomeWidgetSurfaceStyle.gradient,
        gradientColors: [Color(0xff07111f), Color(0xff183f4d)],
        borderColor: Color(0xff55d6be),
        borderWidth: 2,
        elevation: 8,
        cornerRadius: 30,
        typographyScale: 1.2,
        density: CalendarHomeWidgetDensity.spacious,
        firstDayOfWeek: DateTime.saturday,
        headerStyle: CalendarHomeWidgetHeaderStyle.month,
        eventStyle: CalendarHomeWidgetEventStyle.card,
        dateShape: CalendarHomeWidgetDateShape.rounded,
        progressStyle: CalendarHomeWidgetProgressStyle.segmented,
        weekdayFormat: CalendarHomeWidgetWeekdayFormat.full,
        contentPadding: EdgeInsets.fromLTRB(18, 16, 18, 14),
        itemSpacing: 7,
        eventIndicatorWidth: 6,
        maximumEvents: 4,
        showWeekday: true,
        showEventTime: false,
        showProgress: true,
        showSubtitle: false,
        showLocation: false,
        useEventColors: false,
        animateChanges: false,
      ),
    );

    final decoded = CalendarHomeWidgetConfiguration.fromJson(
      configuration.toJson(),
    );

    expect(decoded.toJson(), configuration.toJson());
    expect(
      decoded.theme.copyWith(maximumEvents: 2).maximumEvents,
      2,
    );
  });

  testWidgets('bridge preserves data-only calls and nests configuration',
      (tester) async {
    const channel = MethodChannel('test.calendar.widget.customization');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    const bridge = CalendarHomeWidgetBridge(channel: channel);

    expect(await bridge.update(data), isTrue);
    expect(
        await bridge.update(
          data,
          configuration: const CalendarHomeWidgetConfiguration(
            family: CalendarHomeWidgetFamily.medium,
            content: CalendarHomeWidgetContent.week,
            theme: CalendarHomeWidgetTheme(
              surfaceStyle: CalendarHomeWidgetSurfaceStyle.outlined,
            ),
          ),
        ),
        isTrue);

    final first = (calls.first.arguments as Map<Object?, Object?>);
    final second = (calls.last.arguments as Map<Object?, Object?>);
    expect(first, isNot(contains('configuration')));
    expect(first['selectedDate'], second['selectedDate']);
    expect(second['configuration'], isA<Map<Object?, Object?>>());
  });

  testWidgets('all surface and density combinations remain responsive',
      (tester) async {
    for (final family in CalendarHomeWidgetFamily.values) {
      for (final surface in CalendarHomeWidgetSurfaceStyle.values) {
        for (final density in CalendarHomeWidgetDensity.values) {
          await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(1.6),
              ),
              child: Center(
                child: SizedBox.fromSize(
                  size: family.previewSize,
                  child: CalendarHomeWidget(
                    data: data,
                    family: family,
                    content: CalendarHomeWidgetContent.agenda,
                    theme: CalendarHomeWidgetTheme(
                      surfaceStyle: surface,
                      density: density,
                      gradientColors: const [
                        Color(0xff08111f),
                        Color(0xff17334d),
                      ],
                      maximumEvents: 4,
                    ),
                  ),
                ),
              ),
            ),
          ));
          expect(
            tester.takeException(),
            isNull,
            reason: '${family.name}/${surface.name}/${density.name}',
          );
        }
      }
    }
  });

  testWidgets('custom styles are observable in the rendered preview',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox.fromSize(
          size: CalendarHomeWidgetFamily.large.previewSize,
          child: CalendarHomeWidget(
            data: data,
            family: CalendarHomeWidgetFamily.large,
            content: CalendarHomeWidgetContent.agenda,
            theme: const CalendarHomeWidgetTheme(
              surfaceStyle: CalendarHomeWidgetSurfaceStyle.gradient,
              gradientColors: [Color(0xff07111f), Color(0xff183f4d)],
              eventStyle: CalendarHomeWidgetEventStyle.dot,
              maximumEvents: 2,
              showSubtitle: false,
              showLocation: false,
            ),
          ),
        ),
      ),
    ));

    expect(
        find.byKey(const ValueKey('calendar-home-widget-surface')), findsOne);
    expect(find.byKey(const ValueKey('calendar-home-widget-event-dot')),
        findsNWidgets(2));
    expect(find.text('Calendar event 3'), findsNothing);
    expect(find.textContaining('Studio'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
