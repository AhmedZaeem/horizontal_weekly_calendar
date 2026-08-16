import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../configuration/calendar_configuration.dart';
import '../domain/calendar_date_math.dart';
import '../models/calendar_selection.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';
import 'calendar_cupertino_picker.dart';
import 'month_calendar.dart';

/// Cupertino presentation used by [showAdaptiveCalendarPicker].
enum CalendarCupertinoPickerPresentation {
  /// Uses the shared animated month grid with Cupertino controls.
  calendar,

  /// Uses native iOS-style spinning date wheels.
  wheel,
}

/// Material container used by [showAdaptiveCalendarPicker].
enum CalendarMaterialPickerPresentation {
  /// Rounded bottom sheet suited to phones.
  sheet,

  /// Centered dialog suited to tablets and desktop.
  dialog,
}

/// Additive behavior and presentation for the Material adaptive picker.
@immutable
class CalendarMaterialPickerConfiguration {
  /// Creates Material picker configuration.
  const CalendarMaterialPickerConfiguration({
    this.presentation = CalendarMaterialPickerPresentation.sheet,
    this.confirmSelection = false,
    this.showQuickActions = true,
    this.headline = 'Choose a date',
    this.helpText,
    this.backgroundColor,
    this.borderRadius,
    this.motionDuration = const Duration(milliseconds: 280),
  });

  /// Modal surface used on Material platforms.
  final CalendarMaterialPickerPresentation presentation;

  /// Whether a date tap remains provisional until explicit confirmation.
  ///
  /// Defaults to `false` to preserve the original immediate return behavior.
  final bool confirmSelection;

  /// Whether Today, Tomorrow, and next-week actions are visible.
  final bool showQuickActions;

  /// Picker headline.
  final String headline;

  /// Optional supporting instructions.
  final String? helpText;

  /// Optional opaque panel color.
  final Color? backgroundColor;

  /// Optional panel corner radius.
  final double? borderRadius;

  /// Month and provisional-selection motion duration.
  final Duration motionDuration;
}

/// Builds a custom title for [AdaptiveCalendarNavigationBar].
typedef AdaptiveCalendarTitleBuilder = Widget Function(
  BuildContext context,
  DateTime focusedDate,
);

/// Platform-adaptive date navigation with chronological callbacks.
class AdaptiveCalendarNavigationBar extends StatelessWidget {
  /// Creates an adaptive navigation bar.
  const AdaptiveCalendarNavigationBar({
    super.key,
    required this.focusedDate,
    required this.onPrevious,
    required this.onNext,
    this.onToday,
    this.canNavigateBackward = true,
    this.canNavigateForward = true,
    this.showToday = true,
    this.locale,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.titleBuilder,
  });

  /// Focused date used by the standard month-and-year title.
  final DateTime focusedDate;

  /// Navigates to the previous chronological interval.
  final VoidCallback onPrevious;

  /// Navigates to the next chronological interval.
  final VoidCallback onNext;

  /// Optional action that navigates to today.
  final VoidCallback? onToday;

  /// Whether chronological backward navigation is available.
  final bool canNavigateBackward;

  /// Whether chronological forward navigation is available.
  final bool canNavigateForward;

  /// Whether the today action is shown when [onToday] is supplied.
  final bool showToday;

  /// Optional locale override for the title.
  final String? locale;

  /// Shared platform style and theme configuration.
  final CalendarAppearance appearance;

  /// Optional title replacement.
  final AdaptiveCalendarTitleBuilder? titleBuilder;

  @override
  Widget build(BuildContext context) {
    final isCupertino = CalendarStyleResolver.isCupertino(
      appearance.style,
      Theme.of(context).platform,
    );
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final direction = Directionality.of(context);
    final previousIcon = direction == TextDirection.rtl
        ? Icons.chevron_right_rounded
        : Icons.chevron_left_rounded;
    final nextIcon = direction == TextDirection.rtl
        ? Icons.chevron_left_rounded
        : Icons.chevron_right_rounded;
    final title = titleBuilder?.call(context, focusedDate) ??
        Text(
          DateFormat.yMMMM(locale).format(focusedDate),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.headerTextStyle.copyWith(color: theme.textColor),
        );

    return Row(
      children: [
        Expanded(child: title),
        if (showToday && onToday != null)
          isCupertino
              ? _CupertinoNavigationButton(
                  key: const ValueKey('adaptive-calendar-today'),
                  onPressed: onToday,
                  theme: theme,
                  child: const Text('Today'),
                )
              : TextButton(
                  key: const ValueKey('adaptive-calendar-today'),
                  onPressed: onToday,
                  child: const Text('Today'),
                ),
        if (isCupertino) ...[
          _CupertinoNavigationButton(
            key: const ValueKey('adaptive-calendar-previous'),
            onPressed: canNavigateBackward ? onPrevious : null,
            theme: theme,
            child: Icon(previousIcon, size: 22),
          ),
          _CupertinoNavigationButton(
            key: const ValueKey('adaptive-calendar-next'),
            onPressed: canNavigateForward ? onNext : null,
            theme: theme,
            child: Icon(nextIcon, size: 22),
          ),
        ] else ...[
          IconButton(
            key: const ValueKey('adaptive-calendar-previous'),
            constraints: BoxConstraints.tightFor(
              width: theme.minimumInteractiveDimension,
              height: theme.minimumInteractiveDimension,
            ),
            onPressed: canNavigateBackward ? onPrevious : null,
            tooltip: 'Previous',
            icon: Icon(previousIcon),
          ),
          IconButton(
            key: const ValueKey('adaptive-calendar-next'),
            constraints: BoxConstraints.tightFor(
              width: theme.minimumInteractiveDimension,
              height: theme.minimumInteractiveDimension,
            ),
            onPressed: canNavigateForward ? onNext : null,
            tooltip: 'Next',
            icon: Icon(nextIcon),
          ),
        ],
      ],
    );
  }
}

class _CupertinoNavigationButton extends StatelessWidget {
  const _CupertinoNavigationButton({
    super.key,
    required this.onPressed,
    required this.theme,
    required this.child,
  });

  final VoidCallback? onPressed;
  final HorizontalCalendarThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: theme.minimumInteractiveDimension,
        minHeight: theme.minimumInteractiveDimension,
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

/// Shows a bounded adaptive calendar picker and returns one civil date.
///
/// Material-style appearances use a modal bottom sheet. Cupertino and
/// Cupertino-glass appearances use an Apple-style modal popup. Set
/// [cupertinoPresentation] to [CalendarCupertinoPickerPresentation.wheel] for
/// native spinning date wheels. Dismissing or cancelling returns `null`.
Future<DateTime?> showAdaptiveCalendarPicker({
  required BuildContext context,
  required DateTime initialDate,
  CalendarDateRange? bounds,
  bool Function(DateTime date)? selectableDayPredicate,
  CalendarAppearance appearance = const CalendarAppearance(),
  int firstDayOfWeek = DateTime.monday,
  String? locale,
  bool useRootNavigator = false,
  CalendarCupertinoPickerPresentation cupertinoPresentation =
      CalendarCupertinoPickerPresentation.calendar,
  CalendarCupertinoPickerConfiguration cupertinoWheelConfiguration =
      const CalendarCupertinoPickerConfiguration(),
  CalendarCupertinoPickerStyle cupertinoWheelStyle =
      const CalendarCupertinoPickerStyle(),
  CalendarMaterialPickerConfiguration materialConfiguration =
      const CalendarMaterialPickerConfiguration(),
}) {
  assert(
      firstDayOfWeek >= DateTime.monday && firstDayOfWeek <= DateTime.sunday);
  final isCupertino = CalendarStyleResolver.isCupertino(
    appearance.style,
    Theme.of(context).platform,
  );
  if (isCupertino &&
      cupertinoPresentation == CalendarCupertinoPickerPresentation.wheel) {
    return showCalendarCupertinoDatePicker(
      context: context,
      initialValue: initialDate,
      bounds: bounds,
      selectableDayPredicate: selectableDayPredicate,
      configuration: cupertinoWheelConfiguration,
      style: cupertinoWheelStyle,
      appearance: appearance,
      useRootNavigator: useRootNavigator,
    );
  }
  Widget panel(BuildContext panelContext) => _AdaptiveCalendarPickerPanel(
        initialDate: initialDate,
        bounds: bounds,
        selectableDayPredicate: selectableDayPredicate,
        appearance: appearance,
        firstDayOfWeek: firstDayOfWeek,
        locale: locale,
        cupertinoControls: isCupertino,
        materialConfiguration: materialConfiguration,
      );

  if (isCupertino) {
    return showCupertinoModalPopup<DateTime>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: panel(context),
          ),
        ),
      ),
    );
  }
  if (materialConfiguration.presentation ==
      CalendarMaterialPickerPresentation.dialog) {
    return showDialog<DateTime>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: panel(context),
      ),
    );
  }
  return showModalBottomSheet<DateTime>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: panel,
  );
}

class _AdaptiveCalendarPickerPanel extends StatefulWidget {
  const _AdaptiveCalendarPickerPanel({
    required this.initialDate,
    required this.bounds,
    required this.selectableDayPredicate,
    required this.appearance,
    required this.firstDayOfWeek,
    required this.locale,
    required this.cupertinoControls,
    required this.materialConfiguration,
  });

  final DateTime initialDate;
  final CalendarDateRange? bounds;
  final bool Function(DateTime date)? selectableDayPredicate;
  final CalendarAppearance appearance;
  final int firstDayOfWeek;
  final String? locale;
  final bool cupertinoControls;
  final CalendarMaterialPickerConfiguration materialConfiguration;

  @override
  State<_AdaptiveCalendarPickerPanel> createState() =>
      _AdaptiveCalendarPickerPanelState();
}

class _AdaptiveCalendarPickerPanelState
    extends State<_AdaptiveCalendarPickerPanel> {
  late DateTime _selectedDate = _resolveInitialDate();
  late DateTime _focusedMonth = DateTime(
    _selectedDate.year,
    _selectedDate.month,
  );

  DateTime _resolveInitialDate() {
    final normalized = CalendarDateMath.dateOnly(widget.initialDate);
    final bounds = widget.bounds;
    if (bounds == null) return normalized;
    return CalendarDateMath.clamp(normalized, bounds.start, bounds.end);
  }

  bool _selectable(DateTime date) {
    final bounds = widget.bounds;
    return (bounds == null || bounds.contains(date)) &&
        (widget.selectableDayPredicate?.call(date) ?? true);
  }

  bool _canNavigate(int monthOffset) {
    final target = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + monthOffset,
    );
    final bounds = widget.bounds;
    if (bounds == null) return true;
    final first = DateTime(target.year, target.month);
    final last = DateTime(target.year, target.month + 1, 0);
    return !last.isBefore(bounds.start) && !first.isAfter(bounds.end);
  }

  void _moveMonth(int offset) {
    if (!_canNavigate(offset)) return;
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
    });
  }

  void _select(CalendarSelection next) {
    final date = next.selectedDate;
    if (date == null || !_selectable(date)) return;
    if (!widget.cupertinoControls &&
        widget.materialConfiguration.confirmSelection) {
      setState(() {
        _selectedDate = CalendarDateMath.dateOnly(date);
        _focusedMonth = DateTime(date.year, date.month);
      });
      return;
    }
    Navigator.of(context).pop(CalendarDateMath.dateOnly(date));
  }

  void _today() {
    final today = CalendarDateMath.dateOnly(DateTime.now());
    if (_selectable(today)) {
      if (!widget.cupertinoControls &&
          widget.materialConfiguration.confirmSelection) {
        setState(() {
          _selectedDate = today;
          _focusedMonth = DateTime(today.year, today.month);
        });
      } else {
        Navigator.of(context).pop(today);
      }
      return;
    }
    final bounds = widget.bounds;
    final target = bounds == null
        ? today
        : CalendarDateMath.clamp(today, bounds.start, bounds.end);
    setState(() => _focusedMonth = DateTime(target.year, target.month));
  }

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, widget.appearance);
    final pickerAppearance = widget.appearance.copyWith(showHeader: false);
    final materialConfiguration = widget.materialConfiguration;
    final panelRadius =
        materialConfiguration.borderRadius ?? theme.surfaceBorderRadius;
    final selectedLabel =
        DateFormat.yMMMMEEEEd(widget.locale).format(_selectedDate);
    final availableHeight = (MediaQuery.sizeOf(context).height -
            MediaQuery.viewInsetsOf(context).vertical -
            16)
        .clamp(0.0, double.infinity);
    final body = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 560, maxHeight: availableHeight),
      child: SingleChildScrollView(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color:
                materialConfiguration.backgroundColor ?? theme.backgroundColor,
            borderRadius: widget.cupertinoControls ||
                    materialConfiguration.presentation ==
                        CalendarMaterialPickerPresentation.sheet
                ? BorderRadius.vertical(top: Radius.circular(panelRadius))
                : BorderRadius.circular(panelRadius),
            border: Border.all(color: theme.borderColor),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              theme.contentPadding,
              theme.contentPadding,
              theme.contentPadding,
              theme.contentPadding + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.cupertinoControls) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: theme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              materialConfiguration.headline,
                              style: theme.headerTextStyle
                                  .copyWith(color: theme.textColor),
                            ),
                            Text(
                              materialConfiguration.helpText ?? selectedLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.eventTextStyle
                                  .copyWith(color: theme.mutedTextColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (materialConfiguration.showQuickActions)
                    _MaterialQuickActions(
                      selectedDate: _selectedDate,
                      isSelectable: _selectable,
                      onSelected: (date) =>
                          _select(CalendarSelection.single(date)),
                      theme: theme,
                    ),
                  if (materialConfiguration.showQuickActions)
                    const SizedBox(height: 12),
                ],
                AdaptiveCalendarNavigationBar(
                  focusedDate: _focusedMonth,
                  onPrevious: () => _moveMonth(-1),
                  onNext: () => _moveMonth(1),
                  onToday: _today,
                  canNavigateBackward: _canNavigate(-1),
                  canNavigateForward: _canNavigate(1),
                  locale: widget.locale,
                  appearance: widget.appearance,
                ),
                const SizedBox(height: 8),
                MonthCalendar<Object?>(
                  month: _focusedMonth,
                  focusedDate: _selectedDate,
                  selection: CalendarSelection.single(_selectedDate),
                  onFocusedDateChanged: (_) {},
                  onSelectionChanged: (_, next) => _select(next),
                  bounds: widget.bounds,
                  behavior: CalendarBehavior(
                    firstDayOfWeek: widget.firstDayOfWeek,
                    selectableDayPredicate: widget.selectableDayPredicate,
                  ),
                  appearance: pickerAppearance,
                  outsideMonthVisibility:
                      OutsideMonthVisibility.visibleDisabled,
                ),
                const SizedBox(height: 8),
                if (widget.cupertinoControls)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  )
                else
                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    overflowAlignment: OverflowBarAlignment.end,
                    spacing: 8,
                    overflowSpacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      if (materialConfiguration.confirmSelection)
                        FilledButton.icon(
                          key: const ValueKey('adaptive-calendar-confirm'),
                          onPressed: _selectable(_selectedDate)
                              ? () => Navigator.of(context).pop(_selectedDate)
                              : null,
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Choose date'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return Material(type: MaterialType.transparency, child: body);
  }
}

class _MaterialQuickActions extends StatelessWidget {
  const _MaterialQuickActions({
    required this.selectedDate,
    required this.isSelectable,
    required this.onSelected,
    required this.theme,
  });

  final DateTime selectedDate;
  final bool Function(DateTime) isSelectable;
  final ValueChanged<DateTime> onSelected;
  final HorizontalCalendarThemeData theme;

  @override
  Widget build(BuildContext context) {
    final today = CalendarDateMath.dateOnly(DateTime.now());
    final actions = <(String, DateTime)>[
      ('Today', today),
      ('Tomorrow', CalendarDateMath.addDays(today, 1)),
      ('Next week', CalendarDateMath.addDays(today, 7)),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            Builder(builder: (context) {
              final action = actions[index];
              final selected =
                  CalendarDateMath.isSameDay(selectedDate, action.$2);
              return ChoiceChip(
                label: Text(action.$1),
                selected: selected,
                onSelected: isSelectable(action.$2)
                    ? (_) => onSelected(action.$2)
                    : null,
                selectedColor: theme.accentColor.withValues(alpha: .16),
                side: BorderSide(
                  color: selected ? theme.accentColor : theme.borderColor,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
