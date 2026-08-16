import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../configuration/calendar_configuration.dart';
import '../configuration/calendar_motion.dart';
import '../controller/horizontal_calendar_controller.dart';
import '../models/calendar_event.dart';
import '../models/calendar_selection.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';
import 'calendar_components.dart';
import 'calendar_motion_primitives.dart';
import 'horizontal_calendar.dart';
import 'month_calendar.dart';

/// Built-in control presentation for [FoldableCalendar].
enum CalendarFoldControl {
  /// A compact chevron handle.
  handle,

  /// A labeled expand or collapse button.
  button,

  /// Both the compact handle and labeled button.
  both,

  /// No built-in control; gestures and controllers remain available.
  hidden,
}

/// Builds a complete custom fold control.
typedef CalendarFoldControlBuilder = Widget Function(
  BuildContext context,
  CalendarFoldState state,
  ValueChanged<CalendarFoldState> onChanged,
  HorizontalCalendarThemeData theme,
);

/// Controlled calendar that folds between a horizontal week and month grid.
class FoldableCalendar<T> extends StatefulWidget {
  /// Creates a week-to-month foldable calendar.
  const FoldableCalendar({
    super.key,
    this.controller,
    required this.focusedDate,
    required this.selection,
    required this.onFocusedDateChanged,
    required this.onSelectionChanged,
    this.foldState = CalendarFoldState.collapsed,
    this.onFoldStateChanged,
    this.bounds,
    this.behavior = const CalendarBehavior(),
    this.appearance = const CalendarAppearance(),
    this.outsideMonthVisibility = OutsideMonthVisibility.visible,
    this.events = const [],
    this.eventSource,
    this.builders = const CalendarBuilders(),
    this.dragThreshold = 36,
    this.foldControl = CalendarFoldControl.handle,
    this.foldControlBuilder,
    this.expandLabel = 'Show month',
    this.collapseLabel = 'Show week',
    this.expandIcon = Icons.calendar_view_month_rounded,
    this.collapseIcon = Icons.view_week_rounded,
  }) : assert(dragThreshold > 0);

  /// Creates a foldable calendar with an easy single-date callback.
  factory FoldableCalendar.single({
    Key? key,
    HorizontalCalendarController? controller,
    required DateTime focusedDate,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    ValueChanged<DateTime>? onFocusedDateChanged,
    CalendarFoldState foldState = CalendarFoldState.collapsed,
    ValueChanged<CalendarFoldState>? onFoldStateChanged,
    CalendarDateRange? bounds,
    CalendarBehavior behavior = const CalendarBehavior(),
    CalendarAppearance appearance = const CalendarAppearance(),
    OutsideMonthVisibility outsideMonthVisibility =
        OutsideMonthVisibility.visible,
    List<CalendarEvent<T>> events = const [],
    CalendarEventSource<T>? eventSource,
    CalendarBuilders<T> builders = const CalendarBuilders(),
    double dragThreshold = 36,
    CalendarFoldControl foldControl = CalendarFoldControl.handle,
    CalendarFoldControlBuilder? foldControlBuilder,
    String expandLabel = 'Show month',
    String collapseLabel = 'Show week',
    IconData expandIcon = Icons.calendar_view_month_rounded,
    IconData collapseIcon = Icons.view_week_rounded,
  }) {
    return FoldableCalendar<T>(
      key: key,
      controller: controller,
      focusedDate: focusedDate,
      selection: CalendarSelection.single(selectedDate),
      onFocusedDateChanged: onFocusedDateChanged ?? (_) {},
      onSelectionChanged: (_, next) {
        final date = next.selectedDate;
        if (date != null) onDateSelected(date);
      },
      foldState: foldState,
      onFoldStateChanged: onFoldStateChanged,
      bounds: bounds,
      behavior: behavior,
      appearance: appearance,
      outsideMonthVisibility: outsideMonthVisibility,
      events: events,
      eventSource: eventSource,
      builders: builders,
      dragThreshold: dragThreshold,
      foldControl: foldControl,
      foldControlBuilder: foldControlBuilder,
      expandLabel: expandLabel,
      collapseLabel: collapseLabel,
      expandIcon: expandIcon,
      collapseIcon: collapseIcon,
    );
  }

  /// Optional imperative focus and fold controller.
  final HorizontalCalendarController? controller;

  /// Controlled focused date.
  final DateTime focusedDate;

  /// Controlled selection shared by both surfaces.
  final CalendarSelection selection;

  /// Reports a proposed focus change.
  final ValueChanged<DateTime> onFocusedDateChanged;

  /// Reports a proposed selection change.
  final CalendarSelectionChanged onSelectionChanged;

  /// Controlled fold state when no controller is supplied.
  final CalendarFoldState foldState;

  /// Reports an accepted fold action.
  final ValueChanged<CalendarFoldState>? onFoldStateChanged;

  /// Inclusive date bounds.
  final CalendarDateRange? bounds;

  /// Shared navigation and availability behavior.
  final CalendarBehavior behavior;

  /// Shared visual configuration.
  final CalendarAppearance appearance;

  /// Treatment of adjacent dates in the expanded month.
  final OutsideMonthVisibility outsideMonthVisibility;

  /// Typed events shared by both surfaces.
  final List<CalendarEvent<T>> events;

  /// Optional asynchronous source shared by both fold states.
  final CalendarEventSource<T>? eventSource;

  /// Shared day, header, and event-indicator builders.
  final CalendarBuilders<T> builders;

  /// Vertical drag distance required to change fold state.
  final double dragThreshold;

  /// Built-in fold-control presentation.
  final CalendarFoldControl foldControl;

  /// Optional complete fold-control replacement.
  final CalendarFoldControlBuilder? foldControlBuilder;

  /// Label shown by the button while collapsed.
  final String expandLabel;

  /// Label shown by the button while expanded.
  final String collapseLabel;

  /// Icon shown by the button while collapsed.
  final IconData expandIcon;

  /// Icon shown by the button while expanded.
  final IconData collapseIcon;

  @override
  State<FoldableCalendar<T>> createState() => _FoldableCalendarState<T>();
}

class _FoldableCalendarState<T> extends State<FoldableCalendar<T>>
    with SingleTickerProviderStateMixin {
  static const double _flingVelocity = 450;

  final GlobalKey _foldKey = GlobalKey();
  late final AnimationController _fold;
  double _dragDistance = 0;
  double _cachedTravel = 240;
  bool _dragging = false;

  CalendarFoldState get _state =>
      widget.controller?.foldState ?? widget.foldState;

  @override
  void initState() {
    super.initState();
    _fold = AnimationController(
      vsync: this,
      value: _state == CalendarFoldState.expanded ? 1 : 0,
      duration: const Duration(milliseconds: 280),
    );
    widget.controller?.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant FoldableCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_changed);
      widget.controller?.addListener(_changed);
    }
    _syncFold();
  }

  void _changed() {
    if (mounted) setState(_syncFold);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_changed);
    _fold.dispose();
    super.dispose();
  }

  /// Height one complete fold travels, measured from the live layout.
  ///
  /// The last valid measurement is cached because both surfaces are only
  /// mounted while the calendar is mid-fold.
  double get _travel {
    final render = _foldKey.currentContext?.findRenderObject();
    if (render is RenderCalendarFold) {
      final travel = render.foldTravel;
      if (travel != null && travel > 8) _cachedTravel = travel;
    }
    return _cachedTravel;
  }

  bool get _animates {
    if (MediaQuery.disableAnimationsOf(context)) return false;
    final motion = widget.appearance.motion;
    if (motion == null) return true;
    return motion.foldTransition != CalendarFoldTransition.none;
  }

  void _syncFold({double velocity = 0}) {
    final target = _state == CalendarFoldState.expanded ? 1.0 : 0.0;
    if (_fold.value == target) return;
    // A command issued with `animate: false` moves the fold in one frame.
    final immediate =
        !_animates || widget.controller?.shouldAnimateLastCommand == false;
    if (immediate) {
      _fold.value = target;
      return;
    }
    final motion = widget.appearance.motion;
    if (motion != null) {
      // A released fold settles on a spring, so a fast flick carries its
      // momentum into the resting state instead of restarting from zero.
      _fold.animateWith(
        SpringSimulation(
          motion.settleSpring,
          _fold.value,
          target,
          velocity / math.max(1, _travel),
        ),
      );
      return;
    }
    _fold.animateTo(
      target,
      duration: widget.appearance.theme?.motionDuration ??
          const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _setState(CalendarFoldState next, {double velocity = 0}) {
    if (next == _state) {
      _syncFold(velocity: velocity);
      return;
    }
    widget.controller?.setFoldState(next);
    widget.onFoldStateChanged?.call(next);
    // Move immediately: a controlled parent may rebuild on a later frame, and
    // the fold should never wait for that round trip.
    setState(() {});
    _syncFold(velocity: velocity);
  }

  void _handleDragStart(DragStartDetails details) {
    _dragDistance = 0;
    _fold.stop();
    // Mount both surfaces up front so the very first drag frame already has a
    // measured travel distance to divide by.
    if (!_dragging) setState(() => _dragging = true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    _dragDistance += delta;
    if (!_animates) return;
    _fold.value = (_fold.value + delta / _travel).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final distance = _dragDistance;
    _dragDistance = 0;
    if (_dragging) setState(() => _dragging = false);

    final committed = distance.abs() >= widget.dragThreshold ||
        velocity.abs() >= _flingVelocity;
    final direction = velocity.abs() >= _flingVelocity ? velocity : distance;
    final next = committed
        ? (direction > 0
            ? CalendarFoldState.expanded
            : CalendarFoldState.collapsed)
        : (_fold.value >= .5
            ? CalendarFoldState.expanded
            : CalendarFoldState.collapsed);
    _setState(next, velocity: velocity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, widget.appearance);
    final motion = widget.appearance.motion;
    // The foldable already draws the surface, so neither fold state adds a
    // second card inside it.
    final horizontalAppearance = widget.appearance.copyWith(
      showHeader: false,
      showSurface: false,
    );
    final week = HorizontalCalendar<T>.controlled(
      controller: widget.controller,
      focusedDate: widget.focusedDate,
      selection: widget.selection,
      onFocusedDateChanged: widget.onFocusedDateChanged,
      onSelectionChanged: widget.onSelectionChanged,
      bounds: widget.bounds,
      behavior: widget.behavior.copyWith(visibleDayCount: 7),
      appearance: horizontalAppearance,
      events: widget.events,
      eventSource: widget.eventSource,
      builders: widget.builders,
    );
    final month = MonthCalendar<T>(
      month: widget.focusedDate,
      focusedDate: widget.focusedDate,
      selection: widget.selection,
      onFocusedDateChanged: widget.onFocusedDateChanged,
      onSelectionChanged: widget.onSelectionChanged,
      bounds: widget.bounds,
      behavior: widget.behavior,
      appearance: horizontalAppearance,
      outsideMonthVisibility: widget.outsideMonthVisibility,
      events: widget.events,
      eventSource: widget.eventSource,
      builders: widget.builders,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart:
          widget.behavior.enableGestures ? _handleDragStart : null,
      onVerticalDragUpdate:
          widget.behavior.enableGestures ? _handleDragUpdate : null,
      onVerticalDragEnd: widget.behavior.enableGestures ? _handleDragEnd : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(theme.surfaceBorderRadius),
          border: Border.all(color: theme.borderColor),
        ),
        child: Padding(
          padding: EdgeInsets.all(theme.contentPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFold(week, month, motion),
              if (widget.foldControl != CalendarFoldControl.hidden)
                KeyedSubtree(
                  key: const ValueKey('calendar-fold-toggle'),
                  child: widget.foldControlBuilder?.call(
                        context,
                        _state,
                        _setState,
                        theme,
                      ) ??
                      _builtInFoldControl(theme),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFold(Widget week, Widget month, CalendarMotion? motion) {
    if (!_animates) {
      return KeyedSubtree(
        key: ValueKey(_state),
        child: _state == CalendarFoldState.collapsed ? week : month,
      );
    }
    final crossFade = motion == null ||
        motion.foldTransition != CalendarFoldTransition.resize;
    return AnimatedBuilder(
      animation: _fold,
      builder: (context, _) {
        final progress = _fold.value.clamp(0.0, 1.0);
        final expandedDominant = progress >= .5;
        // Both surfaces are only mounted while the fold is actually moving, so
        // a settled calendar costs exactly one calendar to build.
        final mountBoth = _dragging || (progress > 0 && progress < 1);
        return CalendarFoldLayout(
          key: _foldKey,
          progress: progress,
          crossFade: crossFade,
          // Only the surface the user is reading stays in the semantics tree,
          // so a half-folded calendar never announces two sets of dates.
          collapsed: mountBoth || progress == 0
              ? ExcludeSemantics(excluding: expandedDominant, child: week)
              : const SizedBox.shrink(),
          expanded: mountBoth || progress == 1
              ? ExcludeSemantics(excluding: !expandedDominant, child: month)
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _builtInFoldControl(HorizontalCalendarThemeData theme) {
    final handle = CalendarFoldHandle(
      state: _state,
      onChanged: _setState,
      theme: theme,
    );
    final expanded = _state == CalendarFoldState.expanded;
    final button = Semantics(
      expanded: expanded,
      button: true,
      label: expanded ? widget.collapseLabel : widget.expandLabel,
      child: OutlinedButton.icon(
        key: const ValueKey('calendar-fold-button'),
        onPressed: () => _setState(
          expanded ? CalendarFoldState.collapsed : CalendarFoldState.expanded,
        ),
        icon: Icon(expanded ? widget.collapseIcon : widget.expandIcon),
        label: Text(
          expanded ? widget.collapseLabel : widget.expandLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    return switch (widget.foldControl) {
      CalendarFoldControl.handle => handle,
      CalendarFoldControl.button => Align(child: button),
      CalendarFoldControl.both => Column(
          mainAxisSize: MainAxisSize.min,
          children: [handle, button],
        ),
      CalendarFoldControl.hidden => const SizedBox.shrink(),
    };
  }
}
