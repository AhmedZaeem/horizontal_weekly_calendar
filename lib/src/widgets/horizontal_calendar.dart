import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../configuration/calendar_configuration.dart';
import '../controller/calendar_event_coordinator.dart';
import '../controller/horizontal_calendar_controller.dart';
import '../domain/calendar_date_math.dart';
import '../domain/calendar_event_layout.dart';
import '../domain/calendar_selection_logic.dart';
import '../models/calendar_day_state.dart';
import '../models/calendar_event.dart';
import '../models/calendar_selection.dart';
import '../models/calendar_visible_interval.dart';
import '../theme/calendar_theme_resolver.dart';
import 'calendar_components.dart';
import 'calendar_motion_primitives.dart';
import 'calendar_page_motion.dart';

/// Called after an accepted action proposes a controlled selection.
typedef CalendarSelectionChanged = void Function(
  CalendarSelection previous,
  CalendarSelection next,
);

/// Adaptive horizontal calendar with a simple default and a complete controlled
/// API.
class HorizontalCalendar<T> extends StatefulWidget {
  /// Creates the quick-start single-date calendar.
  const HorizontalCalendar({
    super.key,
    required DateTime selectedDate,
    required this.onDateSelected,
    this.controller,
    this.bounds,
    this.behavior = const CalendarBehavior(),
    this.appearance = const CalendarAppearance(),
    this.events = const [],
    this.eventSource,
    this.builders = const CalendarBuilders(),
  })  : selectedDate = selectedDate,
        focusedDate = selectedDate,
        selection = null,
        onFocusedDateChanged = null,
        onSelectionChanged = null;

  /// Creates the fully controlled calendar.
  const HorizontalCalendar.controlled({
    super.key,
    required this.focusedDate,
    required this.selection,
    required this.onFocusedDateChanged,
    required this.onSelectionChanged,
    this.controller,
    this.bounds,
    this.behavior = const CalendarBehavior(),
    this.appearance = const CalendarAppearance(),
    this.events = const [],
    this.eventSource,
    this.builders = const CalendarBuilders(),
  })  : assert(selection != null),
        selectedDate = null,
        onDateSelected = null;

  /// Selected date used by the quick-start constructor.
  final DateTime? selectedDate;

  /// Called by the quick-start constructor after an accepted date tap.
  final ValueChanged<DateTime>? onDateSelected;

  /// Controlled focused date, or the quick-start selected date.
  final DateTime focusedDate;

  /// Advanced controlled selection; `null` for the quick-start constructor.
  final CalendarSelection? selection;

  /// Called when advanced navigation proposes a different focused date.
  final ValueChanged<DateTime>? onFocusedDateChanged;

  /// Called when advanced interaction proposes a different selection.
  final CalendarSelectionChanged? onSelectionChanged;

  /// Optional imperative navigation controller.
  final HorizontalCalendarController? controller;

  /// Inclusive navigation and selection bounds.
  final CalendarDateRange? bounds;

  /// Date-window and interaction configuration.
  final CalendarBehavior behavior;

  /// Visual style, density, indicator, and theme configuration.
  final CalendarAppearance appearance;

  /// Synchronous typed events used by day indicators.
  final List<CalendarEvent<T>> events;

  /// Optional asynchronous event source for the visible interval.
  final CalendarEventSource<T>? eventSource;

  /// Focused presentation builder overrides.
  final CalendarBuilders<T> builders;

  bool get _isQuickStart => selection == null;

  CalendarSelection get _effectiveSelection =>
      selection ?? CalendarSelection.single(selectedDate);

  @override
  State<HorizontalCalendar<T>> createState() => _HorizontalCalendarState<T>();
}

class _HorizontalCalendarState<T> extends State<HorizontalCalendar<T>> {
  HorizontalCalendarController? _ownedController;
  CalendarEventCoordinator<T>? _eventCoordinator;
  final FocusNode _focusNode = FocusNode(debugLabel: 'HorizontalCalendar');
  late DateTime _lastControllerDate;
  late DateTime _quickStartFocus;
  bool _controllerSyncScheduled = false;

  HorizontalCalendarController get _controller =>
      widget.controller ?? _ownedController!;

  DateTime get _focusedDate => widget._isQuickStart
      ? _quickStartFocus
      : CalendarDateMath.dateOnly(widget.focusedDate);

  @override
  void initState() {
    super.initState();
    _quickStartFocus = CalendarDateMath.dateOnly(widget.focusedDate);
    _attachController();
    _attachEventSource();
  }

  @override
  void didUpdateWidget(covariant HorizontalCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._isQuickStart &&
        !CalendarDateMath.isSameDay(
          oldWidget.focusedDate,
          widget.focusedDate,
        )) {
      _quickStartFocus = CalendarDateMath.dateOnly(widget.focusedDate);
    }
    if (oldWidget.controller != widget.controller ||
        oldWidget.behavior.visibleDayCount != widget.behavior.visibleDayCount ||
        oldWidget.bounds != widget.bounds) {
      _detachController();
      _attachController();
    }
    final desiredFocus = _focusedDate;
    _scheduleControllerSync();
    if (oldWidget.eventSource != widget.eventSource) {
      _detachEventSource();
      _attachEventSource();
    } else {
      _eventCoordinator?.load(_visibleInterval(desiredFocus));
    }
  }

  void _attachController() {
    _ownedController = widget.controller == null
        ? HorizontalCalendarController(
            focusedDate: _focusedDate,
            minimumDate: widget.bounds?.start,
            maximumDate: widget.bounds?.end,
            visibleDayCount: widget.behavior.visibleDayCount,
            selection: widget._effectiveSelection,
          )
        : null;
    _lastControllerDate = _controller.focusedDate;
    _controller.addListener(_handleControllerChanged);
    _scheduleControllerSync();
  }

  void _scheduleControllerSync() {
    if (_controllerSyncScheduled) return;
    _controllerSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controllerSyncScheduled = false;
      if (!mounted) return;

      final controller = _controller;
      final desiredFocus = _focusedDate;
      if (!CalendarDateMath.isSameDay(controller.focusedDate, desiredFocus)) {
        _lastControllerDate = desiredFocus;
        controller.focusDate(desiredFocus, animate: false);
      }
      controller.updateSelection(widget._effectiveSelection);
    });
  }

  void _detachController() {
    _controller.removeListener(_handleControllerChanged);
    _ownedController?.dispose();
    _ownedController = null;
  }

  void _handleControllerChanged() {
    final nextDate = _controller.focusedDate;
    if (!CalendarDateMath.isSameDay(_lastControllerDate, nextDate)) {
      _lastControllerDate = nextDate;
      if (widget._isQuickStart) {
        setState(() => _quickStartFocus = nextDate);
      } else {
        widget.onFocusedDateChanged!(nextDate);
      }
      _eventCoordinator?.load(_visibleInterval(nextDate));
    }
  }

  CalendarVisibleInterval _visibleInterval(DateTime focus) {
    final start = widget.behavior.visibleDayCount == 7
        ? CalendarDateMath.startOfWeek(
            focus,
            widget.behavior.firstDayOfWeek,
          )
        : focus;
    return CalendarVisibleInterval(
      start,
      CalendarDateMath.addDays(start, widget.behavior.visibleDayCount),
    );
  }

  void _attachEventSource() {
    final source = widget.eventSource;
    if (source == null) return;
    _eventCoordinator = CalendarEventCoordinator<T>(source: source)
      ..addListener(_handleEventSourceChanged)
      ..load(_visibleInterval(_focusedDate));
  }

  void _detachEventSource() {
    _eventCoordinator
      ?..removeListener(_handleEventSourceChanged)
      ..dispose();
    _eventCoordinator = null;
  }

  void _handleEventSourceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _detachController();
    _detachEventSource();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, widget.appearance);
    final focus = _focusedDate;
    final start = widget.behavior.visibleDayCount == 7
        ? CalendarDateMath.startOfWeek(
            focus,
            widget.behavior.firstDayOfWeek,
          )
        : focus;
    final dates = CalendarDateMath.days(
      start,
      widget.behavior.visibleDayCount,
    );
    final interval = CalendarVisibleInterval(
      start,
      CalendarDateMath.addDays(start, widget.behavior.visibleDayCount),
    );
    final eventsByDate = _eventsByDate(interval);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final headerState = _headerState(interval);

    final direction = Directionality.of(context);
    return Shortcuts(
      shortcuts: widget.behavior.enableKeyboard
          ? _keyboardShortcuts(direction)
          : const {},
      child: Actions(
        actions: {
          _MoveCalendarFocusIntent: CallbackAction<_MoveCalendarFocusIntent>(
            onInvoke: (intent) {
              _moveFocus(intent.dayOffset);
              return null;
            },
          ),
          _SelectFocusedDateIntent: CallbackAction<_SelectFocusedDateIntent>(
            onInvoke: (_) {
              if (_isSelectable(_focusedDate)) _select(_focusedDate);
              return null;
            },
          ),
          _FocusTodayIntent: CallbackAction<_FocusTodayIntent>(
            onInvoke: (_) {
              _controller.today();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          child: CalendarDragPager(
            enabled: widget.behavior.enableGestures &&
                widget.behavior.scrolling == CalendarScrollBehavior.page,
            motion: widget.appearance.motion,
            canStepBackward: headerState.canNavigateBackward,
            canStepForward: headerState.canNavigateForward,
            onStep: (step) => step == CalendarPageStep.next
                ? _controller.next()
                : _controller.previous(),
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => _focusNode.requestFocus(),
              // A surfaceless calendar composes inside a container the
              // application already draws, and gives its dates that
              // container's full width instead of nesting a second card.
              child: DecoratedBox(
                decoration: widget.appearance.showSurface
                    ? BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius:
                            BorderRadius.circular(theme.surfaceBorderRadius),
                        border: Border.all(color: theme.borderColor),
                        boxShadow: theme.elevation == 0
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .08),
                                  blurRadius: 8 * theme.elevation,
                                  offset: Offset(0, 2 * theme.elevation),
                                ),
                              ],
                      )
                    : const BoxDecoration(),
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: EdgeInsets.all(
                      widget.appearance.showSurface ? theme.contentPadding : 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.appearance.showHeader)
                          widget.builders.headerBuilder
                                  ?.call(context, headerState) ??
                              CalendarHeader(
                                state: headerState,
                                theme: theme,
                                locale: locale,
                              ),
                        SizedBox(
                          height: theme.minimumInteractiveDimension +
                              42 * textScale,
                          child: CalendarPageMotionView(
                            pageKey: _civilKey(start),
                            motion: widget.appearance.motion,
                            navigationDirection:
                                _controller.lastNavigationDirection,
                            textDirection: direction,
                            child: LayoutBuilder(
                              key: ValueKey(_civilKey(start)),
                              builder: (context, constraints) {
                                Widget cell(int index) {
                                  final date = dates[index];
                                  final state = _dayState(
                                    date,
                                    focus,
                                    eventsByDate[_civilKey(date)] ?? const [],
                                    locale,
                                  );
                                  final identifier = _dayIdentifier(date);
                                  return CalendarDayCell<T>(
                                    key: ValueKey(identifier),
                                    state: state,
                                    theme: theme,
                                    eventIndicatorStyle:
                                        widget.appearance.eventIndicatorStyle,
                                    eventIndicatorBuilder:
                                        widget.builders.eventIndicatorBuilder,
                                    contentBuilder: widget.builders.dayBuilder,
                                    semanticIdentifier: identifier,
                                    locale: locale,
                                    motion: widget.appearance.motion,
                                    motionIndex: index,
                                    onTap: state.isDisabled
                                        ? null
                                        : () => _select(date),
                                  );
                                }

                                // A page of dates that fits is laid out edge to
                                // edge, so the last day is never clipped by a
                                // scroll viewport the user has no reason to
                                // discover. Narrower viewports fall back to a
                                // scrolling strip.
                                final available = constraints.maxWidth;
                                final required = dates.length *
                                    theme.minimumInteractiveDimension;
                                if (available.isFinite &&
                                    required <= available) {
                                  final spacing = dates.length < 2
                                      ? 0.0
                                      : ((available - required) /
                                              (dates.length - 1))
                                          .clamp(0.0, theme.daySpacing);
                                  return Row(
                                    children: [
                                      for (var index = 0;
                                          index < dates.length;
                                          index += 1) ...[
                                        if (index > 0) SizedBox(width: spacing),
                                        Expanded(child: cell(index)),
                                      ],
                                    ],
                                  );
                                }
                                return ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  // Paging owns the horizontal gesture, so the
                                  // strip never overscroll-bounces against the
                                  // page follow.
                                  physics: !widget.behavior.enableGestures
                                      ? const NeverScrollableScrollPhysics()
                                      : widget.behavior.scrolling ==
                                              CalendarScrollBehavior.page
                                          ? const ClampingScrollPhysics()
                                          : null,
                                  itemCount: dates.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(width: theme.daySpacing),
                                  itemBuilder: (context, index) => cell(index),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<ShortcutActivator, Intent> _keyboardShortcuts(TextDirection direction) {
    final leftOffset = direction == TextDirection.rtl ? 1 : -1;
    return {
      const SingleActivator(LogicalKeyboardKey.arrowLeft):
          _MoveCalendarFocusIntent(leftOffset),
      const SingleActivator(LogicalKeyboardKey.arrowRight):
          _MoveCalendarFocusIntent(-leftOffset),
      const SingleActivator(LogicalKeyboardKey.arrowUp):
          const _MoveCalendarFocusIntent(-7),
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const _MoveCalendarFocusIntent(7),
      const SingleActivator(LogicalKeyboardKey.pageUp):
          _MoveCalendarFocusIntent(-widget.behavior.visibleDayCount),
      const SingleActivator(LogicalKeyboardKey.pageDown):
          _MoveCalendarFocusIntent(widget.behavior.visibleDayCount),
      const SingleActivator(LogicalKeyboardKey.enter):
          const _SelectFocusedDateIntent(),
      const SingleActivator(LogicalKeyboardKey.space):
          const _SelectFocusedDateIntent(),
      const SingleActivator(LogicalKeyboardKey.keyT): const _FocusTodayIntent(),
    };
  }

  void _moveFocus(int dayOffset) {
    _controller.focusDate(
      CalendarDateMath.addDays(_focusedDate, dayOffset),
    );
  }

  Map<int, List<CalendarEvent<T>>> _eventsByDate(
    CalendarVisibleInterval interval,
  ) {
    final grouped = <int, List<CalendarEvent<T>>>{};
    final events = [
      ...widget.events,
      ...?_eventCoordinator?.snapshot.events,
    ];
    for (final segment in CalendarEventLayout.segment(events, interval)) {
      grouped.putIfAbsent(_civilKey(segment.date), () => []).add(segment.event);
    }
    return grouped;
  }

  CalendarHeaderState _headerState(CalendarVisibleInterval interval) {
    final bounds = widget.bounds;
    return CalendarHeaderState(
      focusedDate: _focusedDate,
      visibleInterval: interval,
      canNavigateBackward: bounds == null ||
          CalendarDateMath.civilDayDifference(
                bounds.start,
                interval.start,
              ) >
              0,
      canNavigateForward: bounds == null ||
          CalendarDateMath.civilDayDifference(
                interval.end,
                bounds.end,
              ) >=
              0,
      onPrevious: _controller.previous,
      onNext: _controller.next,
      onToday: _controller.today,
    );
  }

  CalendarDayState<T> _dayState(
    DateTime date,
    DateTime focus,
    List<CalendarEvent<T>> events,
    String? locale,
  ) {
    final selection = widget._effectiveSelection;
    final disabled = !_isSelectable(date);
    final isToday = CalendarDateMath.isSameDay(date, DateTime.now());
    final isSelected = selection.contains(date);
    final stateWords = <String>[
      if (isToday) 'today',
      if (isSelected) 'selected',
      if (disabled) 'disabled',
      if (events.isNotEmpty)
        '${events.length} ${events.length == 1 ? 'event' : 'events'}',
    ];
    final fullDate = DateFormat.yMMMMEEEEd(locale).format(date);
    return CalendarDayState<T>(
      date: date,
      isToday: isToday,
      isSelected: isSelected,
      isFocused: CalendarDateMath.isSameDay(date, focus),
      isDisabled: disabled,
      isOutsideInterval: false,
      rangePosition: CalendarSelectionLogic.rangePosition(selection, date),
      events: List.unmodifiable(events),
      semanticLabel:
          stateWords.isEmpty ? fullDate : '$fullDate, ${stateWords.join(', ')}',
    );
  }

  bool _isSelectable(DateTime date) {
    final bounds = widget.bounds;
    if (bounds != null && !bounds.contains(date)) return false;
    return widget.behavior.selectableDayPredicate?.call(date) ?? true;
  }

  void _select(DateTime date) {
    final previous = widget._effectiveSelection;
    final next = CalendarSelectionLogic.select(
      previous,
      date,
      behavior: widget.behavior.selectionBehavior,
    );
    if (next == previous) return;
    if (widget.behavior.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    if (widget._isQuickStart) {
      widget.onDateSelected!(next.selectedDate!);
    } else {
      widget.onSelectionChanged!(previous, next);
    }
  }
}

String _dayIdentifier(DateTime date) {
  return 'calendar-day-${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

int _civilKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

class _MoveCalendarFocusIntent extends Intent {
  const _MoveCalendarFocusIntent(this.dayOffset);

  final int dayOffset;
}

class _SelectFocusedDateIntent extends Intent {
  const _SelectFocusedDateIntent();
}

class _FocusTodayIntent extends Intent {
  const _FocusTodayIntent();
}
