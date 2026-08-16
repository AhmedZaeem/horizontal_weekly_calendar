import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

/// Repaints a built-in style family in one product's brand colours.
///
/// The built-in styles ship fixed palettes on purpose; an application that
/// already has a colour scheme overrides the semantic tokens it cares about
/// and keeps the rest of the preset's geometry.
HorizontalCalendarThemeData brandCalendarTheme(
  BuildContext context, {
  required Color accent,
  CalendarStyle style = CalendarStyle.material,
}) {
  final scheme = Theme.of(context).colorScheme;
  final base = CalendarThemeResolver.resolve(
    context,
    CalendarAppearance(style: style),
  );
  return base.copyWith(
    backgroundColor: scheme.surfaceContainerLow,
    surfaceColor: scheme.surfaceContainerLowest,
    elevatedSurfaceColor: scheme.surfaceContainer,
    textColor: scheme.onSurface,
    mutedTextColor: scheme.onSurfaceVariant,
    borderColor: scheme.outlineVariant,
    accentColor: accent,
    onAccentColor:
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
            ? Colors.white
            : Colors.black,
    todayColor: accent,
    focusColor: accent,
    eventColor: accent,
    disabledColor: scheme.onSurface.withValues(alpha: .34),
  );
}

/// Page chrome shared by every real-world example.
class ExampleScaffold extends StatelessWidget {
  const ExampleScaffold({
    super.key,
    required this.product,
    required this.title,
    required this.accent,
    required this.children,
    this.brightness = Brightness.light,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 32),
  });

  /// Name of the fictional product this screen belongs to.
  final String product;

  /// What the screen does inside that product.
  final String title;

  /// Brand colour the screen is built around.
  final Color accent;

  /// Builds page content beneath this screen's own theme.
  ///
  /// Content is built from a context inside the theme, so a screen never
  /// accidentally reads colours or text styles from the enclosing app.
  final List<Widget> Function(BuildContext context) children;

  /// Whether the screen presents a light or dark surface.
  final Brightness brightness;

  /// Optional app-bar action.
  final Widget? trailing;

  /// Scroll-view padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    );
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF0B0D14)
          : scheme.surfaceContainerLowest,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 4,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            actions: [
              if (trailing != null) trailing!,
              const SizedBox(width: 8)
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(padding: padding, children: children(context)),
          ),
        ),
      ),
    );
  }
}

/// A titled block that groups one calendar surface with its supporting copy.
class ExampleSection extends StatelessWidget {
  const ExampleSection({
    super.key,
    required this.title,
    required this.child,
    this.caption,
    this.trailing,
  });

  final String title;
  final String? caption;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// A soft card used for the supporting content beside a calendar.
class ExampleCard extends StatelessWidget {
  const ExampleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      // Clipped so a scrolling timeline never paints over the rounded corner.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .5)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// A compact list row for events, entries, and bookings.
class ExampleRow extends StatelessWidget {
  const ExampleRow({
    super.key,
    required this.accent,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  final Color accent;
  final String title;
  final String? subtitle;
  final String? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: icon == null
                ? Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: accent, shape: BoxShape.circle),
                  )
                : Icon(icon, size: 19, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty-state copy used when a selected date has nothing scheduled.
class ExampleEmpty extends StatelessWidget {
  const ExampleEmpty({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.event_available_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
