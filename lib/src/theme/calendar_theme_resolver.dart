import 'package:flutter/material.dart';

import '../configuration/calendar_configuration.dart';
import 'horizontal_calendar_theme.dart';

/// Resolves inherited, explicit, adaptive, and density-aware calendar tokens.
abstract final class CalendarThemeResolver {
  /// Resolves one complete theme for [appearance] and [context].
  static HorizontalCalendarThemeData resolve(
    BuildContext context,
    CalendarAppearance appearance,
  ) {
    final explicit = appearance.theme;
    final inherited =
        Theme.of(context).extension<HorizontalCalendarThemeData>();
    final base = explicit ??
        inherited ??
        _preset(
          CalendarStyleResolver.resolve(
            appearance.style,
            Theme.of(context).platform,
          ),
          Theme.of(context).brightness,
          MediaQuery.highContrastOf(context),
        );
    return switch (appearance.density) {
      CalendarDensity.compact => base.copyWith(
          dayCellExtent: 48,
          daySpacing: 4,
          contentPadding: 8,
        ),
      CalendarDensity.comfortable => base,
      CalendarDensity.spacious => base.copyWith(
          dayCellExtent: 68,
          daySpacing: 12,
          contentPadding: 20,
        ),
    };
  }

  static HorizontalCalendarThemeData _preset(
    CalendarStyle style,
    Brightness brightness,
    bool highContrast,
  ) {
    return switch (style) {
      CalendarStyle.material => HorizontalCalendarThemeData.material3(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.cupertino => HorizontalCalendarThemeData.cupertino(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.neutral ||
      CalendarStyle.adaptive =>
        HorizontalCalendarThemeData.neutral(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.materialExpressive =>
        HorizontalCalendarThemeData.materialExpressive(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.glass => HorizontalCalendarThemeData.glass(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.editorial => HorizontalCalendarThemeData.editorial(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.bold => HorizontalCalendarThemeData.bold(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.cupertinoGlass =>
        HorizontalCalendarThemeData.cupertinoGlass(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.minimal => HorizontalCalendarThemeData.minimal(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.pill => HorizontalCalendarThemeData.pill(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.soft => HorizontalCalendarThemeData.soft(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.neon => HorizontalCalendarThemeData.neon(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.monochrome => HorizontalCalendarThemeData.monochrome(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.aurora => HorizontalCalendarThemeData.aurora(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.sunset => HorizontalCalendarThemeData.sunset(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.midnight => HorizontalCalendarThemeData.midnight(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.paper => HorizontalCalendarThemeData.paper(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.terminal => HorizontalCalendarThemeData.terminal(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.luxury => HorizontalCalendarThemeData.luxury(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.materialYou => HorizontalCalendarThemeData.materialYou(
          brightness: brightness,
          highContrast: highContrast,
        ),
      CalendarStyle.cupertinoTinted =>
        HorizontalCalendarThemeData.cupertinoTinted(
          brightness: brightness,
          highContrast: highContrast,
        ),
    };
  }
}
