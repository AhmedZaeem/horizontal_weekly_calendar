import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configuration/calendar_configuration.dart';
import '../domain/calendar_date_math.dart';
import '../models/calendar_selection.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';

/// Temporal state of a [CalendarCountdownCard].
enum CalendarCountdownStatus {
  /// The target is before the reference date.
  past,

  /// The target and reference are the same civil date.
  today,

  /// The target is after the reference date.
  upcoming,

  /// The application has marked the target complete.
  completed,
}

/// Immutable state supplied by [CalendarCountdownCard].
@immutable
class CalendarCountdownState<T> {
  /// Creates resolved countdown state.
  const CalendarCountdownState({
    required this.targetDate,
    required this.remainingDays,
    required this.status,
    required this.progress,
    required this.semanticLabel,
    this.data,
  });

  /// Normalized target civil date.
  final DateTime targetDate;

  /// Non-negative number of days remaining.
  final int remainingDays;

  /// Resolved temporal or completion state.
  final CalendarCountdownStatus status;

  /// Finite progress from zero through one.
  final double progress;

  /// Original unchanged application payload.
  final T? data;

  /// Complete localized accessibility label.
  final String semanticLabel;
}

/// Builds complete custom countdown content.
typedef CalendarCountdownBuilder<T> = Widget Function(
  BuildContext context,
  CalendarCountdownState<T> state,
);

/// Responsive target-date card for launches, trips, renewals, and deadlines.
class CalendarCountdownCard<T> extends StatelessWidget {
  /// Creates a typed countdown card.
  const CalendarCountdownCard({
    super.key,
    required this.targetDate,
    required this.referenceDate,
    this.startDate,
    this.completed = false,
    this.data,
    this.onTap,
    this.builder,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.title = 'Countdown',
    this.pastLabel = 'Passed',
    this.todayLabel = 'Today',
    this.completedLabel = 'Complete',
    this.showProgress = true,
    this.useGradient = true,
  });

  /// Target civil date.
  final DateTime targetDate;

  /// Date used to resolve temporal state.
  final DateTime referenceDate;

  /// Optional progress origin; dates before it resolve to zero progress.
  final DateTime? startDate;

  /// Whether the application has completed the target.
  final bool completed;

  /// Typed application payload.
  final T? data;

  /// Reports activation with complete immutable state.
  final ValueChanged<CalendarCountdownState<T>>? onTap;

  /// Optional complete content replacement.
  final CalendarCountdownBuilder<T>? builder;

  /// Shared style and theme configuration.
  final CalendarAppearance appearance;

  /// Built-in card title.
  final String title;

  /// Built-in label for a past target.
  final String pastLabel;

  /// Built-in label for a target occurring today.
  final String todayLabel;

  /// Built-in label for a completed target.
  final String completedLabel;

  /// Whether the built-in card shows a progress rail.
  final bool showProgress;

  /// Whether the built-in card uses a subtle accent gradient.
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final target = CalendarDateMath.dateOnly(targetDate);
    final reference = CalendarDateMath.dateOnly(referenceDate);
    final difference = CalendarDateMath.civilDayDifference(reference, target);
    final status = completed
        ? CalendarCountdownStatus.completed
        : difference < 0
            ? CalendarCountdownStatus.past
            : difference == 0
                ? CalendarCountdownStatus.today
                : CalendarCountdownStatus.upcoming;
    final progress = _countdownProgress(target, reference);
    final statusLabel = switch (status) {
      CalendarCountdownStatus.past => pastLabel,
      CalendarCountdownStatus.today => todayLabel,
      CalendarCountdownStatus.completed => completedLabel,
      CalendarCountdownStatus.upcoming =>
        '$difference ${difference == 1 ? 'day' : 'days'} to go',
    };
    final semanticLabel =
        '$title, ${DateFormat.yMMMMEEEEd(locale).format(target)}, $statusLabel';
    final state = CalendarCountdownState<T>(
      targetDate: target,
      remainingDays: math.max(0, difference),
      status: status,
      progress: progress,
      semanticLabel: semanticLabel,
      data: data,
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Material(
        key: const ValueKey('calendar-countdown-card'),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(theme.surfaceBorderRadius),
          onTap: onTap == null ? null : () => onTap!(state),
          child: builder?.call(context, state) ??
              _CountdownContent<T>(
                state: state,
                theme: theme,
                title: title,
                statusLabel: statusLabel,
                showProgress: showProgress,
                useGradient: useGradient,
                locale: locale,
              ),
        ),
      ),
    );
  }

  double _countdownProgress(DateTime target, DateTime reference) {
    if (completed ||
        CalendarDateMath.civilDayDifference(reference, target) <= 0) {
      return 1;
    }
    final origin =
        startDate == null ? reference : CalendarDateMath.dateOnly(startDate!);
    final total = CalendarDateMath.civilDayDifference(origin, target);
    if (total <= 0) return 1;
    final elapsed = CalendarDateMath.civilDayDifference(origin, reference);
    return (elapsed / total).clamp(0.0, 1.0);
  }
}

class _CountdownContent<T> extends StatelessWidget {
  const _CountdownContent({
    required this.state,
    required this.theme,
    required this.title,
    required this.statusLabel,
    required this.showProgress,
    required this.useGradient,
    required this.locale,
  });

  final CalendarCountdownState<T> state;
  final HorizontalCalendarThemeData theme;
  final String title;
  final String statusLabel;
  final bool showProgress;
  final bool useGradient;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 330 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.35;
      final date = DateFormat.yMMMd(locale).format(state.targetDate);
      final leading = DecoratedBox(
        decoration: BoxDecoration(
          color: theme.onAccentColor.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(theme.dayBorderRadius),
        ),
        child: SizedBox.square(
          dimension: compact ? 52 : 64,
          child: Center(
            child: FittedBox(
              child: Text(
                state.status == CalendarCountdownStatus.upcoming
                    ? '${state.remainingDays}'
                    : switch (state.status) {
                        CalendarCountdownStatus.completed => '✓',
                        CalendarCountdownStatus.today => '•',
                        CalendarCountdownStatus.past => '−',
                        CalendarCountdownStatus.upcoming => '',
                      },
                style: theme.headerTextStyle.copyWith(
                  color: theme.onAccentColor,
                  fontSize: compact ? 26 : 34,
                ),
              ),
            ),
          ),
        ),
      );
      final copy = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.eventTextStyle.copyWith(
              color: theme.onAccentColor.withValues(alpha: .78),
            ),
          ),
          Text(
            statusLabel,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: theme.headerTextStyle.copyWith(color: theme.onAccentColor),
          ),
          Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.eventTextStyle.copyWith(color: theme.onAccentColor),
          ),
        ],
      );
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.accentColor,
          gradient: useGradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.accentColor,
                    Color.lerp(theme.accentColor, theme.todayColor, .52)!,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(theme.surfaceBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : theme.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (compact) ...[
                Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: leading),
                const SizedBox(height: 10),
                copy,
              ] else
                Row(
                  children: [
                    leading,
                    const SizedBox(width: 14),
                    Expanded(child: copy),
                  ],
                ),
              if (showProgress) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 5,
                    color: theme.onAccentColor,
                    backgroundColor: theme.onAccentColor.withValues(alpha: .18),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

/// Semantic state of one [CalendarWeekProgress] day.
enum CalendarWeekProgressState {
  /// A date before the current date.
  completed,

  /// The current date.
  current,

  /// A date after the current date.
  upcoming,

  /// The controlled selected date.
  selected,

  /// A date disabled by the application.
  disabled,
}

/// Immutable state supplied to a custom week-progress day.
@immutable
class CalendarWeekProgressDayState {
  /// Creates resolved day state.
  const CalendarWeekProgressDayState({
    required this.date,
    required this.state,
    required this.progress,
    required this.semanticLabel,
  });

  /// Normalized unique civil date.
  final DateTime date;

  /// Resolved progress state.
  final CalendarWeekProgressState state;

  /// Finite progress from zero through one.
  final double progress;

  /// Complete localized accessibility label.
  final String semanticLabel;
}

/// Builds a complete custom week-progress day.
typedef CalendarWeekProgressDayBuilder = Widget Function(
  BuildContext context,
  CalendarWeekProgressDayState state,
);

/// Seven-day progress rail with accessible, typed date activation.
class CalendarWeekProgress extends StatelessWidget {
  /// Creates a seven-day progress surface.
  const CalendarWeekProgress({
    super.key,
    required this.startDate,
    required this.currentDate,
    this.selectedDate,
    this.selectableDayPredicate,
    this.onDateTap,
    this.dayBuilder,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.showLabels = true,
  });

  /// First of seven contiguous civil dates.
  final DateTime startDate;

  /// Date dividing completed and upcoming segments.
  final DateTime currentDate;

  /// Optional controlled selected date.
  final DateTime? selectedDate;

  /// Optional enabled-day rule.
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Reports activation of an enabled date.
  final ValueChanged<DateTime>? onDateTap;

  /// Optional complete day replacement.
  final CalendarWeekProgressDayBuilder? dayBuilder;

  /// Shared style and theme configuration.
  final CalendarAppearance appearance;

  /// Whether built-in weekday and day labels are visible.
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final start = CalendarDateMath.dateOnly(startDate);
    final current = CalendarDateMath.dateOnly(currentDate);
    final dates = CalendarDateMath.days(start, 7);
    final textScale =
        MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0).toDouble();

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : theme.minimumInteractiveDimension * 7;
        final cellExtent = math.max(
          theme.minimumInteractiveDimension,
          available / 7,
        );
        return SizedBox(
          height: (showLabels ? 72 : 48) + (textScale - 1) * 22,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(available, cellExtent * 7),
              child: Row(
                children: [
                  for (final date in dates)
                    SizedBox(
                      width: cellExtent,
                      child: _weekDay(
                        context,
                        date,
                        current,
                        theme,
                        locale,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _weekDay(
    BuildContext context,
    DateTime date,
    DateTime current,
    HorizontalCalendarThemeData theme,
    String? locale,
  ) {
    final disabled = !(selectableDayPredicate?.call(date) ?? true);
    final selected =
        selectedDate != null && CalendarDateMath.isSameDay(date, selectedDate!);
    final difference = CalendarDateMath.civilDayDifference(current, date);
    final state = disabled
        ? CalendarWeekProgressState.disabled
        : selected
            ? CalendarWeekProgressState.selected
            : difference < 0
                ? CalendarWeekProgressState.completed
                : difference == 0
                    ? CalendarWeekProgressState.current
                    : CalendarWeekProgressState.upcoming;
    final progress = switch (state) {
      CalendarWeekProgressState.completed ||
      CalendarWeekProgressState.selected =>
        1.0,
      CalendarWeekProgressState.current => .5,
      CalendarWeekProgressState.upcoming ||
      CalendarWeekProgressState.disabled =>
        0.0,
    };
    final semanticLabel =
        '${DateFormat.yMMMMEEEEd(locale).format(date)}, ${state.name}';
    final dayState = CalendarWeekProgressDayState(
      date: date,
      state: state,
      progress: progress,
      semanticLabel: semanticLabel,
    );
    final identifier = _dateIdentifier('calendar-week-progress', date);
    return Semantics(
      identifier: identifier,
      label: semanticLabel,
      enabled: !disabled,
      selected: selected,
      button: onDateTap != null,
      child: InkWell(
        key: ValueKey(identifier),
        borderRadius: BorderRadius.circular(theme.dayBorderRadius),
        onTap: disabled || onDateTap == null ? null : () => onDateTap!(date),
        child: dayBuilder?.call(context, dayState) ??
            _WeekProgressDay(
              state: dayState,
              theme: theme,
              showLabels: showLabels,
              locale: locale,
            ),
      ),
    );
  }
}

class _WeekProgressDay extends StatelessWidget {
  const _WeekProgressDay({
    required this.state,
    required this.theme,
    required this.showLabels,
    required this.locale,
  });

  final CalendarWeekProgressDayState state;
  final HorizontalCalendarThemeData theme;
  final bool showLabels;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    final active = state.state == CalendarWeekProgressState.completed ||
        state.state == CalendarWeekProgressState.current ||
        state.state == CalendarWeekProgressState.selected;
    final color = state.state == CalendarWeekProgressState.disabled
        ? theme.disabledColor
        : state.state == CalendarWeekProgressState.selected
            ? theme.focusColor
            : active
                ? theme.accentColor
                : theme.borderColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : theme.motionDuration,
            width: state.state == CalendarWeekProgressState.current ? 14 : 10,
            height: state.state == CalendarWeekProgressState.current ? 14 : 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: theme.backgroundColor, width: 2),
            ),
          ),
          if (showLabels) ...[
            const SizedBox(height: 5),
            FittedBox(
              child: Text(
                DateFormat.E(locale).format(state.date),
                style: theme.eventTextStyle.copyWith(
                  color: theme.mutedTextColor,
                ),
              ),
            ),
            Text(
              '${state.date.day}',
              style: theme.dayTextStyle.copyWith(color: theme.textColor),
            ),
          ],
        ],
      ),
    );
  }
}

/// Immutable state supplied by [CalendarDateRangeSummary].
@immutable
class CalendarDateRangeSummaryState<T> {
  /// Creates resolved range-summary state.
  const CalendarDateRangeSummaryState({
    required this.range,
    required this.inclusiveDays,
    required this.elapsedDays,
    required this.progress,
    required this.semanticLabel,
    this.data,
  });

  /// Normalized inclusive range.
  final CalendarDateRange range;

  /// Number of represented civil dates.
  final int inclusiveDays;

  /// Number of elapsed represented dates.
  final int elapsedDays;

  /// Finite progress from zero through one.
  final double progress;

  /// Original unchanged application payload.
  final T? data;

  /// Complete localized accessibility label.
  final String semanticLabel;
}

/// Builds complete custom date-range summary content.
typedef CalendarDateRangeSummaryBuilder<T> = Widget Function(
  BuildContext context,
  CalendarDateRangeSummaryState<T> state,
);

/// Responsive overview of an inclusive range, endpoints, and elapsed progress.
class CalendarDateRangeSummary<T> extends StatelessWidget {
  /// Creates a typed date-range summary.
  const CalendarDateRangeSummary({
    super.key,
    required this.range,
    required this.referenceDate,
    this.data,
    this.onTap,
    this.builder,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.title = 'Date range',
    this.showProgress = true,
  });

  /// Inclusive normalized range.
  final CalendarDateRange range;

  /// Date used to resolve elapsed progress.
  final DateTime referenceDate;

  /// Typed application payload.
  final T? data;

  /// Reports activation with complete immutable state.
  final ValueChanged<CalendarDateRangeSummaryState<T>>? onTap;

  /// Optional complete content replacement.
  final CalendarDateRangeSummaryBuilder<T>? builder;

  /// Shared style and theme configuration.
  final CalendarAppearance appearance;

  /// Built-in summary title.
  final String title;

  /// Whether the built-in summary shows a progress rail.
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final reference = CalendarDateMath.dateOnly(referenceDate);
    final elapsed =
        CalendarDateMath.civilDayDifference(range.start, reference) + 1;
    final elapsedDays = elapsed.clamp(0, range.dayCount);
    final progress = elapsedDays / range.dayCount;
    final semanticLabel =
        '$title, ${DateFormat.yMMMMd(locale).format(range.start)} '
        'to ${DateFormat.yMMMMd(locale).format(range.end)}, '
        '${range.dayCount} ${range.dayCount == 1 ? 'day' : 'days'}';
    final state = CalendarDateRangeSummaryState<T>(
      range: range,
      inclusiveDays: range.dayCount,
      elapsedDays: elapsedDays,
      progress: progress,
      semanticLabel: semanticLabel,
      data: data,
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Material(
        key: const ValueKey('calendar-range-summary'),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(theme.surfaceBorderRadius),
          onTap: onTap == null ? null : () => onTap!(state),
          child: builder?.call(context, state) ??
              _RangeSummaryContent<T>(
                state: state,
                theme: theme,
                title: title,
                showProgress: showProgress,
                locale: locale,
              ),
        ),
      ),
    );
  }
}

class _RangeSummaryContent<T> extends StatelessWidget {
  const _RangeSummaryContent({
    required this.state,
    required this.theme,
    required this.title,
    required this.showProgress,
    required this.locale,
  });

  final CalendarDateRangeSummaryState<T> state;
  final HorizontalCalendarThemeData theme;
  final String title;
  final bool showProgress;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 360 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.35;
      final start = _endpoint('Starts', state.range.start);
      final end = _endpoint('Ends', state.range.end);
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(theme.surfaceBorderRadius),
          border: Border.all(color: theme.borderColor),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : theme.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.headerTextStyle.copyWith(
                        color: theme.textColor,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      child: Text(
                        '${state.inclusiveDays} ${state.inclusiveDays == 1 ? 'day' : 'days'}',
                        style: theme.eventTextStyle.copyWith(
                          color: theme.accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (compact) ...[
                start,
                const SizedBox(height: 8),
                end,
              ] else
                Row(
                  children: [
                    Expanded(child: start),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: theme.mutedTextColor,
                      ),
                    ),
                    Expanded(child: end),
                  ],
                ),
              if (showProgress) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 6,
                    color: theme.accentColor,
                    backgroundColor: theme.borderColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _endpoint(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.eventTextStyle.copyWith(color: theme.mutedTextColor),
        ),
        Text(
          DateFormat.yMMMd(locale).format(date),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.dayTextStyle.copyWith(color: theme.textColor),
        ),
      ],
    );
  }
}

String _dateIdentifier(String prefix, DateTime date) {
  return '$prefix-${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
