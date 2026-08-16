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
    expect(realWorldRoutes.length, realWorldExamples.length);
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
