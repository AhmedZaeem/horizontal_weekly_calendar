import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../weekly_calendar.dart';

/// A builder function type for creating a custom header widget for the weekly calendar.
typedef TableWeeklyCalendarHeaderBuilder = Widget Function(
    BuildContext context,
    DateTime currentDate,
    VoidCallback onPreviousMonth,
    VoidCallback onNextMonth);

/// Represents a date with an associated color to highlight or focus it in the calendar.
class FocusDate {
  /// The date to be focused or highlighted.
  final DateTime date;

  /// The background color used to highlight the [date].
  final Color backgroundColor;

  /// The foreground (text) color for the [date].
  final Color foregroundColor;

  /// Creates a [FocusDate] with the given [date], [backgroundColor], and [foregroundColor].
  const FocusDate({
    required this.date,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

/// A widget that displays a table-based weekly calendar with customizable styles, focus dates, and navigation.
class TableWeeklyCalendar extends StatefulWidget {
  /// The initial date to display when the calendar is first shown.
  final DateTime initialDate;

  /// The currently selected date in the calendar.
  final DateTime selectedDate;

  /// Called when a date is selected by the user.
  final ValueChanged<DateTime> onDateSelected;

  /// Called when the displayed month is changed.
  final ValueChanged<DateTime> onMonthChanged;

  /// Called when a visible day that is NOT in the current month is tapped.
  final ValueChanged<DateTime>? onVisibleDateTapped;

  /// The style configuration for the calendar appearance.
  final HorizontalCalendarStyle calendarStyle;

  /// The day of the week to start the calendar.
  final Weekday? startingDay;

  /// A list of dates to be focused or highlighted in the calendar.
  final List<FocusDate> focusDates;

  /// Whether to show the month header above the calendar.
  final bool showMonthHeader;

  /// The icon to use for navigating to the previous month.
  final IconData? previousMonthIcon;

  /// The icon to use for navigating to the next month.
  final IconData? nextMonthIcon;

  /// The color of the navigation icons.
  final Color? iconColor;

  /// Whether to enable animations when changing months or selecting dates.
  final bool enableAnimations;

  /// A builder for customizing the header widget.
  final TableWeeklyCalendarHeaderBuilder? headerBuilder;

  /// Whether to use the color from the [FocusDate] for focus dates.
  final bool useFocusDateColor;

  /// The padding around the calendar table.
  final EdgeInsetsGeometry tablePadding;

  /// The horizontal spacing between day cells in the calendar.
  final double horizontalSpacing;

  /// The vertical spacing between week rows in the calendar.
  final double verticalSpacing;

  /// Minimum selectable date
  final DateTime? minDate;

  /// Maximum selectable date
  final DateTime? maxDate;

  /// Creates a [TableWeeklyCalendar] widget.
  const TableWeeklyCalendar({
    super.key,
    required this.initialDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.onVisibleDateTapped,
    this.calendarStyle = const HorizontalCalendarStyle(),
    this.startingDay,
    this.focusDates = const [],
    this.showMonthHeader = true,
    this.previousMonthIcon = Icons.chevron_left,
    this.nextMonthIcon = Icons.chevron_right,
    this.iconColor,
    this.enableAnimations = true,
    this.headerBuilder,
    this.useFocusDateColor = true,
    this.tablePadding = const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    this.horizontalSpacing = 0.0,
    this.verticalSpacing = 0.0,
    this.minDate,
    this.maxDate,
  });

  @override
  State<TableWeeklyCalendar> createState() => _TableWeeklyCalendarState();
}

class _TableWeeklyCalendarState extends State<TableWeeklyCalendar> {
  late DateTime _currentDate;
  late Map<DateTime, FocusDate> _focusDateMap;
  late PageController _pageController;
  int _currentMonthPage = 0;

  void _updateFocusDateMap() {
    _focusDateMap = {};
    for (var focusDate in widget.focusDates) {
      final key = DateTime(
        focusDate.date.year,
        focusDate.date.month,
        focusDate.date.day,
      );
      _focusDateMap[key] = focusDate;
    }
  }

  FocusDate? _getFocusDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _focusDateMap[key];
  }

  bool _isFocusDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _focusDateMap.containsKey(key);
  }

  bool _isDateDisabled(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (widget.minDate != null) {
      final normalizedMin = DateTime(
          widget.minDate!.year, widget.minDate!.month, widget.minDate!.day);
      if (normalizedDate.isBefore(normalizedMin)) return true;
    }
    if (widget.maxDate != null) {
      final normalizedMax = DateTime(
          widget.maxDate!.year, widget.maxDate!.month, widget.maxDate!.day);
      if (normalizedDate.isAfter(normalizedMax)) return true;
    }
    return false;
  }

  bool _canNavigateToPreviousMonth() {
    if (widget.minDate == null) return true;
    final previousMonth = DateTime(_currentDate.year, _currentDate.month - 1);
    final lastDayOfPreviousMonth = DateTime(previousMonth.year, previousMonth.month + 1, 0);
    final normalizedMin = DateTime(widget.minDate!.year, widget.minDate!.month, widget.minDate!.day);
    return !lastDayOfPreviousMonth.isBefore(normalizedMin);
  }

  bool _canNavigateToNextMonth() {
    if (widget.maxDate == null) return true;
    final nextMonth = DateTime(_currentDate.year, _currentDate.month + 1);
    final firstDayOfNextMonth = DateTime(nextMonth.year, nextMonth.month, 1);
    final normalizedMax = DateTime(widget.maxDate!.year, widget.maxDate!.month, widget.maxDate!.day);
    return !firstDayOfNextMonth.isAfter(normalizedMax);
  }

  @override
  void initState() {
    super.initState();
    _currentDate =
        DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    _updateFocusDateMap();
    _currentMonthPage = (_currentDate.month - 1).clamp(0, 11);
    _pageController = PageController(initialPage: _currentMonthPage);
  }

  @override
  void didUpdateWidget(TableWeeklyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startingDay != widget.startingDay ||
        oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.focusDates != widget.focusDates) {
      _updateFocusDateMap();
    }
  }

  void _handleDaySelection(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    if (_isDateDisabled(normalizedDay)) return;
    widget.onDateSelected(normalizedDay);
    final selectedMonth = DateTime(normalizedDay.year, normalizedDay.month);
    final currentMonth = DateTime(_currentDate.year, _currentDate.month);
    if (selectedMonth != currentMonth) {
      setState(() {
        _currentDate = DateTime(normalizedDay.year, normalizedDay.month, 1);
        _currentMonthPage = _currentDate.month - 1;
        _pageController.jumpToPage(_currentMonthPage);
      });
      widget.onMonthChanged(_currentDate);
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentMonthPage = page;
      _currentDate = DateTime(_currentDate.year, page + 1, 1);
    });
    widget.onMonthChanged(_currentDate);
  }

  Widget _buildHeader() {
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(
        context,
        _currentDate,
        () {
          if (_currentMonthPage > 0 && _canNavigateToPreviousMonth()) {
            _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }
        },
        () {
          if (_currentMonthPage < 11 && _canNavigateToNextMonth()) {
            _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }
        },
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              widget.previousMonthIcon,
              color: _canNavigateToPreviousMonth()
                  ? widget.iconColor
                  : (widget.iconColor ?? Theme.of(context).iconTheme.color)?.withOpacity(0.3),
              size: 24,
            ),
            onPressed: _canNavigateToPreviousMonth()
                ? () {
              if (_currentMonthPage > 0) {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease);
              }
            }
                : null,
          ),
          Text(
            DateFormat('MMMM y').format(_currentDate),
            style: widget.calendarStyle.monthHeaderStyle,
          ),
          IconButton(
            icon: Icon(
              widget.nextMonthIcon,
              color: _canNavigateToNextMonth()
                  ? widget.iconColor
                  : (widget.iconColor ?? Theme.of(context).iconTheme.color)?.withOpacity(0.3),
              size: 24,
            ),
            onPressed: _canNavigateToNextMonth()
                ? () {
              if (_currentMonthPage < 11) {
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease);
              }
            }
                : null,
          ),
        ],
      ),
    );
  }

  List<List<DateTime>> _generateWeeks(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final startDay = widget.startingDay?.value ?? DateTime.monday;

    int firstWeekday = firstDayOfMonth.weekday;
    int daysToSubtract = (firstWeekday - startDay) % 7;
    DateTime firstCalendarDay = DateTime(firstDayOfMonth.year,
        firstDayOfMonth.month, firstDayOfMonth.day - daysToSubtract);

    int lastWeekday = lastDayOfMonth.weekday;
    int daysToAdd = (startDay + 6 - lastWeekday) % 7;
    DateTime lastCalendarDay = DateTime(lastDayOfMonth.year,
        lastDayOfMonth.month, lastDayOfMonth.day + daysToAdd);

    List<DateTime> days = [];
    int totalDays = lastCalendarDay.difference(firstCalendarDay).inDays + 1;

    for (int i = 0; i < totalDays; i++) {
      DateTime currentDay = DateTime(firstCalendarDay.year,
          firstCalendarDay.month, firstCalendarDay.day + i);
      days.add(currentDay);
    }

    List<List<DateTime>> weeks = [];
    for (int i = 0; i < days.length; i += 7) {
      if (i + 7 <= days.length) {
        weeks.add(days.sublist(i, i + 7));
      }
    }

    return weeks;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showMonthHeader) _buildHeader(),
        Padding(
          padding: widget.tablePadding,
          child: SizedBox(
            height: (widget.calendarStyle.dayIndicatorSize +
                    widget.verticalSpacing) *
                7,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthDate = DateTime(_currentDate.year, index + 1, 1);
                final weeks = _generateWeeks(monthDate);
                return Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: widget.horizontalSpacing > 0
                      ? {
                          for (int i = 0; i < 7; i++)
                            i: FixedColumnWidth(
                                widget.calendarStyle.dayIndicatorSize +
                                    widget.horizontalSpacing)
                        }
                      : null,
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(),
                      children: List.generate(7, (i) {
                        final weekday =
                            widget.startingDay?.value ?? DateTime.monday;
                        final dayIndex = (weekday - 1 + i) % 7;
                        final dayName = DateFormat('E')
                            .format(DateTime(2023, 1, 2 + dayIndex))
                            .substring(0, 2);
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.horizontalSpacing / 2,
                            vertical: widget.verticalSpacing / 2,
                          ),
                          child: SizedBox(
                            height: widget.calendarStyle.dayIndicatorSize,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  dayName,
                                  style: widget.calendarStyle.dayNameStyle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    ...weeks.map((week) {
                      return TableRow(
                        children: week.map((day) {
                          final isSelected =
                              _isSameDay(day, widget.selectedDate);
                          final isCurrentMonth = day.month == monthDate.month;
                          final isFocus = _isFocusDate(day);
                          final focusDate = isFocus ? _getFocusDate(day) : null;
                          final isDisabled = _isDateDisabled(day);
                          final backgroundColor = isDisabled
                              ? widget.calendarStyle.disabledDayColor
                              : isFocus
                                  ? (isSelected
                                      ? widget.calendarStyle.activeDayColor
                                      : focusDate!.backgroundColor)
                                  : (isSelected
                                      ? widget.calendarStyle.activeDayColor
                                      : isCurrentMonth
                                          ? widget
                                              .calendarStyle.dayIndicatorColor
                                          : Colors.transparent);
                          final textColor = isDisabled
                              ? widget.calendarStyle.disabledDayTextStyle.color
                              : isFocus
                                  ? (isSelected
                                      ? widget.calendarStyle.selectedDayTextStyle
                                          .color
                                      : focusDate!.foregroundColor)
                                  : (isSelected
                                      ? widget.calendarStyle.selectedDayTextStyle
                                          .color
                                      : isCurrentMonth
                                          ? widget
                                              .calendarStyle.dayNumberStyle.color
                                          : widget.calendarStyle
                                              .inactiveDayTextStyle.color);
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.horizontalSpacing / 2,
                              vertical: widget.verticalSpacing / 2,
                            ),
                            child: SizedBox(
                              height: widget.calendarStyle.dayIndicatorSize,
                              child: GestureDetector(
                                onTap: isDisabled
                                    ? null
                                    : () {
                                        if (!isCurrentMonth) {
                                          widget.onVisibleDateTapped?.call(
                                              DateTime(
                                                  day.year, day.month, day.day));
                                          return;
                                        }
                                        _handleDaySelection(day);
                                      },
                                child: Container(
                                  margin: EdgeInsets.zero,
                                  width: widget.calendarStyle.dayIndicatorSize,
                                  height: widget.calendarStyle.dayIndicatorSize,
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    shape: BoxShape.circle,
                                    border:
                                        widget.calendarStyle.dayIndicatorBorder,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    day.day.toString(),
                                    style: widget.calendarStyle.dayNumberStyle
                                        .copyWith(color: textColor),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
