import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configuration/calendar_configuration.dart';
import '../domain/calendar_date_math.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';

/// Responsive presentation for [CalendarInsightsDashboard].
enum CalendarInsightsDesign {
  /// Elevated metric cards with a strong summary hierarchy.
  cards,

  /// Dense multi-metric dashboard.
  dashboard,

  /// Single-line compact metrics.
  compact,

  /// Translucent layered cards.
  glass,

  /// Typographic report-style presentation.
  editorial,

  /// Low-chrome content-first presentation.
  minimal,
}

/// Direction communicated by a calendar insight metric.
enum CalendarInsightTrend {
  /// Metric is increasing.
  up,

  /// Metric is decreasing.
  down,

  /// Metric is stable.
  steady,
}

/// Immutable typed metric displayed by [CalendarInsightsDashboard].
@immutable
class CalendarInsightMetric<T> {
  /// Creates an insight metric.
  CalendarInsightMetric({
    required this.id,
    required this.label,
    required this.value,
    this.supportingText,
    this.semanticValue,
    this.trend,
    this.progress,
    this.icon,
    this.accentColor,
    this.data,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'Must not be empty.');
    if (label.isEmpty) {
      throw ArgumentError.value(label, 'label', 'Must not be empty.');
    }
  }

  /// Stable metric identity.
  final String id;

  /// Human-readable metric label.
  final String label;

  /// Already-formatted value.
  final String value;

  /// Optional comparison or explanatory text.
  final String? supportingText;

  /// Optional accessibility-specific value.
  final String? semanticValue;

  /// Optional trend direction.
  final CalendarInsightTrend? trend;

  /// Optional progress, normalized safely during painting.
  final double? progress;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional metric-specific accent.
  final Color? accentColor;

  /// Original application payload.
  final T? data;
}

/// Builds one complete custom insight metric.
typedef CalendarInsightMetricBuilder<T> = Widget Function(
  BuildContext context,
  CalendarInsightMetric<T> metric,
);

/// Adaptive dashboard for schedule, habit, and availability insights.
class CalendarInsightsDashboard<T> extends StatelessWidget {
  /// Creates a responsive insight dashboard.
  const CalendarInsightsDashboard({
    super.key,
    required this.metrics,
    this.title,
    this.subtitle,
    this.design = CalendarInsightsDesign.dashboard,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.onMetricTap,
    this.metricBuilder,
    this.footer,
    this.minimumMetricWidth = 132,
    this.maximumColumns = 4,
    this.spacing = 10,
    this.padding = const EdgeInsets.all(4),
  })  : assert(minimumMetricWidth >= 96),
        assert(maximumColumns >= 1 && maximumColumns <= 8),
        assert(spacing >= 0);

  /// Typed metric source.
  final List<CalendarInsightMetric<T>> metrics;

  /// Optional dashboard headline.
  final String? title;

  /// Optional dashboard supporting copy.
  final String? subtitle;

  /// Built-in metric presentation.
  final CalendarInsightsDesign design;

  /// Shared appearance tokens.
  final CalendarAppearance appearance;

  /// Reports the original activated metric.
  final ValueChanged<CalendarInsightMetric<T>>? onMetricTap;

  /// Optional complete metric replacement.
  final CalendarInsightMetricBuilder<T>? metricBuilder;

  /// Optional dashboard content below the metric grid.
  final Widget? footer;

  /// Smallest automatic metric width.
  final double minimumMetricWidth;

  /// Largest automatic column count.
  final int maximumColumns;

  /// Gap between metric cards.
  final double spacing;

  /// Outer dashboard padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(builder: (context, constraints) {
        final resolvedPadding = padding.resolve(Directionality.of(context));
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : minimumMetricWidth * 2 + spacing + resolvedPadding.horizontal;
        final contentWidth = math.max(
          1.0,
          width - resolvedPadding.horizontal,
        );
        final textScale =
            MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
        final preferred = design == CalendarInsightsDesign.compact
            ? minimumMetricWidth * .82
            : minimumMetricWidth * textScale;
        final columns = math
            .max(
              1,
              ((contentWidth + spacing) / (preferred + spacing)).floor(),
            )
            .clamp(1, maximumColumns);
        final itemWidth = (contentWidth - spacing * (columns - 1)) / columns;
        return Padding(
          padding: resolvedPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || subtitle != null) ...[
                if (title != null)
                  Text(
                    title!,
                    style:
                        theme.headerTextStyle.copyWith(color: theme.textColor),
                  ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.eventTextStyle
                        .copyWith(color: theme.mutedTextColor),
                  ),
                SizedBox(height: spacing),
              ],
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final metric in metrics)
                    SizedBox(
                      width: itemWidth,
                      child: Semantics(
                        label: metric.label,
                        value: metric.semanticValue ?? metric.value,
                        button: onMetricTap != null,
                        child: InkWell(
                          key: ValueKey('calendar-insight-${metric.id}'),
                          borderRadius:
                              BorderRadius.circular(theme.dayBorderRadius),
                          onTap: onMetricTap == null
                              ? null
                              : () => onMetricTap!(metric),
                          child: metricBuilder?.call(context, metric) ??
                              _CalendarInsightCard(
                                metric: metric,
                                design: design,
                                theme: theme,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
              if (footer != null) ...[
                SizedBox(height: spacing),
                footer!,
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _CalendarInsightCard<T> extends StatelessWidget {
  const _CalendarInsightCard({
    required this.metric,
    required this.design,
    required this.theme,
  });

  final CalendarInsightMetric<T> metric;
  final CalendarInsightsDesign design;
  final HorizontalCalendarThemeData theme;

  @override
  Widget build(BuildContext context) {
    final accent = metric.accentColor ?? theme.accentColor;
    final rawProgress = metric.progress;
    final progress = rawProgress == null || !rawProgress.isFinite
        ? null
        : rawProgress.clamp(0, 1).toDouble();
    final transparent = design == CalendarInsightsDesign.minimal ||
        design == CalendarInsightsDesign.editorial;
    final background = design == CalendarInsightsDesign.glass
        ? theme.elevatedSurfaceColor.withValues(alpha: .62)
        : transparent
            ? Colors.transparent
            : theme.surfaceColor;
    final compact = design == CalendarInsightsDesign.compact;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(
          design == CalendarInsightsDesign.editorial
              ? 2
              : theme.dayBorderRadius,
        ),
        border: Border.all(
          color: design == CalendarInsightsDesign.editorial
              ? accent
              : transparent
                  ? Colors.transparent
                  : theme.borderColor,
          width: design == CalendarInsightsDesign.editorial ? 0 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 9 : 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (metric.icon != null) ...[
                  Icon(metric.icon, size: compact ? 15 : 18, color: accent),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.eventTextStyle.copyWith(
                      color: theme.mutedTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (metric.trend != null)
                  Icon(
                    switch (metric.trend!) {
                      CalendarInsightTrend.up => Icons.trending_up_rounded,
                      CalendarInsightTrend.down => Icons.trending_down_rounded,
                      CalendarInsightTrend.steady =>
                        Icons.trending_flat_rounded,
                    },
                    size: 17,
                    color: accent,
                  ),
              ],
            ),
            SizedBox(height: compact ? 5 : 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                metric.value,
                style: theme.headerTextStyle.copyWith(
                  color: theme.textColor,
                  fontSize: compact ? 22 : 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (metric.supportingText != null)
              Text(
                metric.supportingText!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    theme.eventTextStyle.copyWith(color: theme.mutedTextColor),
              ),
            if (progress != null) ...[
              const SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: compact ? 4 : 6,
                  color: accent,
                  backgroundColor: theme.borderColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Built-in geometry for heatmap intensity marks.
enum CalendarHeatmapDesign {
  /// Rounded rectangular cells.
  block,

  /// Circular intensity cells.
  circle,

  /// Capsule-shaped cells.
  pill,

  /// Circular outlines whose color communicates intensity.
  ring,

  /// Bottom-aligned fill bars.
  bar,

  /// Rotated square marks.
  diamond,
}

/// Placement of the built-in compact date label.
enum CalendarHeatmapLabelPosition {
  /// Centers the label over the intensity mark.
  inside,

  /// Places the label beneath the intensity mark.
  below,

  /// Hides the visual label while retaining semantics.
  hidden,
}

/// Immutable visual configuration for [CalendarHeatmapStrip].
@immutable
class CalendarHeatmapStyle {
  /// Creates heatmap visual configuration.
  const CalendarHeatmapStyle({
    this.colors,
    this.levels = 5,
    this.cellExtent = 48,
    this.cellSpacing = 6,
    this.borderRadius = 12,
    this.showLabels = true,
    this.design = CalendarHeatmapDesign.block,
    this.emptyColor,
    this.borderColor,
    this.selectedColor,
    this.borderWidth = 1,
    this.animate = false,
    this.showPercentage = false,
    this.labelPosition = CalendarHeatmapLabelPosition.inside,
  })  : assert(levels >= 2 && levels <= 9),
        assert(cellExtent >= 32 && cellExtent <= 10000),
        assert(cellSpacing >= 0 && cellSpacing <= 1000),
        assert(borderRadius >= 0 && borderRadius <= 10000),
        assert(borderWidth >= 0 && borderWidth <= 100),
        assert(colors == null || colors.length >= 1);

  /// Optional low-to-high color palette.
  final List<Color>? colors;

  /// Number of generated intensity levels when [colors] is omitted.
  final int levels;

  /// Width of one heatmap cell.
  final double cellExtent;

  /// Gap between adjacent cells.
  final double cellSpacing;

  /// Cell corner radius.
  final double borderRadius;

  /// Whether compact weekday/day labels are visible.
  final bool showLabels;

  /// Geometry used by the built-in cell painter.
  final CalendarHeatmapDesign design;

  /// Fill used for zero-intensity dates.
  final Color? emptyColor;

  /// Cell outline override.
  final Color? borderColor;

  /// Outline used by the controlled selected date.
  final Color? selectedColor;

  /// Width of built-in cell outlines.
  final double borderWidth;

  /// Whether intensity and selection changes animate.
  final bool animate;

  /// Whether built-in labels include the resolved percentage.
  final bool showPercentage;

  /// Visual date-label placement.
  final CalendarHeatmapLabelPosition labelPosition;
}

/// Complete immutable state for one heatmap date.
@immutable
class CalendarHeatmapCellState {
  /// Creates heatmap cell state.
  const CalendarHeatmapCellState({
    required this.date,
    required this.intensity,
    required this.level,
    required this.color,
    required this.semanticLabel,
    this.isSelected = false,
  });

  /// Normalized civil date.
  final DateTime date;

  /// Finite intensity clamped from zero through one.
  final double intensity;

  /// Resolved zero-based palette level.
  final int level;

  /// Resolved visual color.
  final Color color;

  /// Complete localized accessibility label.
  final String semanticLabel;

  /// Whether this date matches the controlled strip selection.
  final bool isSelected;
}

/// Builds one complete custom heatmap cell.
typedef CalendarHeatmapCellBuilder = Widget Function(
  BuildContext context,
  CalendarHeatmapCellState state,
);

/// Horizontal intensity visualization for activity, finance, and habit data.
class CalendarHeatmapStrip extends StatelessWidget {
  /// Creates a heatmap containing [dayCount] contiguous dates.
  const CalendarHeatmapStrip({
    super.key,
    required this.startDate,
    required this.dayCount,
    this.values = const {},
    this.selectedDate,
    this.onDateTap,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.style = const CalendarHeatmapStyle(),
    this.cellBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
  }) : assert(dayCount >= 1 && dayCount <= 366);

  /// First visible civil date.
  final DateTime startDate;

  /// Number of contiguous dates, from 1 through 366.
  final int dayCount;

  /// Sparse per-date intensity values; missing dates resolve to zero.
  final Map<DateTime, double> values;

  /// Optional controlled selected date.
  final DateTime? selectedDate;

  /// Optional date activation callback.
  final ValueChanged<DateTime>? onDateTap;

  /// Shared style and theme configuration.
  final CalendarAppearance appearance;

  /// Heatmap-specific geometry and colors.
  final CalendarHeatmapStyle style;

  /// Optional complete cell replacement.
  final CalendarHeatmapCellBuilder? cellBuilder;

  /// Outer horizontal padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final normalizedValues = <int, double>{
      for (final entry in values.entries)
        _civilKey(entry.key): _normalizeIntensity(entry.value),
    };
    final palette = _palette(theme);
    final dates = CalendarDateMath.days(startDate, dayCount);
    final textScale =
        MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0).toDouble();
    final height = style.showLabels ? 54 + 22 * textScale : 50.0;

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: height,
        child: ListView.separated(
          padding: padding,
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, __) => SizedBox(width: style.cellSpacing),
          itemBuilder: (context, index) {
            final date = dates[index];
            final intensity = normalizedValues[_civilKey(date)] ?? 0;
            final level = intensity == 0
                ? 0
                : (intensity * (palette.length - 1))
                    .ceil()
                    .clamp(
                      1,
                      palette.length - 1,
                    )
                    .toInt();
            final percentage = (intensity * 100).round();
            final semanticLabel =
                '${DateFormat.yMMMMEEEEd(locale).format(date)}, '
                '$percentage% intensity';
            final state = CalendarHeatmapCellState(
              date: date,
              intensity: intensity,
              level: level,
              color: palette[level],
              semanticLabel: semanticLabel,
              isSelected: selectedDate != null &&
                  CalendarDateMath.isSameDay(date, selectedDate!),
            );
            final identifier = _identifier('calendar-heatmap-day', date);
            return Semantics(
              identifier: identifier,
              label: semanticLabel,
              selected: state.isSelected,
              button: onDateTap != null,
              child: SizedBox(
                key: ValueKey(identifier),
                width: style.cellExtent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(style.borderRadius),
                  onTap: onDateTap == null ? null : () => onDateTap!(date),
                  child: cellBuilder?.call(context, state) ??
                      _DefaultHeatmapCell(
                        state: state,
                        theme: theme,
                        style: style,
                        locale: locale,
                      ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Color> _palette(HorizontalCalendarThemeData theme) {
    final supplied = style.colors;
    if (supplied != null) {
      if (supplied.length == 1) {
        return [style.emptyColor ?? theme.surfaceColor, supplied.single];
      }
      return [
        style.emptyColor ?? supplied.first,
        ...supplied.skip(1),
      ];
    }
    return List<Color>.generate(
      style.levels,
      (index) => Color.lerp(
        style.emptyColor ?? theme.surfaceColor,
        theme.accentColor,
        index / (style.levels - 1),
      )!,
      growable: false,
    );
  }
}

class _DefaultHeatmapCell extends StatelessWidget {
  const _DefaultHeatmapCell({
    required this.state,
    required this.theme,
    required this.style,
    required this.locale,
  });

  final CalendarHeatmapCellState state;
  final HorizontalCalendarThemeData theme;
  final CalendarHeatmapStyle style;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    final foreground = style.design == CalendarHeatmapDesign.ring
        ? theme.textColor
        : state.intensity >= .55
            ? theme.onAccentColor
            : theme.textColor;
    final label = _label(foreground);
    final mark = _mark(context);
    if (!style.showLabels ||
        style.labelPosition == CalendarHeatmapLabelPosition.hidden) {
      return mark;
    }
    if (style.labelPosition == CalendarHeatmapLabelPosition.below) {
      return Column(
        children: [
          Expanded(child: mark),
          SizedBox(height: 23, child: label),
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [mark, label],
    );
  }

  Widget _mark(BuildContext context) {
    final duration = style.animate && !MediaQuery.disableAnimationsOf(context)
        ? const Duration(milliseconds: 260)
        : Duration.zero;
    final borderColor = state.isSelected
        ? style.selectedColor ?? theme.focusColor
        : style.borderColor ?? theme.borderColor.withValues(alpha: .6);
    final shape = switch (style.design) {
      CalendarHeatmapDesign.circle ||
      CalendarHeatmapDesign.ring =>
        BoxShape.circle,
      _ => BoxShape.rectangle,
    };
    final radius = switch (style.design) {
      CalendarHeatmapDesign.pill => BorderRadius.circular(999),
      CalendarHeatmapDesign.block ||
      CalendarHeatmapDesign.bar =>
        BorderRadius.circular(style.borderRadius),
      CalendarHeatmapDesign.diamond ||
      CalendarHeatmapDesign.circle ||
      CalendarHeatmapDesign.ring =>
        BorderRadius.zero,
    };
    Widget body;
    if (style.design == CalendarHeatmapDesign.bar) {
      body = AnimatedContainer(
        duration: duration,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: style.emptyColor ?? theme.surfaceColor,
          borderRadius: radius,
          border: Border.all(color: borderColor, width: style.borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedFractionallySizedBox(
          duration: duration,
          widthFactor: 1,
          heightFactor: state.intensity,
          alignment: Alignment.bottomCenter,
          child: ColoredBox(color: state.color),
        ),
      );
    } else {
      body = AnimatedContainer(
        duration: duration,
        curve: Curves.easeOutCubic,
        margin: style.design == CalendarHeatmapDesign.diamond
            ? const EdgeInsets.all(10)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: style.design == CalendarHeatmapDesign.ring
              ? Colors.transparent
              : state.color,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? radius : null,
          border: Border.all(
            color: style.design == CalendarHeatmapDesign.ring
                ? state.color
                : borderColor,
            width: style.design == CalendarHeatmapDesign.ring
                ? math.max(3, style.borderWidth)
                : style.borderWidth,
          ),
        ),
      );
    }
    return style.design == CalendarHeatmapDesign.diamond
        ? Transform.rotate(angle: math.pi / 4, child: body)
        : body;
  }

  Widget _label(Color foreground) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat.E(locale).format(state.date),
              maxLines: 1,
              style: theme.weekdayTextStyle.copyWith(color: foreground),
            ),
            Text(
              style.showPercentage
                  ? '${(state.intensity * 100).round()}%'
                  : '${state.date.day}',
              maxLines: 1,
              style: theme.dayTextStyle.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lazy week-column heatmap for contribution, activity, and habit histories.
class CalendarContributionHeatmap extends StatelessWidget {
  /// Creates a contribution grid containing contiguous civil dates.
  const CalendarContributionHeatmap({
    super.key,
    required this.startDate,
    required this.dayCount,
    this.values = const {},
    this.selectedDate,
    this.onDateTap,
    this.firstDayOfWeek = DateTime.monday,
    this.showWeekdayLabels = true,
    this.weekExtent = 40,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.style = const CalendarHeatmapStyle(
      cellExtent: 32,
      cellSpacing: 4,
      showLabels: false,
    ),
    this.cellBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
  })  : assert(dayCount >= 1 && dayCount <= 3660),
        assert(firstDayOfWeek >= DateTime.monday &&
            firstDayOfWeek <= DateTime.sunday),
        assert(weekExtent >= 32 && weekExtent <= 10000);

  /// First represented civil date.
  final DateTime startDate;

  /// Number of contiguous represented dates.
  final int dayCount;

  /// Sparse intensity values keyed by civil date.
  final Map<DateTime, double> values;

  /// Optional controlled selected date.
  final DateTime? selectedDate;

  /// Reports activation of a represented date.
  final ValueChanged<DateTime>? onDateTap;

  /// Weekday used by the first grid row.
  final int firstDayOfWeek;

  /// Whether localized weekday labels appear beside the rows.
  final bool showWeekdayLabels;

  /// Scroll extent reserved for one lazy week column.
  final double weekExtent;

  /// Shared style and theme configuration.
  final CalendarAppearance appearance;

  /// Heatmap cell geometry and color treatment.
  final CalendarHeatmapStyle style;

  /// Optional complete cell replacement.
  final CalendarHeatmapCellBuilder? cellBuilder;

  /// Outer padding on the chronological scroll axis.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final start = CalendarDateMath.dateOnly(startDate);
    final leading = (start.weekday - firstDayOfWeek + 7) % 7;
    final weekCount = ((leading + dayCount) / 7).ceil();
    final normalizedValues = <int, double>{
      for (final entry in values.entries)
        _civilKey(entry.key): _normalizeIntensity(entry.value),
    };
    final palette = _heatmapPalette(theme, style);

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : style.cellExtent * 7 + style.cellSpacing * 6;
        final cellExtent = math.min(
          style.cellExtent,
          math.max(
            14.0,
            (availableHeight - style.cellSpacing * 6) / 7,
          ),
        );
        final weekdayWidth = showWeekdayLabels ? 30.0 : 0.0;
        return SizedBox(
          height: availableHeight,
          child: Row(
            children: [
              if (showWeekdayLabels)
                SizedBox(
                  width: weekdayWidth,
                  child: Column(
                    children: [
                      for (var row = 0; row < 7; row += 1)
                        SizedBox(
                          height:
                              cellExtent + (row == 6 ? 0 : style.cellSpacing),
                          child: Center(
                            child: Text(
                              DateFormat.E(locale).format(
                                DateTime(
                                    2026,
                                    1,
                                    5 +
                                        ((firstDayOfWeek -
                                                DateTime.monday +
                                                row) %
                                            7)),
                              ),
                              maxLines: 1,
                              style: theme.eventTextStyle.copyWith(
                                color: theme.mutedTextColor,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: padding,
                  // ignore: deprecated_member_use
                  cacheExtent: 0,
                  itemExtent: weekExtent,
                  itemCount: weekCount,
                  itemBuilder: (context, weekIndex) {
                    return Column(
                      children: [
                        for (var row = 0; row < 7; row += 1)
                          SizedBox(
                            height:
                                cellExtent + (row == 6 ? 0 : style.cellSpacing),
                            child: Center(
                              child: _buildCell(
                                context,
                                start,
                                weekIndex * 7 + row - leading,
                                cellExtent,
                                normalizedValues,
                                palette,
                                theme,
                                locale,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCell(
    BuildContext context,
    DateTime start,
    int dateIndex,
    double extent,
    Map<int, double> normalizedValues,
    List<Color> palette,
    HorizontalCalendarThemeData theme,
    String? locale,
  ) {
    if (dateIndex < 0 || dateIndex >= dayCount) {
      return SizedBox.square(dimension: extent);
    }
    final date = CalendarDateMath.addDays(start, dateIndex);
    final intensity = normalizedValues[_civilKey(date)] ?? 0;
    final level = intensity == 0
        ? 0
        : (intensity * (palette.length - 1))
            .ceil()
            .clamp(1, palette.length - 1)
            .toInt();
    final percentage = (intensity * 100).round();
    final semanticLabel =
        '${DateFormat.yMMMMEEEEd(locale).format(date)}, $percentage% intensity';
    final state = CalendarHeatmapCellState(
      date: date,
      intensity: intensity,
      level: level,
      color: palette[level],
      semanticLabel: semanticLabel,
      isSelected: selectedDate != null &&
          CalendarDateMath.isSameDay(date, selectedDate!),
    );
    final identifier = _identifier('calendar-contribution-day', date);
    return Semantics(
      identifier: identifier,
      label: semanticLabel,
      button: onDateTap != null,
      selected: state.isSelected,
      child: SizedBox.square(
        key: ValueKey(identifier),
        dimension: extent,
        child: InkWell(
          onTap: onDateTap == null ? null : () => onDateTap!(date),
          child: cellBuilder?.call(context, state) ??
              _DefaultHeatmapCell(
                state: state,
                theme: theme,
                style: style,
                locale: locale,
              ),
        ),
      ),
    );
  }
}

/// Semantic date state used by [CalendarStreakStrip].
enum CalendarStreakState {
  /// A past or current date that was completed.
  completed,

  /// A past date that was not completed.
  missed,

  /// The current civil date when it is not complete.
  today,

  /// A date after today.
  future,
}

/// Immutable visual configuration for [CalendarStreakStrip].
@immutable
class CalendarStreakStyle {
  /// Creates streak-strip visual configuration.
  const CalendarStreakStyle({
    this.completedColor,
    this.missedColor,
    this.todayColor,
    this.futureColor,
    this.selectedColor,
    this.cellExtent = 52,
    this.cellSpacing = 7,
    this.borderRadius = 18,
    this.showLabels = true,
  })  : assert(cellExtent >= 36),
        assert(cellSpacing >= 0),
        assert(borderRadius >= 0);

  /// Completed-date fill override.
  final Color? completedColor;

  /// Missed-date fill override.
  final Color? missedColor;

  /// Today fill override.
  final Color? todayColor;

  /// Future-date fill override.
  final Color? futureColor;

  /// Selected-date outline override.
  final Color? selectedColor;

  /// Width of one date cell.
  final double cellExtent;

  /// Gap between adjacent cells.
  final double cellSpacing;

  /// Cell corner radius.
  final double borderRadius;

  /// Whether weekday and day labels are visible.
  final bool showLabels;
}

/// Complete immutable state supplied to a custom streak cell.
@immutable
class CalendarStreakCellState {
  /// Creates streak cell state.
  const CalendarStreakCellState({
    required this.date,
    required this.state,
    required this.isSelected,
    required this.fillColor,
    required this.semanticLabel,
  });

  /// Normalized civil date.
  final DateTime date;

  /// Completion state for [date].
  final CalendarStreakState state;

  /// Whether [date] is the controlled selected date.
  final bool isSelected;

  /// Resolved state fill color.
  final Color fillColor;

  /// Complete localized accessibility label.
  final String semanticLabel;
}

/// Builds one complete custom streak cell.
typedef CalendarStreakCellBuilder = Widget Function(
  BuildContext context,
  CalendarStreakCellState state,
);

/// Horizontal completion streak for habits, learning, and wellness products.
class CalendarStreakStrip extends StatelessWidget {
  /// Creates a streak containing [dayCount] contiguous dates.
  const CalendarStreakStrip({
    super.key,
    required this.startDate,
    required this.dayCount,
    this.completedDates = const {},
    this.selectedDate,
    this.today,
    this.onDateTap,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.style = const CalendarStreakStyle(),
    this.cellBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
  }) : assert(dayCount >= 1 && dayCount <= 366);

  /// First visible civil date.
  final DateTime startDate;

  /// Number of contiguous dates, from 1 through 366.
  final int dayCount;

  /// Dates considered complete, compared by civil identity.
  final Set<DateTime> completedDates;

  /// Optional controlled selected date.
  final DateTime? selectedDate;

  /// Optional today override for deterministic displays and tests.
  final DateTime? today;

  /// Optional date activation callback.
  final ValueChanged<DateTime>? onDateTap;

  /// Shared style and theme configuration.
  final CalendarAppearance appearance;

  /// Streak-specific colors and geometry.
  final CalendarStreakStyle style;

  /// Optional complete streak-cell replacement.
  final CalendarStreakCellBuilder? cellBuilder;

  /// Outer horizontal padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final resolvedToday = CalendarDateMath.dateOnly(today ?? DateTime.now());
    final completed = completedDates.map(_civilKey).toSet();
    final dates = CalendarDateMath.days(startDate, dayCount);
    final textScale =
        MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0).toDouble();
    final height = style.showLabels ? 56 + 20 * textScale : 52.0;

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: height,
        child: ListView.separated(
          padding: padding,
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, __) => SizedBox(width: style.cellSpacing),
          itemBuilder: (context, index) {
            final date = dates[index];
            final state = completed.contains(_civilKey(date))
                ? CalendarStreakState.completed
                : CalendarDateMath.isSameDay(date, resolvedToday)
                    ? CalendarStreakState.today
                    : CalendarDateMath.civilDayDifference(date, resolvedToday) <
                            0
                        ? CalendarStreakState.future
                        : CalendarStreakState.missed;
            final isSelected = selectedDate != null &&
                CalendarDateMath.isSameDay(date, selectedDate!);
            final fill = _fillColor(state, theme);
            final words = <String>[state.name, if (isSelected) 'selected'];
            final semanticLabel =
                '${DateFormat.yMMMMEEEEd(locale).format(date)}, ${words.join(', ')}';
            final cellState = CalendarStreakCellState(
              date: date,
              state: state,
              isSelected: isSelected,
              fillColor: fill,
              semanticLabel: semanticLabel,
            );
            final identifier = _identifier('calendar-streak-day', date);
            return Semantics(
              identifier: identifier,
              label: semanticLabel,
              selected: isSelected,
              button: onDateTap != null,
              child: SizedBox(
                key: ValueKey(identifier),
                width: style.cellExtent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(style.borderRadius),
                  onTap: onDateTap == null ? null : () => onDateTap!(date),
                  child: cellBuilder?.call(context, cellState) ??
                      _DefaultStreakCell(
                        state: cellState,
                        theme: theme,
                        style: style,
                        locale: locale,
                      ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _fillColor(
    CalendarStreakState state,
    HorizontalCalendarThemeData theme,
  ) {
    return switch (state) {
      CalendarStreakState.completed =>
        style.completedColor ?? theme.accentColor,
      CalendarStreakState.missed =>
        style.missedColor ?? theme.errorColor.withValues(alpha: .18),
      CalendarStreakState.today =>
        style.todayColor ?? theme.todayColor.withValues(alpha: .22),
      CalendarStreakState.future => style.futureColor ?? theme.surfaceColor,
    };
  }
}

class _DefaultStreakCell extends StatelessWidget {
  const _DefaultStreakCell({
    required this.state,
    required this.theme,
    required this.style,
    required this.locale,
  });

  final CalendarStreakCellState state;
  final HorizontalCalendarThemeData theme;
  final CalendarStreakStyle style;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    final completed = state.state == CalendarStreakState.completed;
    final foreground = completed ? theme.onAccentColor : theme.textColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: state.fillColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        border: Border.all(
          color: state.isSelected
              ? style.selectedColor ?? theme.focusColor
              : theme.borderColor,
          width: state.isSelected ? 2.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (completed)
                Icon(Icons.check_rounded, size: 16, color: foreground)
              else if (state.state == CalendarStreakState.today)
                Icon(Icons.circle, size: 8, color: theme.todayColor)
              else
                const SizedBox(height: 16),
              if (style.showLabels) ...[
                Text(
                  DateFormat.E(locale).format(state.date),
                  maxLines: 1,
                  style: theme.weekdayTextStyle.copyWith(color: foreground),
                ),
                Text(
                  '${state.date.day}',
                  maxLines: 1,
                  style: theme.dayTextStyle.copyWith(color: foreground),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

double _normalizeIntensity(double value) {
  if (!value.isFinite) return 0;
  return value.clamp(0, 1).toDouble();
}

List<Color> _heatmapPalette(
  HorizontalCalendarThemeData theme,
  CalendarHeatmapStyle style,
) {
  final supplied = style.colors;
  if (supplied != null) {
    if (supplied.length == 1) {
      return [style.emptyColor ?? theme.surfaceColor, supplied.single];
    }
    return [style.emptyColor ?? supplied.first, ...supplied.skip(1)];
  }
  return List<Color>.generate(
    style.levels,
    (index) => Color.lerp(
      style.emptyColor ?? theme.surfaceColor,
      theme.accentColor,
      index / (style.levels - 1),
    )!,
    growable: false,
  );
}

int _civilKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

String _identifier(String prefix, DateTime date) {
  return '$prefix-${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
