import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  group('CalendarStyleResolver', () {
    test('classifies every Cupertino-oriented style consistently', () {
      for (final style in [
        CalendarStyle.cupertino,
        CalendarStyle.cupertinoGlass,
        CalendarStyle.cupertinoTinted,
      ]) {
        expect(
          CalendarStyleResolver.isCupertino(style, TargetPlatform.android),
          isTrue,
        );
      }
      expect(
        CalendarStyleResolver.isCupertino(
          CalendarStyle.adaptive,
          TargetPlatform.iOS,
        ),
        isTrue,
      );
      expect(
        CalendarStyleResolver.isCupertino(
          CalendarStyle.materialYou,
          TargetPlatform.iOS,
        ),
        isFalse,
      );
    });

    test('adaptive follows Apple, Android/Fuchsia, and neutral platforms', () {
      expect(
        CalendarStyleResolver.resolve(
          CalendarStyle.adaptive,
          TargetPlatform.iOS,
        ),
        CalendarStyle.cupertino,
      );
      expect(
        CalendarStyleResolver.resolve(
          CalendarStyle.adaptive,
          TargetPlatform.macOS,
        ),
        CalendarStyle.cupertino,
      );
      expect(
        CalendarStyleResolver.resolve(
          CalendarStyle.adaptive,
          TargetPlatform.android,
        ),
        CalendarStyle.material,
      );
      expect(
        CalendarStyleResolver.resolve(
          CalendarStyle.adaptive,
          TargetPlatform.fuchsia,
        ),
        CalendarStyle.material,
      );
      expect(
        CalendarStyleResolver.resolve(
          CalendarStyle.adaptive,
          TargetPlatform.linux,
        ),
        CalendarStyle.neutral,
      );
    });

    test('explicit styles are never changed by the platform', () {
      for (final style in [
        CalendarStyle.material,
        CalendarStyle.cupertino,
        CalendarStyle.neutral,
        CalendarStyle.glass,
        CalendarStyle.editorial,
        CalendarStyle.bold,
        CalendarStyle.materialExpressive,
        CalendarStyle.cupertinoGlass,
        CalendarStyle.minimal,
        CalendarStyle.pill,
        CalendarStyle.soft,
        CalendarStyle.neon,
        CalendarStyle.monochrome,
        CalendarStyle.aurora,
        CalendarStyle.sunset,
        CalendarStyle.midnight,
        CalendarStyle.paper,
        CalendarStyle.terminal,
        CalendarStyle.luxury,
        CalendarStyle.materialYou,
        CalendarStyle.cupertinoTinted,
      ]) {
        expect(
          CalendarStyleResolver.resolve(style, TargetPlatform.iOS),
          style,
        );
      }
    });
  });

  group('HorizontalCalendarThemeData', () {
    test('ships complete and visually distinct premium presets', () {
      final presets = [
        HorizontalCalendarThemeData.material3(),
        HorizontalCalendarThemeData.cupertino(),
        HorizontalCalendarThemeData.neutral(),
        HorizontalCalendarThemeData.glass(),
        HorizontalCalendarThemeData.editorial(),
        HorizontalCalendarThemeData.bold(),
        HorizontalCalendarThemeData.materialExpressive(),
        HorizontalCalendarThemeData.cupertinoGlass(),
        HorizontalCalendarThemeData.minimal(),
        HorizontalCalendarThemeData.pill(),
        HorizontalCalendarThemeData.soft(),
        HorizontalCalendarThemeData.neon(),
        HorizontalCalendarThemeData.monochrome(),
        HorizontalCalendarThemeData.aurora(),
        HorizontalCalendarThemeData.sunset(),
        HorizontalCalendarThemeData.midnight(),
        HorizontalCalendarThemeData.paper(),
        HorizontalCalendarThemeData.terminal(),
        HorizontalCalendarThemeData.luxury(),
        HorizontalCalendarThemeData.materialYou(),
        HorizontalCalendarThemeData.cupertinoTinted(),
      ];

      expect(presets.map((theme) => theme.dayBorderRadius).toSet().length,
          greaterThanOrEqualTo(4));
      expect(presets.map((theme) => theme.accentColor).toSet().length,
          greaterThanOrEqualTo(4));
      expect(presets.every((theme) => theme.motionDuration > Duration.zero),
          isTrue);
    });

    test('presets use platform-appropriate targets and distinct treatment', () {
      final material = HorizontalCalendarThemeData.material();
      final cupertino = HorizontalCalendarThemeData.cupertino();
      final neutral = HorizontalCalendarThemeData.neutral();

      expect(material.minimumInteractiveDimension, 48);
      expect(cupertino.minimumInteractiveDimension, 44);
      expect(material.dayBorderRadius, isNot(cupertino.dayBorderRadius));
      expect(material.motionCurve, isNot(cupertino.motionCurve));
      expect(neutral.dayBorderRadius, isNot(material.dayBorderRadius));
      expect(
        HorizontalCalendarThemeData.materialExpressive()
            .minimumInteractiveDimension,
        48,
      );
      expect(
        HorizontalCalendarThemeData.cupertinoGlass()
            .minimumInteractiveDimension,
        44,
      );
    });

    test('light, dark, and high-contrast presets meet text contrast AA', () {
      for (final theme in [
        HorizontalCalendarThemeData.material(),
        HorizontalCalendarThemeData.material(
          brightness: Brightness.dark,
        ),
        HorizontalCalendarThemeData.material(highContrast: true),
        HorizontalCalendarThemeData.cupertino(),
        HorizontalCalendarThemeData.cupertino(
          brightness: Brightness.dark,
        ),
        HorizontalCalendarThemeData.neutral(),
        HorizontalCalendarThemeData.materialExpressive(),
        HorizontalCalendarThemeData.materialExpressive(
          brightness: Brightness.dark,
        ),
        HorizontalCalendarThemeData.cupertinoGlass(),
        HorizontalCalendarThemeData.cupertinoGlass(
          brightness: Brightness.dark,
        ),
        HorizontalCalendarThemeData.minimal(),
        HorizontalCalendarThemeData.minimal(brightness: Brightness.dark),
        HorizontalCalendarThemeData.pill(),
        HorizontalCalendarThemeData.pill(brightness: Brightness.dark),
        HorizontalCalendarThemeData.soft(),
        HorizontalCalendarThemeData.soft(brightness: Brightness.dark),
        HorizontalCalendarThemeData.neon(),
        HorizontalCalendarThemeData.neon(brightness: Brightness.light),
        HorizontalCalendarThemeData.monochrome(),
        HorizontalCalendarThemeData.monochrome(
          brightness: Brightness.dark,
        ),
        HorizontalCalendarThemeData.aurora(),
        HorizontalCalendarThemeData.aurora(brightness: Brightness.dark),
        HorizontalCalendarThemeData.sunset(),
        HorizontalCalendarThemeData.sunset(brightness: Brightness.dark),
        HorizontalCalendarThemeData.midnight(),
        HorizontalCalendarThemeData.midnight(brightness: Brightness.dark),
        HorizontalCalendarThemeData.paper(),
        HorizontalCalendarThemeData.paper(brightness: Brightness.dark),
        HorizontalCalendarThemeData.terminal(),
        HorizontalCalendarThemeData.terminal(brightness: Brightness.dark),
        HorizontalCalendarThemeData.luxury(),
        HorizontalCalendarThemeData.luxury(brightness: Brightness.dark),
        HorizontalCalendarThemeData.materialYou(),
        HorizontalCalendarThemeData.materialYou(brightness: Brightness.dark),
        HorizontalCalendarThemeData.cupertinoTinted(),
        HorizontalCalendarThemeData.cupertinoTinted(
          brightness: Brightness.dark,
        ),
      ]) {
        expect(
          _contrast(theme.textColor, theme.backgroundColor),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(theme.onAccentColor, theme.accentColor),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('copyWith changes only supplied semantic tokens', () {
      final original = HorizontalCalendarThemeData.material();
      final changed = original.copyWith(
        accentColor: const Color(0xFF006E5B),
        dayBorderRadius: 99,
        motionDuration: const Duration(milliseconds: 1),
      );

      expect(changed.accentColor, const Color(0xFF006E5B));
      expect(changed.dayBorderRadius, 99);
      expect(changed.motionDuration, const Duration(milliseconds: 1));
      expect(changed.backgroundColor, original.backgroundColor);
      expect(changed.dayTextStyle, original.dayTextStyle);
    });

    test('lerp returns endpoints and interpolates colors and dimensions', () {
      final light = HorizontalCalendarThemeData.material();
      final dark = HorizontalCalendarThemeData.material(
        brightness: Brightness.dark,
      );

      expect(light.lerp(dark, 0), light);
      expect(light.lerp(dark, 1), dark);
      final middle = light.lerp(dark, .5);
      expect(
        middle.minimumInteractiveDimension,
        (light.minimumInteractiveDimension + dark.minimumInteractiveDimension) /
            2,
      );
      expect(
          middle.backgroundColor,
          Color.lerp(
            light.backgroundColor,
            dark.backgroundColor,
            .5,
          ));
    });

    testWidgets('works as a standard Flutter ThemeExtension', (tester) async {
      final calendarTheme = HorizontalCalendarThemeData.neutral();
      late HorizontalCalendarThemeData resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [calendarTheme]),
          home: Builder(
            builder: (context) {
              resolved =
                  Theme.of(context).extension<HorizontalCalendarThemeData>()!;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved, same(calendarTheme));
    });
  });
}

double _contrast(Color first, Color second) {
  final light = first.computeLuminance() > second.computeLuminance()
      ? first.computeLuminance()
      : second.computeLuminance();
  final dark = first.computeLuminance() > second.computeLuminance()
      ? second.computeLuminance()
      : first.computeLuminance();
  return (light + .05) / (dark + .05);
}
