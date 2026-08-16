import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Visual convention used by v2 calendar widgets.
enum CalendarStyle {
  /// Resolves from the current target platform.
  adaptive,

  /// Material-oriented shape, target, typography, and motion.
  material,

  /// Cupertino-oriented shape, target, typography, and motion.
  cupertino,

  /// Platform-independent restrained presentation.
  neutral,

  /// Translucent rounded presentation for layered interfaces.
  glass,

  /// Typographic presentation with sharp editorial geometry.
  editorial,

  /// Saturated presentation with oversized energetic treatment.
  bold,

  /// Material 3 expressive geometry and energetic motion.
  materialExpressive,

  /// Layered translucent Apple-oriented presentation.
  cupertinoGlass,

  /// Quiet, low-chrome presentation for content-first applications.
  minimal,

  /// Rounded capsule presentation for compact mobile selectors.
  pill,

  /// Gentle tinted surfaces for wellness and lifestyle applications.
  soft,

  /// Dark luminous presentation for media, gaming, and live experiences.
  neon,

  /// Ink-and-paper presentation for focused and branded products.
  monochrome,

  /// Layered violet and cyan presentation for creative products.
  aurora,

  /// Warm coral and amber presentation for travel and lifestyle products.
  sunset,

  /// Deep blue night presentation for focus and media products.
  midnight,

  /// Warm tactile paper presentation for journals and reading products.
  paper,

  /// Monospaced green-screen presentation for developer tools.
  terminal,

  /// Restrained ink and gold presentation for premium products.
  luxury,

  /// Personalized Material color treatment with generous geometry.
  materialYou,

  /// Tinted Apple-oriented treatment with restrained depth.
  cupertinoTinted,
}

/// Resolves adaptive calendar styling without coupling widgets to a platform.
abstract final class CalendarStyleResolver {
  /// Resolves [style] for [platform]. Explicit styles pass through unchanged.
  static CalendarStyle resolve(CalendarStyle style, TargetPlatform platform) {
    if (style != CalendarStyle.adaptive) return style;
    return switch (platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CalendarStyle.cupertino,
      TargetPlatform.android ||
      TargetPlatform.fuchsia =>
        CalendarStyle.material,
      TargetPlatform.linux || TargetPlatform.windows => CalendarStyle.neutral,
    };
  }

  /// Whether [style] resolves to one of the Apple-oriented presentations.
  ///
  /// This is the canonical platform-family check used by adaptive controls.
  /// Keeping it here ensures new Cupertino variants inherit native behavior.
  static bool isCupertino(CalendarStyle style, TargetPlatform platform) {
    return switch (resolve(style, platform)) {
      CalendarStyle.cupertino ||
      CalendarStyle.cupertinoGlass ||
      CalendarStyle.cupertinoTinted =>
        true,
      _ => false,
    };
  }
}

/// Semantic visual tokens shared by every v2 calendar widget.
@immutable
class HorizontalCalendarThemeData
    extends ThemeExtension<HorizontalCalendarThemeData> {
  /// Creates a complete calendar theme.
  const HorizontalCalendarThemeData({
    required this.backgroundColor,
    required this.surfaceColor,
    required this.elevatedSurfaceColor,
    required this.textColor,
    required this.mutedTextColor,
    required this.borderColor,
    required this.accentColor,
    required this.onAccentColor,
    required this.todayColor,
    required this.disabledColor,
    required this.focusColor,
    required this.eventColor,
    required this.errorColor,
    required this.headerTextStyle,
    required this.weekdayTextStyle,
    required this.dayTextStyle,
    required this.eventTextStyle,
    required this.minimumInteractiveDimension,
    required this.dayCellExtent,
    required this.daySpacing,
    required this.contentPadding,
    required this.dayBorderRadius,
    required this.surfaceBorderRadius,
    required this.eventMarkerSize,
    required this.elevation,
    required this.motionDuration,
    required this.motionCurve,
  });

  /// Material 3 preset aligned with the shared indigo/cyan palette.
  factory HorizontalCalendarThemeData.material3({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final colors = _CalendarPalette.resolve(brightness, highContrast);
    return HorizontalCalendarThemeData(
      backgroundColor: colors.background,
      surfaceColor: colors.surface,
      elevatedSurfaceColor: colors.elevatedSurface,
      textColor: colors.text,
      mutedTextColor: colors.mutedText,
      borderColor: colors.border,
      accentColor: colors.accent,
      onAccentColor: colors.onAccent,
      todayColor: colors.today,
      disabledColor: colors.disabled,
      focusColor: colors.focus,
      eventColor: colors.event,
      errorColor: colors.error,
      headerTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      weekdayTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
      dayTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      eventTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
      minimumInteractiveDimension: 48,
      dayCellExtent: 56,
      daySpacing: 8,
      contentPadding: 16,
      dayBorderRadius: 16,
      surfaceBorderRadius: 20,
      eventMarkerSize: 6,
      elevation: 1,
      motionDuration: const Duration(milliseconds: 240),
      motionCurve: Curves.easeOutCubic,
    );
  }

  /// Alias for the Material 3 preset.
  factory HorizontalCalendarThemeData.material({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    return HorizontalCalendarThemeData.material3(
      brightness: brightness,
      highContrast: highContrast,
    );
  }

  /// Cupertino preset with Apple-sized targets and restrained motion.
  factory HorizontalCalendarThemeData.cupertino({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final colors = _CalendarPalette.resolve(brightness, highContrast);
    return HorizontalCalendarThemeData(
      backgroundColor: colors.background,
      surfaceColor: colors.surface,
      elevatedSurfaceColor: colors.elevatedSurface,
      textColor: colors.text,
      mutedTextColor: colors.mutedText,
      borderColor: colors.border,
      accentColor: colors.accent,
      onAccentColor: colors.onAccent,
      todayColor: colors.today,
      disabledColor: colors.disabled,
      focusColor: colors.focus,
      eventColor: colors.event,
      errorColor: colors.error,
      headerTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      weekdayTextStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: .2,
        height: 1.25,
      ),
      dayTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      eventTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      minimumInteractiveDimension: 44,
      dayCellExtent: 54,
      daySpacing: 8,
      contentPadding: 16,
      dayBorderRadius: 22,
      surfaceBorderRadius: 22,
      eventMarkerSize: 6,
      elevation: 0,
      motionDuration: const Duration(milliseconds: 280),
      motionCurve: Curves.easeInOutCubic,
    );
  }

  /// Neutral preset suitable for desktop, web, and branded design systems.
  factory HorizontalCalendarThemeData.neutral({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final colors = _CalendarPalette.resolve(brightness, highContrast);
    return HorizontalCalendarThemeData(
      backgroundColor: colors.background,
      surfaceColor: colors.surface,
      elevatedSurfaceColor: colors.elevatedSurface,
      textColor: colors.text,
      mutedTextColor: colors.mutedText,
      borderColor: colors.border,
      accentColor: colors.accent,
      onAccentColor: colors.onAccent,
      todayColor: colors.today,
      disabledColor: colors.disabled,
      focusColor: colors.focus,
      eventColor: colors.event,
      errorColor: colors.error,
      headerTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      weekdayTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      dayTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      eventTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
      minimumInteractiveDimension: 44,
      dayCellExtent: 56,
      daySpacing: 8,
      contentPadding: 16,
      dayBorderRadius: 12,
      surfaceBorderRadius: 16,
      eventMarkerSize: 6,
      elevation: 0,
      motionDuration: const Duration(milliseconds: 200),
      motionCurve: Curves.easeOut,
    );
  }

  /// Translucent, rounded preset for layered modern interfaces.
  factory HorizontalCalendarThemeData.glass({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.cupertino(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (highContrast) {
      return base.copyWith(dayBorderRadius: 28, surfaceBorderRadius: 30);
    }
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xE6182036) : const Color(0xE6F8FAFF),
      surfaceColor: dark ? const Color(0x99313C58) : const Color(0xB3FFFFFF),
      elevatedSurfaceColor:
          dark ? const Color(0xCC3B4664) : const Color(0xE6FFFFFF),
      borderColor: dark ? const Color(0x668FA4CC) : const Color(0x99FFFFFF),
      accentColor: dark ? const Color(0xFFA7C7FF) : const Color(0xFF3157D5),
      onAccentColor: dark ? const Color(0xFF10234E) : const Color(0xFFFFFFFF),
      eventColor: dark ? const Color(0xFF67E8F9) : const Color(0xFF087E8B),
      dayBorderRadius: 28,
      surfaceBorderRadius: 30,
      elevation: 1.5,
      motionDuration: const Duration(milliseconds: 320),
      motionCurve: Curves.easeOutQuart,
    );
  }

  /// High-contrast typographic preset with square editorial geometry.
  factory HorizontalCalendarThemeData.editorial({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.neutral(
      brightness: brightness,
      highContrast: highContrast,
    );
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF11100F) : const Color(0xFFFFFCF5),
      surfaceColor: dark ? const Color(0xFF1D1B19) : const Color(0xFFF7F0E3),
      textColor: dark ? const Color(0xFFFFF8ED) : const Color(0xFF17120D),
      mutedTextColor: dark ? const Color(0xFFD8CABA) : const Color(0xFF66594A),
      borderColor: dark ? const Color(0xFF5A5148) : const Color(0xFFB9A58C),
      accentColor: highContrast
          ? base.accentColor
          : dark
              ? const Color(0xFFFFB37A)
              : const Color(0xFF8A341A),
      onAccentColor: dark ? const Color(0xFF2A1206) : const Color(0xFFFFFFFF),
      eventColor: dark ? const Color(0xFF8BD3C7) : const Color(0xFF176B5B),
      headerTextStyle: base.headerTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -.4,
      ),
      weekdayTextStyle: base.weekdayTextStyle.copyWith(
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
      ),
      dayBorderRadius: 0,
      surfaceBorderRadius: 4,
      elevation: 0,
      motionDuration: const Duration(milliseconds: 180),
      motionCurve: Curves.easeOut,
    );
  }

  /// Energetic preset with saturated color and oversized day treatment.
  factory HorizontalCalendarThemeData.bold({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.material3(
      brightness: brightness,
      highContrast: highContrast,
    );
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF150C29) : const Color(0xFFFFF7FD),
      surfaceColor: dark ? const Color(0xFF24133F) : const Color(0xFFF7E8FF),
      accentColor: highContrast
          ? base.accentColor
          : dark
              ? const Color(0xFFFF9FF3)
              : const Color(0xFF7A1CAC),
      onAccentColor: dark ? const Color(0xFF32103B) : const Color(0xFFFFFFFF),
      todayColor: dark ? const Color(0xFF7DF9FF) : const Color(0xFF006B73),
      eventColor: dark ? const Color(0xFFFFD166) : const Color(0xFF9A5800),
      headerTextStyle: base.headerTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -.35,
      ),
      dayTextStyle: base.dayTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      dayCellExtent: 62,
      dayBorderRadius: 20,
      surfaceBorderRadius: 28,
      eventMarkerSize: 8,
      elevation: 2,
      motionDuration: const Duration(milliseconds: 260),
      motionCurve: Curves.easeOutBack,
    );
  }

  /// Material 3 expressive preset with larger type and asymmetric energy.
  factory HorizontalCalendarThemeData.materialExpressive({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.material3(
      brightness: brightness,
      highContrast: highContrast,
    );
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF15121C) : const Color(0xFFFFF7FF),
      surfaceColor: dark ? const Color(0xFF211D29) : const Color(0xFFF8EEFF),
      elevatedSurfaceColor:
          dark ? const Color(0xFF2C2536) : const Color(0xFFFFFFFF),
      accentColor: highContrast
          ? base.accentColor
          : dark
              ? const Color(0xFFD6B8FF)
              : const Color(0xFF6750A4),
      onAccentColor: dark ? const Color(0xFF251047) : Colors.white,
      eventColor: dark ? const Color(0xFFFFB1C8) : const Color(0xFF9B405D),
      headerTextStyle: base.headerTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -.5,
      ),
      dayTextStyle: base.dayTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      minimumInteractiveDimension: 48,
      dayCellExtent: 64,
      dayBorderRadius: 24,
      surfaceBorderRadius: 32,
      elevation: 1.5,
      motionDuration: const Duration(milliseconds: 320),
      motionCurve: Curves.easeOutBack,
    );
  }

  /// Translucent Cupertino preset for layered Apple-style interfaces.
  factory HorizontalCalendarThemeData.cupertinoGlass({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    return HorizontalCalendarThemeData.glass(
      brightness: brightness,
      highContrast: highContrast,
    ).copyWith(
      minimumInteractiveDimension: 44,
      dayCellExtent: 58,
      dayBorderRadius: 24,
      surfaceBorderRadius: 26,
      elevation: highContrast ? 0 : 1,
      motionDuration: const Duration(milliseconds: 300),
      motionCurve: Curves.easeInOutCubicEmphasized,
    );
  }

  /// Minimal preset with restrained borders and compact typography.
  factory HorizontalCalendarThemeData.minimal({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.neutral(
      brightness: brightness,
      highContrast: highContrast,
    );
    return base.copyWith(
      surfaceColor: base.backgroundColor,
      elevatedSurfaceColor: base.surfaceColor,
      borderColor: highContrast
          ? base.textColor
          : base.borderColor.withValues(alpha: .4),
      dayBorderRadius: 8,
      surfaceBorderRadius: 10,
      eventMarkerSize: 5,
      elevation: 0,
      motionDuration: const Duration(milliseconds: 140),
      motionCurve: Curves.easeOut,
    );
  }

  /// Capsule preset optimized for horizontal date pickers.
  factory HorizontalCalendarThemeData.pill({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.material3(
      brightness: brightness,
      highContrast: highContrast,
    );
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF101716) : const Color(0xFFF3FAF8),
      surfaceColor: dark ? const Color(0xFF192422) : Colors.white,
      accentColor: highContrast
          ? base.accentColor
          : dark
              ? const Color(0xFF79D7C5)
              : const Color(0xFF006B5D),
      onAccentColor: dark ? const Color(0xFF00382F) : Colors.white,
      eventColor: dark ? const Color(0xFFFFD166) : const Color(0xFF8B5A00),
      dayCellExtent: 58,
      dayBorderRadius: 999,
      surfaceBorderRadius: 999,
      elevation: 0,
      motionDuration: const Duration(milliseconds: 220),
      motionCurve: Curves.easeOutCubic,
    );
  }

  /// Soft tinted preset for wellness, family, and lifestyle products.
  factory HorizontalCalendarThemeData.soft({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.material3(
      brightness: brightness,
      highContrast: highContrast,
    );
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF17151B) : const Color(0xFFFFF8FB),
      surfaceColor: dark ? const Color(0xFF27222C) : const Color(0xFFFFEAF2),
      elevatedSurfaceColor:
          dark ? const Color(0xFF322A38) : const Color(0xFFFFFFFF),
      accentColor: highContrast
          ? base.accentColor
          : dark
              ? const Color(0xFFFFB1C8)
              : const Color(0xFF9B405D),
      onAccentColor: dark ? const Color(0xFF5E1130) : Colors.white,
      todayColor: dark ? const Color(0xFF9BD9D0) : const Color(0xFF236B62),
      eventColor: dark ? const Color(0xFFC8B8FF) : const Color(0xFF6552A3),
      dayBorderRadius: 20,
      surfaceBorderRadius: 28,
      elevation: .5,
      motionDuration: const Duration(milliseconds: 300),
      motionCurve: Curves.easeInOutCubic,
    );
  }

  /// Luminous dark-first preset for media and live-event applications.
  factory HorizontalCalendarThemeData.neon({
    Brightness brightness = Brightness.dark,
    bool highContrast = false,
  }) {
    if (highContrast) {
      return HorizontalCalendarThemeData.material3(
        brightness: brightness,
        highContrast: true,
      ).copyWith(dayBorderRadius: 12, surfaceBorderRadius: 16);
    }
    final dark = brightness == Brightness.dark;
    return HorizontalCalendarThemeData.material3(
      brightness: brightness,
    ).copyWith(
      backgroundColor: dark ? const Color(0xFF05070D) : const Color(0xFFF5F8FF),
      surfaceColor: dark ? const Color(0xFF0C1324) : const Color(0xFFE9F0FF),
      elevatedSurfaceColor:
          dark ? const Color(0xFF121E35) : const Color(0xFFFFFFFF),
      textColor: dark ? const Color(0xFFF4F7FF) : const Color(0xFF111827),
      mutedTextColor: dark ? const Color(0xFFB5C8EA) : const Color(0xFF42526B),
      borderColor: dark ? const Color(0xFF284B75) : const Color(0xFF9AB6D9),
      accentColor: dark ? const Color(0xFF45F0DF) : const Color(0xFF006B65),
      onAccentColor: dark ? const Color(0xFF00201D) : Colors.white,
      todayColor: dark ? const Color(0xFFFF5FD2) : const Color(0xFF9A146F),
      eventColor: dark ? const Color(0xFFFFD166) : const Color(0xFF8A5800),
      dayBorderRadius: 12,
      surfaceBorderRadius: 16,
      elevation: dark ? 2 : .5,
      motionDuration: const Duration(milliseconds: 260),
      motionCurve: Curves.easeOutExpo,
    );
  }

  /// Monochrome preset for editorial, luxury, and deeply branded products.
  factory HorizontalCalendarThemeData.monochrome({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final dark = brightness == Brightness.dark;
    return HorizontalCalendarThemeData.neutral(
      brightness: brightness,
      highContrast: highContrast,
    ).copyWith(
      backgroundColor: dark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      surfaceColor: dark ? const Color(0xFF171717) : Colors.white,
      elevatedSurfaceColor:
          dark ? const Color(0xFF242424) : const Color(0xFFF1F1F1),
      textColor: dark ? Colors.white : Colors.black,
      mutedTextColor: dark ? const Color(0xFFBDBDBD) : const Color(0xFF525252),
      borderColor: dark ? const Color(0xFF525252) : const Color(0xFFBDBDBD),
      accentColor: dark ? Colors.white : Colors.black,
      onAccentColor: dark ? Colors.black : Colors.white,
      todayColor: dark ? const Color(0xFFE0E0E0) : const Color(0xFF333333),
      eventColor: dark ? const Color(0xFFD4D4D4) : const Color(0xFF404040),
      dayBorderRadius: 4,
      surfaceBorderRadius: 6,
      elevation: 0,
      motionDuration: const Duration(milliseconds: 160),
      motionCurve: Curves.linearToEaseOut,
    );
  }

  /// Aurora preset with cool luminous color and layered rounded surfaces.
  factory HorizontalCalendarThemeData.aurora({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.glass(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (highContrast) return base;
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF071521) : const Color(0xFFF4FBFF),
      surfaceColor: dark ? const Color(0xFF10283A) : const Color(0xFFE9F7FF),
      elevatedSurfaceColor:
          dark ? const Color(0xFF18364B) : const Color(0xFFFFFFFF),
      textColor: dark ? const Color(0xFFF3FAFF) : const Color(0xFF102333),
      mutedTextColor: dark ? const Color(0xFFBED3E3) : const Color(0xFF475F70),
      borderColor: dark ? const Color(0xFF42677C) : const Color(0xFFA8C5D4),
      accentColor: dark ? const Color(0xFF79E7D7) : const Color(0xFF006B60),
      onAccentColor: dark ? const Color(0xFF00382F) : Colors.white,
      todayColor: dark ? const Color(0xFFD7B8FF) : const Color(0xFF62429A),
      eventColor: dark ? const Color(0xFFFFB3D8) : const Color(0xFF8F3B67),
      dayBorderRadius: 26,
      surfaceBorderRadius: 32,
      motionDuration: const Duration(milliseconds: 340),
      motionCurve: Curves.easeInOutCubicEmphasized,
    );
  }

  /// Sunset preset with warm coral, amber, and grounded ink colors.
  factory HorizontalCalendarThemeData.sunset({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.material3(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (highContrast) return base;
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF21110E) : const Color(0xFFFFF8F3),
      surfaceColor: dark ? const Color(0xFF341C18) : const Color(0xFFFFEDE2),
      elevatedSurfaceColor:
          dark ? const Color(0xFF452720) : const Color(0xFFFFFFFF),
      textColor: dark ? const Color(0xFFFFF4EE) : const Color(0xFF321611),
      mutedTextColor: dark ? const Color(0xFFE6C4B8) : const Color(0xFF70524A),
      borderColor: dark ? const Color(0xFF795044) : const Color(0xFFD6B1A4),
      accentColor: dark ? const Color(0xFFFFB59B) : const Color(0xFF8A2B00),
      onAccentColor: dark ? const Color(0xFF541500) : Colors.white,
      todayColor: dark ? const Color(0xFFFFD180) : const Color(0xFF7A4D00),
      eventColor: dark ? const Color(0xFFFFC4D6) : const Color(0xFF8F3052),
      dayBorderRadius: 18,
      surfaceBorderRadius: 24,
    );
  }

  /// Midnight preset with deep blue surfaces and crisp cool highlights.
  factory HorizontalCalendarThemeData.midnight({
    Brightness brightness = Brightness.dark,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.neon(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (highContrast) return base;
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF060A18) : const Color(0xFFF5F7FF),
      surfaceColor: dark ? const Color(0xFF101831) : const Color(0xFFE9EEFF),
      elevatedSurfaceColor:
          dark ? const Color(0xFF182344) : const Color(0xFFFFFFFF),
      textColor: dark ? const Color(0xFFF7F8FF) : const Color(0xFF151B31),
      mutedTextColor: dark ? const Color(0xFFC2C9E8) : const Color(0xFF4D5878),
      borderColor: dark ? const Color(0xFF3D4D7A) : const Color(0xFFAAB6D9),
      accentColor: dark ? const Color(0xFFAFC6FF) : const Color(0xFF304A94),
      onAccentColor: dark ? const Color(0xFF10265C) : Colors.white,
      todayColor: dark ? const Color(0xFFFFC4E8) : const Color(0xFF843F6A),
      eventColor: dark ? const Color(0xFF7BE4D3) : const Color(0xFF006B5F),
      dayBorderRadius: 14,
      surfaceBorderRadius: 20,
    );
  }

  /// Paper preset with warm surfaces and tactile editorial geometry.
  factory HorizontalCalendarThemeData.paper({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.editorial(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (highContrast) return base;
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF17130E) : const Color(0xFFFFFBEE),
      surfaceColor: dark ? const Color(0xFF241F17) : const Color(0xFFF6EED8),
      elevatedSurfaceColor:
          dark ? const Color(0xFF30291F) : const Color(0xFFFFFFFF),
      textColor: dark ? const Color(0xFFFFF8E8) : const Color(0xFF261D12),
      mutedTextColor: dark ? const Color(0xFFD6C9B1) : const Color(0xFF665844),
      borderColor: dark ? const Color(0xFF655946) : const Color(0xFFC5B694),
      accentColor: dark ? const Color(0xFFF4C88A) : const Color(0xFF704A16),
      onAccentColor: dark ? const Color(0xFF432B08) : Colors.white,
      todayColor: dark ? const Color(0xFF9ED7C7) : const Color(0xFF28695B),
      eventColor: dark ? const Color(0xFFD8B8F0) : const Color(0xFF6C4384),
      dayBorderRadius: 3,
      surfaceBorderRadius: 8,
    );
  }

  /// Terminal preset with monospaced typography and green-screen emphasis.
  factory HorizontalCalendarThemeData.terminal({
    Brightness brightness = Brightness.dark,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.monochrome(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (highContrast) return base;
    final dark = brightness == Brightness.dark;
    const mono = 'monospace';
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF061008) : const Color(0xFFF4FAF5),
      surfaceColor: dark ? const Color(0xFF0C1B10) : const Color(0xFFE5F2E8),
      elevatedSurfaceColor:
          dark ? const Color(0xFF132719) : const Color(0xFFFFFFFF),
      textColor: dark ? const Color(0xFFE9FFEC) : const Color(0xFF102A17),
      mutedTextColor: dark ? const Color(0xFFAFD6B6) : const Color(0xFF47654D),
      borderColor: dark ? const Color(0xFF356843) : const Color(0xFF9BBCA2),
      accentColor: dark ? const Color(0xFF76F28C) : const Color(0xFF176B2C),
      onAccentColor: dark ? const Color(0xFF00390D) : Colors.white,
      todayColor: dark ? const Color(0xFFFFD479) : const Color(0xFF745000),
      eventColor: dark ? const Color(0xFF8EDCFF) : const Color(0xFF16627D),
      headerTextStyle: base.headerTextStyle.copyWith(fontFamily: mono),
      weekdayTextStyle: base.weekdayTextStyle.copyWith(fontFamily: mono),
      dayTextStyle: base.dayTextStyle.copyWith(fontFamily: mono),
      eventTextStyle: base.eventTextStyle.copyWith(fontFamily: mono),
      dayBorderRadius: 2,
      surfaceBorderRadius: 4,
    );
  }

  /// Luxury preset with restrained ink, ivory, and accessible gold accents.
  factory HorizontalCalendarThemeData.luxury({
    Brightness brightness = Brightness.dark,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.editorial(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (highContrast) return base;
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF0D0C0A) : const Color(0xFFFFFCF5),
      surfaceColor: dark ? const Color(0xFF1B1813) : const Color(0xFFF5EDDB),
      elevatedSurfaceColor:
          dark ? const Color(0xFF272218) : const Color(0xFFFFFFFF),
      textColor: dark ? const Color(0xFFFFF9EA) : const Color(0xFF211B11),
      mutedTextColor: dark ? const Color(0xFFD5C8A9) : const Color(0xFF655A43),
      borderColor: dark ? const Color(0xFF66593D) : const Color(0xFFC3B183),
      accentColor: dark ? const Color(0xFFE8C878) : const Color(0xFF634A0B),
      onAccentColor: dark ? const Color(0xFF3A2A00) : Colors.white,
      todayColor: dark ? const Color(0xFFC9B3FF) : const Color(0xFF5F478B),
      eventColor: dark ? const Color(0xFF9ED7C7) : const Color(0xFF28695B),
      dayBorderRadius: 0,
      surfaceBorderRadius: 2,
      elevation: 0,
    );
  }

  /// Material You preset with personalized color energy and large geometry.
  factory HorizontalCalendarThemeData.materialYou({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.materialExpressive(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (highContrast) return base;
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF101510) : const Color(0xFFF6FBF2),
      surfaceColor: dark ? const Color(0xFF1C241B) : const Color(0xFFEAF4E4),
      elevatedSurfaceColor:
          dark ? const Color(0xFF273125) : const Color(0xFFFFFFFF),
      textColor: dark ? const Color(0xFFF4FBF0) : const Color(0xFF182117),
      mutedTextColor: dark ? const Color(0xFFC4D4BF) : const Color(0xFF52604E),
      borderColor: dark ? const Color(0xFF4D6348) : const Color(0xFFABBEA5),
      accentColor: dark ? const Color(0xFFB5D99F) : const Color(0xFF3E672C),
      onAccentColor: dark ? const Color(0xFF203A14) : Colors.white,
      todayColor: dark ? const Color(0xFFFFB2C8) : const Color(0xFF8B3E58),
      eventColor: dark ? const Color(0xFFC8B8FF) : const Color(0xFF5E4B94),
      dayBorderRadius: 28,
      surfaceBorderRadius: 36,
      minimumInteractiveDimension: 48,
    );
  }

  /// Cupertino tinted preset with Apple-sized controls and quiet color depth.
  factory HorizontalCalendarThemeData.cupertinoTinted({
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) {
    final base = HorizontalCalendarThemeData.cupertino(
      brightness: brightness,
      highContrast: highContrast,
    );
    if (highContrast) return base;
    final dark = brightness == Brightness.dark;
    return base.copyWith(
      backgroundColor: dark ? const Color(0xFF11131A) : const Color(0xFFF7F8FD),
      surfaceColor: dark ? const Color(0xFF20232D) : const Color(0xFFEFF1FA),
      elevatedSurfaceColor:
          dark ? const Color(0xFF2B2F3B) : const Color(0xFFFFFFFF),
      textColor: dark ? const Color(0xFFF7F7FA) : const Color(0xFF1C1C1E),
      mutedTextColor: dark ? const Color(0xFFC7C7CC) : const Color(0xFF5B5B63),
      borderColor: dark ? const Color(0xFF4B4F5C) : const Color(0xFFC5C7D0),
      accentColor: dark ? const Color(0xFFAEC6FF) : const Color(0xFF3B5BA9),
      onAccentColor: dark ? const Color(0xFF17316B) : Colors.white,
      todayColor: dark ? const Color(0xFFFFB2C8) : const Color(0xFF93405D),
      eventColor: dark ? const Color(0xFF79D7C5) : const Color(0xFF006B5D),
      minimumInteractiveDimension: 44,
      dayBorderRadius: 18,
      surfaceBorderRadius: 22,
    );
  }

  /// Calendar background color.
  final Color backgroundColor;

  /// Default day and control surface color.
  final Color surfaceColor;

  /// Raised card and event surface color.
  final Color elevatedSurfaceColor;

  /// Primary readable foreground color.
  final Color textColor;

  /// Secondary readable foreground color.
  final Color mutedTextColor;

  /// Dividers and outline color.
  final Color borderColor;

  /// Selected-date and primary-action color.
  final Color accentColor;

  /// Foreground drawn over [accentColor].
  final Color onAccentColor;

  /// Today indicator color.
  final Color todayColor;

  /// Disabled-date foreground color.
  final Color disabledColor;

  /// Keyboard focus indicator color.
  final Color focusColor;

  /// Default event marker color.
  final Color eventColor;

  /// Error-state color.
  final Color errorColor;

  /// Month/header typography.
  final TextStyle headerTextStyle;

  /// Weekday-label typography.
  final TextStyle weekdayTextStyle;

  /// Day-number typography.
  final TextStyle dayTextStyle;

  /// Event-label typography.
  final TextStyle eventTextStyle;

  /// Smallest width and height of an interactive calendar target.
  final double minimumInteractiveDimension;

  /// Preferred horizontal extent of one day cell.
  final double dayCellExtent;

  /// Gap between adjacent day cells.
  final double daySpacing;

  /// Padding around a calendar surface.
  final double contentPadding;

  /// Corner radius of a day cell.
  final double dayBorderRadius;

  /// Corner radius of the outer calendar surface.
  final double surfaceBorderRadius;

  /// Diameter or thickness of a compact event marker.
  final double eventMarkerSize;

  /// Resting calendar-surface elevation.
  final double elevation;

  /// Default page, selection, and fold animation duration.
  final Duration motionDuration;

  /// Default page, selection, and fold animation curve.
  final Curve motionCurve;

  @override
  HorizontalCalendarThemeData copyWith({
    Color? backgroundColor,
    Color? surfaceColor,
    Color? elevatedSurfaceColor,
    Color? textColor,
    Color? mutedTextColor,
    Color? borderColor,
    Color? accentColor,
    Color? onAccentColor,
    Color? todayColor,
    Color? disabledColor,
    Color? focusColor,
    Color? eventColor,
    Color? errorColor,
    TextStyle? headerTextStyle,
    TextStyle? weekdayTextStyle,
    TextStyle? dayTextStyle,
    TextStyle? eventTextStyle,
    double? minimumInteractiveDimension,
    double? dayCellExtent,
    double? daySpacing,
    double? contentPadding,
    double? dayBorderRadius,
    double? surfaceBorderRadius,
    double? eventMarkerSize,
    double? elevation,
    Duration? motionDuration,
    Curve? motionCurve,
  }) {
    return HorizontalCalendarThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      elevatedSurfaceColor: elevatedSurfaceColor ?? this.elevatedSurfaceColor,
      textColor: textColor ?? this.textColor,
      mutedTextColor: mutedTextColor ?? this.mutedTextColor,
      borderColor: borderColor ?? this.borderColor,
      accentColor: accentColor ?? this.accentColor,
      onAccentColor: onAccentColor ?? this.onAccentColor,
      todayColor: todayColor ?? this.todayColor,
      disabledColor: disabledColor ?? this.disabledColor,
      focusColor: focusColor ?? this.focusColor,
      eventColor: eventColor ?? this.eventColor,
      errorColor: errorColor ?? this.errorColor,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
      dayTextStyle: dayTextStyle ?? this.dayTextStyle,
      eventTextStyle: eventTextStyle ?? this.eventTextStyle,
      minimumInteractiveDimension:
          minimumInteractiveDimension ?? this.minimumInteractiveDimension,
      dayCellExtent: dayCellExtent ?? this.dayCellExtent,
      daySpacing: daySpacing ?? this.daySpacing,
      contentPadding: contentPadding ?? this.contentPadding,
      dayBorderRadius: dayBorderRadius ?? this.dayBorderRadius,
      surfaceBorderRadius: surfaceBorderRadius ?? this.surfaceBorderRadius,
      eventMarkerSize: eventMarkerSize ?? this.eventMarkerSize,
      elevation: elevation ?? this.elevation,
      motionDuration: motionDuration ?? this.motionDuration,
      motionCurve: motionCurve ?? this.motionCurve,
    );
  }

  @override
  HorizontalCalendarThemeData lerp(
    covariant HorizontalCalendarThemeData? other,
    double t,
  ) {
    if (other == null || t == 0) return this;
    if (t == 1) return other;
    return HorizontalCalendarThemeData(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      elevatedSurfaceColor:
          Color.lerp(elevatedSurfaceColor, other.elevatedSurfaceColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      mutedTextColor: Color.lerp(mutedTextColor, other.mutedTextColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      onAccentColor: Color.lerp(onAccentColor, other.onAccentColor, t)!,
      todayColor: Color.lerp(todayColor, other.todayColor, t)!,
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t)!,
      focusColor: Color.lerp(focusColor, other.focusColor, t)!,
      eventColor: Color.lerp(eventColor, other.eventColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      headerTextStyle: TextStyle.lerp(
        headerTextStyle,
        other.headerTextStyle,
        t,
      )!,
      weekdayTextStyle: TextStyle.lerp(
        weekdayTextStyle,
        other.weekdayTextStyle,
        t,
      )!,
      dayTextStyle: TextStyle.lerp(dayTextStyle, other.dayTextStyle, t)!,
      eventTextStyle: TextStyle.lerp(eventTextStyle, other.eventTextStyle, t)!,
      minimumInteractiveDimension: lerpDouble(
        minimumInteractiveDimension,
        other.minimumInteractiveDimension,
        t,
      )!,
      dayCellExtent: lerpDouble(dayCellExtent, other.dayCellExtent, t)!,
      daySpacing: lerpDouble(daySpacing, other.daySpacing, t)!,
      contentPadding: lerpDouble(contentPadding, other.contentPadding, t)!,
      dayBorderRadius: lerpDouble(dayBorderRadius, other.dayBorderRadius, t)!,
      surfaceBorderRadius:
          lerpDouble(surfaceBorderRadius, other.surfaceBorderRadius, t)!,
      eventMarkerSize: lerpDouble(eventMarkerSize, other.eventMarkerSize, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      motionDuration: Duration(
        microseconds: lerpDouble(
          motionDuration.inMicroseconds,
          other.motionDuration.inMicroseconds,
          t,
        )!
            .round(),
      ),
      motionCurve: t < .5 ? motionCurve : other.motionCurve,
    );
  }
}

@immutable
class _CalendarPalette {
  const _CalendarPalette({
    required this.background,
    required this.surface,
    required this.elevatedSurface,
    required this.text,
    required this.mutedText,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.today,
    required this.disabled,
    required this.focus,
    required this.event,
    required this.error,
  });

  factory _CalendarPalette.resolve(Brightness brightness, bool highContrast) {
    if (highContrast) {
      return brightness == Brightness.dark
          ? const _CalendarPalette(
              background: Color(0xFF000000),
              surface: Color(0xFF000000),
              elevatedSurface: Color(0xFF111111),
              text: Color(0xFFFFFFFF),
              mutedText: Color(0xFFE5E7EB),
              border: Color(0xFFFFFFFF),
              accent: Color(0xFFFFFFFF),
              onAccent: Color(0xFF000000),
              today: Color(0xFF67E8F9),
              disabled: Color(0xFF9CA3AF),
              focus: Color(0xFFFFFF00),
              event: Color(0xFF67E8F9),
              error: Color(0xFFFF6B6B),
            )
          : const _CalendarPalette(
              background: Color(0xFFFFFFFF),
              surface: Color(0xFFFFFFFF),
              elevatedSurface: Color(0xFFF8FAFC),
              text: Color(0xFF000000),
              mutedText: Color(0xFF374151),
              border: Color(0xFF000000),
              accent: Color(0xFF000000),
              onAccent: Color(0xFFFFFFFF),
              today: Color(0xFF004D66),
              disabled: Color(0xFF6B7280),
              focus: Color(0xFF7C2D12),
              event: Color(0xFF005A72),
              error: Color(0xFFB91C1C),
            );
    }
    return brightness == Brightness.dark
        ? const _CalendarPalette(
            background: Color(0xFF0B1020),
            surface: Color(0xFF111827),
            elevatedSurface: Color(0xFF1F2937),
            text: Color(0xFFF8FAFC),
            mutedText: Color(0xFFCBD5E1),
            border: Color(0xFF334155),
            accent: Color(0xFFC7D2FE),
            onAccent: Color(0xFF1E1B4B),
            today: Color(0xFF67E8F9),
            disabled: Color(0xFF64748B),
            focus: Color(0xFFA5B4FC),
            event: Color(0xFF22D3EE),
            error: Color(0xFFFCA5A5),
          )
        : const _CalendarPalette(
            background: Color(0xFFFFFFFF),
            surface: Color(0xFFF8FAFC),
            elevatedSurface: Color(0xFFFFFFFF),
            text: Color(0xFF0F172A),
            mutedText: Color(0xFF475569),
            border: Color(0xFFE2E8F0),
            accent: Color(0xFF4338CA),
            onAccent: Color(0xFFFFFFFF),
            today: Color(0xFF0E7490),
            disabled: Color(0xFF94A3B8),
            focus: Color(0xFF4F46E5),
            event: Color(0xFF0891B2),
            error: Color(0xFFB91C1C),
          );
  }

  final Color background;
  final Color surface;
  final Color elevatedSurface;
  final Color text;
  final Color mutedText;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color today;
  final Color disabled;
  final Color focus;
  final Color event;
  final Color error;
}
