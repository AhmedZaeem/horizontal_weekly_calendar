import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

/// Directory the captured picker screenshots are written to.
///
/// Override it with `--dart-define=SHOT_DIR=/path/to/output` when running the
/// driver; the default keeps the output inside the example project.
const _shotDir = String.fromEnvironment(
  'SHOT_DIR',
  defaultValue: 'build/picker-screenshots',
);

Future<void> _shoot(FlutterDriver driver, String name) async {
  final bytes = await driver.screenshot();
  await File('$_shotDir/$name.png').writeAsBytes(bytes);
  // ignore: avoid_print
  print('captured $name.png (${bytes.length} bytes)');
}

Future<void> main() async {
  await Directory(_shotDir).create(recursive: true);
  final driver = await FlutterDriver.connect();

  await driver.tap(find.byValueKey('open-material-sheet'));
  await Future<void>.delayed(const Duration(milliseconds: 700));
  await _shoot(driver, 'real_material_sheet');
  await driver.tap(find.text('Cancel'));
  await Future<void>.delayed(const Duration(milliseconds: 400));

  await driver.tap(find.byValueKey('open-material-dialog'));
  await Future<void>.delayed(const Duration(milliseconds: 700));
  await _shoot(driver, 'real_material_dialog');
  await driver.tap(find.text('Cancel'));
  await Future<void>.delayed(const Duration(milliseconds: 400));

  await driver.tap(find.byValueKey('open-cupertino-wheel'));
  await Future<void>.delayed(const Duration(milliseconds: 2500));
  await _shoot(driver, 'real_cupertino_wheel');
  await driver.tap(find.text('Cancel'));
  await Future<void>.delayed(const Duration(milliseconds: 800));

  await driver.tap(find.byValueKey('open-cupertino-calendar'));
  await Future<void>.delayed(const Duration(milliseconds: 2500));
  await _shoot(driver, 'real_cupertino_calendar');

  await driver.close();
}
