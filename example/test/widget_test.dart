import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar_example/main.dart';
import 'package:horizontal_weekly_calendar_example/calendar_playground.dart';
import 'package:horizontal_weekly_calendar_example/home_widget_studio.dart';

void main() {
  testWidgets('opens the interactive calendar gallery', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CalendarGalleryApp());
    await tester.pump();

    expect(find.text('Horizontal Calendar 2.0'), findsOneWidget);
    expect(
        find.text('Explore the API instead of guessing at it'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('capture catalogue renders every showcase family',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final kind in [
      'styles',
      'motion',
      'foldable',
      'native',
      'planning',
      'data',
      'selection',
      'celestial',
      'widgets',
      'legacy',
      'carousel',
      'horizon',
      'heatmaps',
      'responsive',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: CaptureShowcase(kind: kind),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: kind);
    }
  });

  testWidgets('calendar playground exposes live foldable controls',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const CalendarPlaygroundPage(),
      ),
    );
    await tester.pump();

    expect(find.text('Configure the real widget'), findsOneWidget);
    expect(find.byKey(const ValueKey('playground-horizontal')), findsOneWidget);
    final verticalList = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
    );
    await tester.drag(verticalList, const Offset(0, -700));
    await tester.pumpAndSettle();
    const toggleKey = ValueKey('playground-foldable-toggle');
    await tester.ensureVisible(find.byKey(toggleKey));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(toggleKey),
        matching: find.byType(FilterChip),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(verticalList, const Offset(0, 1000));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('playground-foldable')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home-widget studio exposes a responsive configured preview',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const HomeWidgetStudioPage(),
      ),
    );
    await tester.pump();

    expect(find.text('Design the glance'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-widget-studio-preview')),
      findsOneWidget,
    );
    expect(find.textContaining('Live preview · medium / week'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('developer studios survive compact large-text scrolling',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final page in const [
      CalendarPlaygroundPage(),
      HomeWidgetStudioPage(),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.4),
            ),
            child: child!,
          ),
          home: page,
        ),
      );
      await tester.pump();
      final verticalList = find.byWidgetPredicate(
        (widget) =>
            widget is ListView && widget.scrollDirection == Axis.vertical,
      );
      for (var index = 0; index < 9; index++) {
        await tester.drag(verticalList, const Offset(0, -520));
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: page.runtimeType.toString());
      }
    }
  });
}
