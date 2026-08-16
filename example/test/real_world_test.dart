import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar_example/real_world/index.dart';

void main() {
  testWidgets('the catalogue lists every real-world example', (tester) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: RealWorldIndexPage()),
    );
    await tester.pumpAndSettle();

    for (final example in realWorldExamples) {
      expect(
        find.text(example.product),
        findsOneWidget,
        reason: 'missing catalogue entry for ${example.id}',
      );
    }
    // Every catalogue entry has a route, plus the two capture-only surfaces
    // that render the README artwork.
    for (final example in realWorldExamples) {
      expect(realWorldRoutes, contains(example.route));
    }
    expect(realWorldRoutes, contains('/hero'));
    expect(realWorldRoutes, contains('/home-screen'));
  });

  testWidgets('the capture surfaces build', (tester) async {
    tester.view.physicalSize = const Size(1032, 1376);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final route in ['/hero', '/home-screen']) {
      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: realWorldRoutes[route]!)),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(tester.takeException(), isNull, reason: 'route $route');
    }
  });

  testWidgets('every example has a unique id and route', (tester) async {
    final ids = realWorldExamples.map((example) => example.id).toSet();
    final routes = realWorldExamples.map((example) => example.route).toSet();

    expect(ids, hasLength(realWorldExamples.length));
    expect(routes, hasLength(realWorldExamples.length));
  });

  for (final example in realWorldExamples) {
    testWidgets('${example.id} builds and settles', (tester) async {
      // Tall viewport so a full screen lays out without needing to scroll.
      tester.view.physicalSize = const Size(430, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: example.builder)),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
    });
  }
}
