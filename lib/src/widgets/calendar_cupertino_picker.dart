import 'package:flutter/cupertino.dart';

import '../configuration/calendar_configuration.dart';
import '../domain/calendar_date_math.dart';
import '../models/calendar_selection.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';

/// Supported native wheel modes for [CalendarCupertinoDatePicker].
enum CalendarCupertinoPickerMode {
  /// Month, day, and year wheels.
  date,

  /// Hour, minute, and optional day-period wheels.
  time,

  /// Date and time wheels.
  dateAndTime,

  /// Month and year wheels.
  monthYear,
}

/// Immutable Cupertino wheel and reporting configuration.
@immutable
class CalendarCupertinoPickerConfiguration {
  /// Creates Cupertino picker behavior.
  const CalendarCupertinoPickerConfiguration({
    this.mode = CalendarCupertinoPickerMode.date,
    this.minuteInterval = 1,
    this.use24HourFormat = false,
    this.showDayOfWeek = false,
    this.showTimeSeparator = false,
    this.itemExtent = 32,
    this.changeReportingBehavior = ChangeReportingBehavior.onScrollEnd,
  })  : assert(minuteInterval > 0 && 60 % minuteInterval == 0),
        assert(itemExtent > 0);

  /// Native wheel mode.
  final CalendarCupertinoPickerMode mode;

  /// Positive minute increment that divides 60.
  final int minuteInterval;

  /// Whether time wheels use a 24-hour clock.
  final bool use24HourFormat;

  /// Whether date wheels include weekday labels.
  ///
  /// The native picker only supports weekday labels in
  /// [CalendarCupertinoPickerMode.date]; other modes ignore this flag.
  final bool showDayOfWeek;

  /// Whether time wheels show the native separator.
  final bool showTimeSeparator;

  /// Height of each wheel item.
  final double itemExtent;

  /// Whether changes report during movement or after wheels settle.
  final ChangeReportingBehavior changeReportingBehavior;
}

/// Visual configuration for inline and modal Cupertino date wheels.
@immutable
class CalendarCupertinoPickerStyle {
  /// Creates Cupertino wheel presentation.
  const CalendarCupertinoPickerStyle({
    this.height = 216,
    this.modalHeight = 356,
    this.backgroundColor,
    this.modalBackgroundColor,
    this.barrierColor = const Color(0x66000000),
    this.selectionOverlayColor,
    this.borderRadius = 28,
    this.actionPadding = const EdgeInsets.symmetric(horizontal: 12),
  })  : assert(height >= 160),
        assert(modalHeight >= 280),
        assert(borderRadius >= 0);

  /// Inline wheel height.
  final double height;

  /// Total modal sheet height.
  final double modalHeight;

  /// Inline wheel background override.
  final Color? backgroundColor;

  /// Modal surface background override.
  final Color? modalBackgroundColor;

  /// Modal barrier color.
  final Color barrierColor;

  /// Selection-row fill override.
  final Color? selectionOverlayColor;

  /// Top modal corner radius.
  final double borderRadius;

  /// Horizontal padding around modal actions.
  final EdgeInsetsGeometry actionPadding;
}

/// Styled controlled wrapper around Flutter's native Cupertino date wheels.
class CalendarCupertinoDatePicker extends StatelessWidget {
  /// Creates an inline Cupertino picker.
  const CalendarCupertinoDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.bounds,
    this.selectableDayPredicate,
    this.configuration = const CalendarCupertinoPickerConfiguration(),
    this.style = const CalendarCupertinoPickerStyle(),
    this.appearance = const CalendarAppearance(
      style: CalendarStyle.cupertino,
      showHeader: false,
    ),
  });

  /// Current controlled value.
  final DateTime value;

  /// Reports a valid wheel value.
  final ValueChanged<DateTime> onChanged;

  /// Optional inclusive civil-date bounds.
  final CalendarDateRange? bounds;

  /// Optional enabled-day rule.
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Native wheel behavior.
  final CalendarCupertinoPickerConfiguration configuration;

  /// Wheel and modal presentation.
  final CalendarCupertinoPickerStyle style;

  /// Shared calendar tokens used for default colors.
  final CalendarAppearance appearance;

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, appearance);
    final initial = _clampValue(value, bounds);
    final background = style.backgroundColor ?? theme.backgroundColor;
    return SizedBox(
      height: style.height,
      child: CupertinoTheme(
        data: CupertinoTheme.of(context).copyWith(
          primaryColor: theme.accentColor,
          scaffoldBackgroundColor: background,
        ),
        child: CupertinoDatePicker(
          key: ValueKey(
            'cupertino-picker-${initial.microsecondsSinceEpoch}-'
            '${configuration.mode.name}',
          ),
          mode: _nativeMode(configuration.mode),
          initialDateTime: initial,
          minimumDate: bounds?.start,
          maximumDate: bounds == null
              ? null
              : DateTime(
                  bounds!.end.year,
                  bounds!.end.month,
                  bounds!.end.day,
                  23,
                  59,
                  59,
                ),
          minuteInterval: configuration.minuteInterval,
          use24hFormat: configuration.use24HourFormat,
          // The native picker only accepts weekday labels in date mode, so a
          // configuration that asks for them in another mode degrades instead
          // of failing an assertion inside Flutter.
          showDayOfWeek: configuration.showDayOfWeek &&
              configuration.mode == CalendarCupertinoPickerMode.date,
          showTimeSeparator: configuration.showTimeSeparator,
          itemExtent: configuration.itemExtent,
          backgroundColor: background,
          selectableDayPredicate: selectableDayPredicate,
          changeReportingBehavior: configuration.changeReportingBehavior,
          selectionOverlayBuilder: (context,
              {required columnCount, required selectedIndex}) {
            final capStart = selectedIndex == 0;
            final capEnd = selectedIndex == columnCount - 1;
            const radius = Radius.circular(10);
            return Container(
              margin: EdgeInsetsDirectional.only(
                start: capStart ? 8 : 0,
                end: capEnd ? 8 : 0,
              ),
              decoration: BoxDecoration(
                color: style.selectionOverlayColor ??
                    theme.accentColor.withValues(alpha: .12),
                borderRadius: BorderRadiusDirectional.horizontal(
                  start: capStart ? radius : Radius.zero,
                  end: capEnd ? radius : Radius.zero,
                ),
              ),
            );
          },
          onDateTimeChanged: (next) {
            final resolved = _normalizeForMode(next, configuration.mode);
            if (bounds != null && !bounds!.contains(resolved)) return;
            if (!(selectableDayPredicate?.call(resolved) ?? true)) return;
            onChanged(resolved);
          },
        ),
      ),
    );
  }
}

/// Shows a styled Cupertino wheel picker with provisional confirmation.
Future<DateTime?> showCalendarCupertinoDatePicker({
  required BuildContext context,
  required DateTime initialValue,
  CalendarDateRange? bounds,
  bool Function(DateTime date)? selectableDayPredicate,
  CalendarCupertinoPickerConfiguration configuration =
      const CalendarCupertinoPickerConfiguration(),
  CalendarCupertinoPickerStyle style = const CalendarCupertinoPickerStyle(),
  CalendarAppearance appearance = const CalendarAppearance(
    style: CalendarStyle.cupertino,
    showHeader: false,
  ),
  String cancelLabel = 'Cancel',
  String todayLabel = 'Today',
  String confirmLabel = 'Done',
  bool showToday = true,
  bool useRootNavigator = true,
}) {
  var provisional = _clampValue(initialValue, bounds);
  return showCupertinoModalPopup<DateTime>(
    context: context,
    useRootNavigator: useRootNavigator,
    semanticsDismissible: true,
    barrierColor: style.barrierColor,
    builder: (modalContext) {
      final theme = CalendarThemeResolver.resolve(modalContext, appearance);
      final modalColor = _opaqueSurface(
        style.modalBackgroundColor ?? theme.backgroundColor,
        CupertinoTheme.brightnessOf(modalContext),
      );
      return StatefulBuilder(builder: (context, setModalState) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(style.borderRadius),
            ),
            child: ColoredBox(
              key: const ValueKey('calendar-cupertino-modal-background'),
              color: modalColor,
              child: SizedBox(
                width: double.infinity,
                height: style.modalHeight,
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: style.actionPadding,
                        child: Row(
                          children: [
                            CupertinoButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(cancelLabel),
                            ),
                            if (showToday)
                              Expanded(
                                child: CupertinoButton(
                                  onPressed: () => setModalState(() {
                                    provisional =
                                        _clampValue(DateTime.now(), bounds);
                                  }),
                                  child: Text(todayLabel),
                                ),
                              )
                            else
                              const Spacer(),
                            CupertinoButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(provisional),
                              child: Text(
                                confirmLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CalendarCupertinoDatePicker(
                          value: provisional,
                          bounds: bounds,
                          selectableDayPredicate: selectableDayPredicate,
                          configuration: configuration,
                          style: CalendarCupertinoPickerStyle(
                            height: style.height,
                            modalHeight: style.modalHeight,
                            backgroundColor: modalColor,
                            modalBackgroundColor: style.modalBackgroundColor,
                            barrierColor: style.barrierColor,
                            selectionOverlayColor: style.selectionOverlayColor,
                            borderRadius: style.borderRadius,
                            actionPadding: style.actionPadding,
                          ),
                          appearance: appearance,
                          onChanged: (next) => setModalState(() {
                            provisional = next;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    },
  );
}

Color _opaqueSurface(Color color, Brightness brightness) {
  if (color.a == 1) return color;
  final base = brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);
  return Color.alphaBlend(color, base).withValues(alpha: 1);
}

CupertinoDatePickerMode _nativeMode(CalendarCupertinoPickerMode mode) {
  return switch (mode) {
    CalendarCupertinoPickerMode.date => CupertinoDatePickerMode.date,
    CalendarCupertinoPickerMode.time => CupertinoDatePickerMode.time,
    CalendarCupertinoPickerMode.dateAndTime =>
      CupertinoDatePickerMode.dateAndTime,
    CalendarCupertinoPickerMode.monthYear => CupertinoDatePickerMode.monthYear,
  };
}

DateTime _normalizeForMode(DateTime value, CalendarCupertinoPickerMode mode) {
  return switch (mode) {
    CalendarCupertinoPickerMode.date => CalendarDateMath.dateOnly(value),
    CalendarCupertinoPickerMode.monthYear => value.isUtc
        ? DateTime.utc(value.year, value.month)
        : DateTime(value.year, value.month),
    CalendarCupertinoPickerMode.time ||
    CalendarCupertinoPickerMode.dateAndTime =>
      value,
  };
}

DateTime _clampValue(DateTime value, CalendarDateRange? bounds) {
  if (bounds == null) return value;
  final date = CalendarDateMath.clamp(value, bounds.start, bounds.end);
  if (CalendarDateMath.isSameDay(date, value)) return value;
  return date;
}
