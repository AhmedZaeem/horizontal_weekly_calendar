import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configuration/calendar_configuration.dart';
import '../configuration/calendar_motion.dart';
import '../controller/horizontal_calendar_controller.dart';
import '../models/calendar_day_state.dart';
import '../models/calendar_event.dart';
import '../theme/horizontal_calendar_theme.dart';
import 'calendar_motion_primitives.dart';

/// Resolved semantic colors and outline for one calendar day.
@immutable
class CalendarDayVisualStyle {
  /// Creates a complete day visual style.
  const CalendarDayVisualStyle({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.eventColor,
    required this.borderColor,
    required this.borderWidth,
  });

  /// Primary text and icon color.
  final Color foregroundColor;

  /// Day selection or range fill.
  final Color backgroundColor;

  /// Event-marker color.
  final Color eventColor;

  /// Optional focus or today outline color.
  final Color? borderColor;

  /// Width of [borderColor].
  final double borderWidth;
}

/// Canonical visual precedence shared by built-in calendar day cells.
abstract final class CalendarDayVisualResolver {
  /// Resolves semantic colors without depending on a particular day layout.
  static CalendarDayVisualStyle resolve<T>(
    CalendarDayState<T> state,
    HorizontalCalendarThemeData theme,
  ) {
    final rangeMiddle =
        state.isSelected && state.rangePosition == CalendarRangePosition.middle;
    final selectedBoundary = state.isSelected && !rangeMiddle;
    final foreground = state.isDisabled
        ? theme.disabledColor
        : selectedBoundary
            ? theme.onAccentColor
            : theme.textColor;
    final background = state.isDisabled
        ? Colors.transparent
        : selectedBoundary
            ? theme.accentColor
            : rangeMiddle
                ? theme.accentColor.withValues(alpha: .16)
                : Colors.transparent;
    final eventColor = state.isDisabled
        ? theme.disabledColor
        : selectedBoundary
            ? theme.onAccentColor
            : rangeMiddle
                ? theme.accentColor
                : theme.eventColor;
    final borderColor = state.isFocused && !state.isSelected
        ? theme.focusColor
        : state.isToday && !state.isSelected
            ? theme.todayColor
            : null;
    return CalendarDayVisualStyle(
      foregroundColor: foreground,
      backgroundColor: background,
      eventColor: eventColor,
      borderColor: borderColor,
      borderWidth: state.isFocused && !state.isSelected ? 2 : 1.5,
    );
  }
}

/// Standard accessible day cell shared by calendar surfaces.
class CalendarDayCell<T> extends StatelessWidget {
  /// Creates a calendar day cell.
  const CalendarDayCell({
    super.key,
    required this.state,
    required this.theme,
    this.onTap,
    this.locale,
    this.eventIndicatorStyle = EventIndicatorStyle.dot,
    this.eventIndicatorBuilder,
    this.contentBuilder,
    this.semanticIdentifier,
    this.motion,
    this.motionIndex = 0,
  });

  /// Complete immutable day state.
  final CalendarDayState<T> state;

  /// Resolved calendar theme.
  final HorizontalCalendarThemeData theme;

  /// Called when the enabled cell is activated.
  final VoidCallback? onTap;

  /// Optional locale override for the weekday label.
  final String? locale;

  /// Built-in event marker presentation.
  final EventIndicatorStyle eventIndicatorStyle;

  /// Optional marker replacement.
  final CalendarEventIndicatorBuilder<T>? eventIndicatorBuilder;

  /// Optional replacement for the standard visual content.
  final CalendarDayBuilder<T>? contentBuilder;

  /// Optional stable identifier for semantics and widget tests.
  final String? semanticIdentifier;

  /// Optional selection, event, and hover choreography.
  final CalendarMotion? motion;

  /// Stable index used to vary staggered transition duration.
  final int motionIndex;

  @override
  Widget build(BuildContext context) {
    final visual = CalendarDayVisualResolver.resolve(state, theme);
    final duration = motion?.effectiveDuration(context) ??
        (MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : theme.motionDuration);
    final curve = motion?.curve ?? theme.motionCurve;
    final content = Semantics(
      identifier: semanticIdentifier,
      label: state.semanticLabel,
      selected: state.isSelected,
      enabled: !state.isDisabled,
      button: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: theme.minimumInteractiveDimension,
          minHeight: theme.minimumInteractiveDimension,
          maxWidth: theme.dayCellExtent,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(theme.dayBorderRadius),
          onTap: state.isDisabled ? null : onTap,
          child: contentBuilder?.call(context, state) ??
              _CalendarSelectionMotion(
                selected: state.isSelected,
                motion: motion,
                index: motionIndex,
                // The fill, outline, and label colors interpolate continuously
                // so a selection change reads as one movement rather than a
                // transform layered over an instant repaint.
                child: AnimatedContainer(
                  duration: duration,
                  curve: curve,
                  decoration: BoxDecoration(
                    color: visual.backgroundColor,
                    borderRadius: _selectionRadius(
                      state.rangePosition,
                      theme.dayBorderRadius,
                    ),
                    border: Border.all(
                      color: visual.borderColor ?? Colors.transparent,
                      width:
                          visual.borderColor == null ? 0 : visual.borderWidth,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPadding(
                        duration: duration,
                        curve: curve,
                        padding: EdgeInsets.fromLTRB(
                          4,
                          6,
                          4,
                          state.eventCount > 0 ? theme.eventMarkerSize + 10 : 6,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: duration,
                                curve: curve,
                                style: theme.weekdayTextStyle.copyWith(
                                  color: visual.foregroundColor,
                                ),
                                child: Text(
                                  DateFormat.E(locale).format(state.date),
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: duration,
                                curve: curve,
                                style: theme.dayTextStyle
                                    .copyWith(color: visual.foregroundColor),
                                child: Text(
                                  '${state.date.day}',
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.eventCount > 0)
                        Positioned(
                          bottom: 5,
                          child: _CalendarEventMotion(
                            count: state.eventCount,
                            motion: motion,
                            child:
                                eventIndicatorBuilder?.call(context, state) ??
                                    CalendarEventMarker(
                                      count: state.eventCount,
                                      style: eventIndicatorStyle,
                                      color: visual.eventColor,
                                      size: theme.eventMarkerSize,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
    return CalendarPressable(
      enabled: !state.isDisabled && onTap != null,
      motion: motion,
      child: content,
    );
  }
}

/// Emphasizes a selected date with an interruptible, continuous transform.
///
/// Progress rests at the unselected geometry and moves toward the selected
/// emphasis, so tapping between dates faster than the transition completes
/// reads as one continuous movement instead of a restarted animation.
class _CalendarSelectionMotion extends StatelessWidget {
  const _CalendarSelectionMotion({
    required this.selected,
    required this.motion,
    required this.index,
    required this.child,
  });

  final bool selected;
  final CalendarMotion? motion;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = this.motion;
    if (motion == null ||
        motion.selectionTransition == CalendarSelectionTransition.none ||
        // The surrounding container already cross-fades every semantic color,
        // so a fade transition needs no additional transform.
        motion.selectionTransition == CalendarSelectionTransition.fade) {
      return child;
    }
    return CalendarStateTransition(
      active: selected,
      motion: motion,
      index: index,
      child: child,
      builder: (context, progress, child) =>
          switch (motion.selectionTransition) {
        CalendarSelectionTransition.none ||
        CalendarSelectionTransition.fade =>
          child!,
        CalendarSelectionTransition.scale => Transform.scale(
            scale: 1 + .05 * progress,
            child: child,
          ),
        CalendarSelectionTransition.slide => Transform.translate(
            offset: Offset(0, -4 * progress),
            child: child,
          ),
        CalendarSelectionTransition.bounce => Transform.scale(
            scale: 1 + .07 * progress,
            child: child,
          ),
      },
    );
  }
}

class _CalendarEventMotion extends StatelessWidget {
  const _CalendarEventMotion({
    required this.count,
    required this.motion,
    required this.child,
  });

  final int count;
  final CalendarMotion? motion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = this.motion;
    if (motion == null ||
        motion.eventTransition == CalendarEventTransition.none) {
      return child;
    }
    return AnimatedSwitcher(
      duration: motion.effectiveDuration(context),
      switchInCurve: Curves.linear,
      switchOutCurve: Curves.linear,
      transitionBuilder: (child, animation) {
        final scale = animation.drive(CurveTween(curve: motion.curve));
        return switch (motion.eventTransition) {
          CalendarEventTransition.none => child,
          CalendarEventTransition.fade => FadeTransition(
              opacity: animation,
              child: child,
            ),
          CalendarEventTransition.scale => ScaleTransition(
              scale: scale,
              child: FadeTransition(opacity: animation, child: child),
            ),
        };
      },
      child: KeyedSubtree(key: ValueKey(count), child: child),
    );
  }
}

BorderRadiusGeometry _selectionRadius(
  CalendarRangePosition position,
  double radius,
) {
  final rounded = Radius.circular(radius);
  return switch (position) {
    CalendarRangePosition.start => BorderRadiusDirectional.only(
        topStart: rounded,
        bottomStart: rounded,
      ),
    CalendarRangePosition.middle => BorderRadius.zero,
    CalendarRangePosition.end => BorderRadiusDirectional.only(
        topEnd: rounded,
        bottomEnd: rounded,
      ),
    CalendarRangePosition.none ||
    CalendarRangePosition.single =>
      BorderRadius.circular(radius),
  };
}

/// Compact event presence indicator.
class CalendarEventMarker extends StatelessWidget {
  /// Creates an event marker.
  const CalendarEventMarker({
    super.key,
    required this.count,
    this.style = EventIndicatorStyle.dot,
    this.color,
    this.size = 6,
  }) : assert(count > 0);

  /// Number of represented events.
  final int count;

  /// Marker presentation.
  final EventIndicatorStyle style;

  /// Marker color; ambient primary color is used when omitted.
  final Color? color;

  /// Base marker diameter or thickness.
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.primary;
    return switch (style) {
      EventIndicatorStyle.dot => Container(
          width: size,
          height: size,
          decoration:
              BoxDecoration(color: resolvedColor, shape: BoxShape.circle),
        ),
      EventIndicatorStyle.count => Text(
          '$count',
          style: TextStyle(
            color: resolvedColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      EventIndicatorStyle.bar => Container(
          width: size * 3,
          height: size / 2,
          decoration: BoxDecoration(
            color: resolvedColor,
            borderRadius: BorderRadius.circular(size),
          ),
        ),
      EventIndicatorStyle.stack => SizedBox(
          width: size * 2,
          height: size,
          child: Stack(
            children: List.generate(
              count.clamp(1, 3),
              (index) => PositionedDirectional(
                start: index * size / 2,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: resolvedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: .5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    };
  }
}

/// Standard month title and navigation controls.
class CalendarHeader extends StatelessWidget {
  /// Creates a calendar header.
  const CalendarHeader({
    super.key,
    required this.state,
    required this.theme,
    this.locale,
    this.showToday = true,
  });

  /// Header navigation state and actions.
  final CalendarHeaderState state;

  /// Resolved calendar theme.
  final HorizontalCalendarThemeData theme;

  /// Optional locale override.
  final String? locale;

  /// Whether a compact today action is visible.
  final bool showToday;

  @override
  Widget build(BuildContext context) {
    final title = DateFormat.yMMMM(locale).format(state.focusedDate);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : theme.motionDuration;
    return Row(
      children: [
        Expanded(
          // The month label cross-fades so paging past a month boundary does
          // not swap the title in a single frame.
          child: AnimatedSwitcher(
            duration: duration,
            switchInCurve: theme.motionCurve,
            switchOutCurve: theme.motionCurve,
            layoutBuilder: (current, previous) => Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [...previous, if (current != null) current],
            ),
            child: Text(
              title,
              key: ValueKey(title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.headerTextStyle.copyWith(color: theme.textColor),
            ),
          ),
        ),
        if (showToday)
          IconButton(
            key: const ValueKey('calendar-header-today'),
            constraints: BoxConstraints.tightFor(
              width: theme.minimumInteractiveDimension,
              height: theme.minimumInteractiveDimension,
            ),
            onPressed: state.onToday,
            tooltip: 'Today',
            icon: const Icon(Icons.today_outlined),
          ),
        IconButton(
          key: const ValueKey('calendar-header-previous'),
          constraints: BoxConstraints.tightFor(
            width: theme.minimumInteractiveDimension,
            height: theme.minimumInteractiveDimension,
          ),
          onPressed: state.canNavigateBackward ? state.onPrevious : null,
          tooltip: MaterialLocalizations.of(context).previousPageTooltip,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          key: const ValueKey('calendar-header-next'),
          constraints: BoxConstraints.tightFor(
            width: theme.minimumInteractiveDimension,
            height: theme.minimumInteractiveDimension,
          ),
          onPressed: state.canNavigateForward ? state.onNext : null,
          tooltip: MaterialLocalizations.of(context).nextPageTooltip,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

/// Reusable event card that always returns the original typed event.
class CalendarEventTile<T> extends StatelessWidget {
  /// Creates an event tile.
  const CalendarEventTile({
    super.key,
    required this.event,
    required this.theme,
    this.onTap,
    this.onLongPress,
    this.leading,
    this.trailing,
    this.compact = false,
    this.motion,
  });

  /// Original typed event.
  final CalendarEvent<T> event;

  /// Resolved calendar theme.
  final HorizontalCalendarThemeData theme;

  /// Called with [event] on tap.
  final ValueChanged<CalendarEvent<T>>? onTap;

  /// Called with [event] on long press.
  final ValueChanged<CalendarEvent<T>>? onLongPress;

  /// Optional leading content.
  final Widget? leading;

  /// Optional trailing content.
  final Widget? trailing;

  /// Whether to use compact padding.
  final bool compact;

  /// Optional press-feedback choreography.
  final CalendarMotion? motion;

  @override
  Widget build(BuildContext context) {
    final color = event.color ?? theme.eventColor;
    return CalendarPressable(
      enabled: onTap != null || onLongPress != null,
      motion: motion,
      child: Semantics(
        button: onTap != null,
        label: event.semanticLabel ?? event.title,
        child: InkWell(
          onTap: onTap == null ? null : () => onTap!(event),
          onLongPress: onLongPress == null ? null : () => onLongPress!(event),
          borderRadius: BorderRadius.circular(theme.dayBorderRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.elevatedSurfaceColor,
              borderRadius: BorderRadius.circular(theme.dayBorderRadius),
              border: BorderDirectional(
                start: BorderSide(color: color, width: 4),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(compact ? 8 : 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      event.title ?? '',
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          theme.eventTextStyle.copyWith(color: theme.textColor),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Current-time line with an optional label.
class CalendarNowIndicator extends StatelessWidget {
  /// Creates a current-time indicator.
  const CalendarNowIndicator({
    super.key,
    this.label,
    this.color,
    this.thickness = 2,
  });

  /// Optional time label.
  final String? label;

  /// Indicator color.
  final Color? color;

  /// Line thickness.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.error;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: resolvedColor,
            shape: BoxShape.circle,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 4),
          Text(label!, style: TextStyle(color: resolvedColor, fontSize: 11)),
          const SizedBox(width: 4),
        ],
        Expanded(child: Divider(color: resolvedColor, thickness: thickness)),
      ],
    );
  }
}

/// Accessible fold affordance shared by foldable calendar headers.
class CalendarFoldHandle extends StatelessWidget {
  /// Creates a fold handle.
  const CalendarFoldHandle({
    super.key,
    required this.state,
    required this.onChanged,
    required this.theme,
  });

  /// Current stable fold state.
  final CalendarFoldState state;

  /// Reports the opposite stable state when activated.
  final ValueChanged<CalendarFoldState> onChanged;

  /// Resolved calendar theme.
  final HorizontalCalendarThemeData theme;

  @override
  Widget build(BuildContext context) {
    final expanded = state == CalendarFoldState.expanded;
    return Semantics(
      button: true,
      expanded: expanded,
      label: expanded ? 'Collapse to week' : 'Expand to month',
      child: InkWell(
        borderRadius: BorderRadius.circular(theme.dayBorderRadius),
        onTap: () => onChanged(
          expanded ? CalendarFoldState.collapsed : CalendarFoldState.expanded,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: theme.minimumInteractiveDimension,
            minHeight: theme.minimumInteractiveDimension,
          ),
          child: Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: theme.mutedTextColor,
          ),
        ),
      ),
    );
  }
}
