import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  testWidgets('date carousel keeps dates contiguous and returns typed metadata',
      (tester) async {
    DateTime? selected;
    String? selectedData;
    final items = [
      CalendarCarouselItem(
        date: DateTime(2026, 8, 5),
        data: 'priority',
        title: 'Release',
        subtitle: 'Two milestones',
        badge: '2',
      ),
    ];

    await tester.pumpWidget(_app(
      CalendarDateCarousel<String>(
        startDate: DateTime(2026, 8, 3),
        dayCount: 7,
        selectedDate: DateTime(2026, 8, 4),
        onDateSelected: (date) => selected = date,
        items: items,
        cardBuilder: (context, state) {
          if (state.isSelected) selectedData = state.item?.data;
          return Text(state.item?.title ?? '${state.date.day}');
        },
      ),
    ));

    expect(
      find.byKey(const ValueKey('calendar-carousel-day-2026-08-03')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('calendar-carousel-day-2026-08-09')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const ValueKey('calendar-carousel-day-2026-08-09')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('calendar-carousel-day-2026-08-05')),
    );

    expect(selected, DateTime(2026, 8, 5));

    await tester.pumpWidget(_app(
      CalendarDateCarousel<String>(
        startDate: DateTime(2026, 8, 3),
        dayCount: 7,
        selectedDate: DateTime(2026, 8, 5),
        onDateSelected: (_) {},
        items: items,
        cardBuilder: (context, state) {
          if (state.isSelected) selectedData = state.item?.data;
          return Text(state.item?.title ?? '${state.date.day}');
        },
      ),
    ));

    expect(selectedData, 'priority');
  });

  testWidgets('carousel survives compact large-text presentation',
      (tester) async {
    tester.view.physicalSize = const Size(280, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _app(
          CalendarDateCarousel<Object?>(
            startDate: DateTime(2026, 8, 1),
            dayCount: 31,
            selectedDate: DateTime(2026, 8, 4),
            onDateSelected: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('adaptive navigation uses Material and Cupertino controls',
      (tester) async {
    await tester.pumpWidget(_app(
      AdaptiveCalendarNavigationBar(
        focusedDate: DateTime(2026, 8, 4),
        onPrevious: () {},
        onNext: () {},
      ),
      platform: TargetPlatform.android,
    ));
    expect(find.byType(IconButton), findsWidgets);
    expect(find.byType(CupertinoButton), findsNothing);

    await tester.pumpWidget(_app(
      AdaptiveCalendarNavigationBar(
        focusedDate: DateTime(2026, 8, 4),
        onPrevious: () {},
        onNext: () {},
      ),
      platform: TargetPlatform.iOS,
    ));
    expect(find.byType(CupertinoButton), findsWidgets);
  });

  testWidgets('adaptive picker returns an enabled normalized civil date',
      (tester) async {
    DateTime? result;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => FilledButton(
        onPressed: () async {
          result = await showAdaptiveCalendarPicker(
            context: context,
            initialDate: DateTime(2026, 8, 4, 18),
            bounds: CalendarDateRange(
              DateTime(2026, 8, 1),
              DateTime(2026, 8, 31),
            ),
            selectableDayPredicate: (date) => date.day != 5,
          );
        },
        child: const Text('Open'),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('month-day-2026-08-06')));
    await tester.pumpAndSettle();

    expect(result, DateTime(2026, 8, 6));
  });

  testWidgets('adaptive picker uses Cupertino popup controls on iOS',
      (tester) async {
    DateTime? result;
    await tester.pumpWidget(_app(
      Builder(
        builder: (context) => FilledButton(
          onPressed: () async {
            result = await showAdaptiveCalendarPicker(
              context: context,
              initialDate: DateTime(2026, 8, 4),
            );
          },
          child: const Text('Open iOS'),
        ),
      ),
      platform: TargetPlatform.iOS,
    ));

    await tester.tap(find.text('Open iOS'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoButton), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('month-day-2026-08-06')));
    await tester.pumpAndSettle();
    expect(result, DateTime(2026, 8, 6));
  });

  testWidgets('adaptive picker can explicitly use Cupertino wheels',
      (tester) async {
    DateTime? result;
    await tester.pumpWidget(_app(
      Builder(
        builder: (context) => FilledButton(
          onPressed: () async {
            result = await showAdaptiveCalendarPicker(
              context: context,
              initialDate: DateTime(2026, 8, 4),
              appearance: const CalendarAppearance(
                style: CalendarStyle.cupertino,
              ),
              cupertinoPresentation: CalendarCupertinoPickerPresentation.wheel,
            );
          },
          child: const Text('Open wheel picker'),
        ),
      ),
      platform: TargetPlatform.iOS,
    ));

    await tester.tap(find.text('Open wheel picker'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('Cupertino Tinted explicit wheel never falls back to month grid',
      (tester) async {
    await tester.pumpWidget(_app(
      Builder(
        builder: (context) => FilledButton(
          onPressed: () => showAdaptiveCalendarPicker(
            context: context,
            initialDate: DateTime(2026, 8, 4),
            appearance: const CalendarAppearance(
              style: CalendarStyle.cupertinoTinted,
            ),
            cupertinoPresentation: CalendarCupertinoPickerPresentation.wheel,
          ),
          child: const Text('Open tinted wheel'),
        ),
      ),
      platform: TargetPlatform.android,
    ));

    await tester.tap(find.text('Open tinted wheel'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    expect(find.byType(MonthCalendar), findsNothing);
    final modal = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('calendar-cupertino-modal-background')),
    );
    expect(modal.color.a, 1);
  });

  testWidgets(
      'Material picker confirm action row never overflows at narrow '
      'width or large text', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 780 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    DateTime? result;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData.fromView(tester.view).copyWith(
          textScaler: const TextScaler.linear(1.6),
        ),
        child: _app(
          Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showAdaptiveCalendarPicker(
                  context: context,
                  initialDate: DateTime(2026, 8, 4),
                  appearance: const CalendarAppearance(
                    style: CalendarStyle.material,
                  ),
                  materialConfiguration:
                      const CalendarMaterialPickerConfiguration(
                    presentation: CalendarMaterialPickerPresentation.dialog,
                    confirmSelection: true,
                    helpText: 'Pick any day that works best for you',
                  ),
                );
              },
              child: const Text('Open confirm dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open confirm dialog'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final confirmButton =
        find.byKey(const ValueKey('adaptive-calendar-confirm'));
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(result, DateTime(2026, 8, 4));
  });

  testWidgets(
      'Material picker never produces negative height constraints when '
      'keyboard insets nearly consume the viewport', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData.fromView(tester.view).copyWith(
          size: const Size(360, 480),
          viewInsets: const EdgeInsets.only(bottom: 470),
        ),
        child: _app(
          Builder(
            builder: (context) => FilledButton(
              onPressed: () => showAdaptiveCalendarPicker(
                context: context,
                initialDate: DateTime(2026, 8, 4),
                appearance: const CalendarAppearance(
                  style: CalendarStyle.material,
                ),
              ),
              child: const Text('Open under keyboard'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open under keyboard'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget child, {TargetPlatform platform = TargetPlatform.android}) {
  return MaterialApp(
    key: ValueKey(platform),
    theme: ThemeData(useMaterial3: true, platform: platform),
    home: Scaffold(body: child),
  );
}
