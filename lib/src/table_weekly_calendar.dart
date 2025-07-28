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

  /// The style configuration for the calendar appearance.
  final HorizontalCalendarStyle calendarStyle;

  /// The day of the week to start the calendar (e.g., Monday or Sunday).
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

  /// A builder for customizing the header widget. If null, a default header is used.
  final TableWeeklyCalendarHeaderBuilder? headerBuilder;

  /// Whether to use the color from the [FocusDate] for focus dates. If false, uses the default indicator color.
  final bool useFocusDateColor;

  /// The padding around the calendar table (excluding the header).
  final EdgeInsetsGeometry tablePadding;

  /// Creates a [TableWeeklyCalendar] widget.
  const TableWeeklyCalendar({
    super.key,
    required this.initialDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
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
  });

  /// Creates the mutable state for this widget.
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
      final key = DateTime.utc(
        focusDate.date.year,
        focusDate.date.month,
        focusDate.date.day,
      );
      _focusDateMap[key] = focusDate;
    }
  }

  FocusDate? _getFocusDate(DateTime date) {
    final key = DateTime.utc(date.year, date.month, date.day);
    return _focusDateMap[key];
  }

  bool _isFocusDate(DateTime date) {
    final key = DateTime.utc(date.year, date.month, date.day);
    return _focusDateMap.containsKey(key);
  }

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
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
    widget.onDateSelected(day);
    final selectedMonth = DateTime(day.year, day.month);
    if (selectedMonth != DateTime(_currentDate.year, _currentDate.month)) {
      setState(() {
        _currentDate = selectedMonth;
        _currentMonthPage = _currentDate.month - 1;
        _pageController.jumpToPage(_currentMonthPage);
      });
      widget.onMonthChanged(_currentDate);
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentMonthPage = page;
      _currentDate = DateTime(_currentDate.year, page + 1);
    });
    widget.onMonthChanged(_currentDate);
  }

  Widget _buildHeader() {
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(
        context,
        _currentDate,
        () {
          if (_currentMonthPage > 0) {
            _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }
        },
        () {
          if (_currentMonthPage < 11) {
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
              color: widget.iconColor,
              size: 24,
            ),
            onPressed: () {
              if (_currentMonthPage > 0) {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease);
              }
            },
          ),
          Text(
            DateFormat('MMMM y').format(_currentDate),
            style: widget.calendarStyle.monthHeaderStyle,
          ),
          IconButton(
            icon: Icon(
              widget.nextMonthIcon,
              color: widget.iconColor,
              size: 24,
            ),
            onPressed: () {
              if (_currentMonthPage < 11) {
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease);
              }
            },
          ),
        ],
      ),
    );
  }

  List<List<DateTime>> _generateWeeks(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final startDay = widget.startingDay?.value ?? DateTime.monday;
    int daysToSubtract = (firstDayOfMonth.weekday - startDay) % 7;
    DateTime weekStart =
        firstDayOfMonth.subtract(Duration(days: daysToSubtract));
    int daysToAdd = (startDay + 6 - lastDayOfMonth.weekday) % 7;
    DateTime weekEnd = lastDayOfMonth.add(Duration(days: daysToAdd));
    final totalDays = weekEnd.difference(weekStart).inDays + 1;
    final numberOfWeeks = (totalDays / 7).ceil();
    return List.generate(numberOfWeeks, (weekIndex) {
      return List.generate(7, (dayIndex) {
        return weekStart.add(Duration(days: (weekIndex * 7) + dayIndex));
      });
    });
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
            height: widget.calendarStyle.dayIndicatorSize * 6,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthDate = DateTime(_currentDate.year, index + 1);
                final weeks = _generateWeeks(monthDate);
                return Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
                        return SizedBox(
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
                          final backgroundColor = isFocus
                              ? (isSelected
                                  ? widget.calendarStyle.activeDayColor
                                  : focusDate!.backgroundColor)
                              : (isSelected
                                  ? widget.calendarStyle.activeDayColor
                                  : isCurrentMonth
                                      ? widget.calendarStyle.dayIndicatorColor
                                      : Colors.transparent);
                          final textColor = isFocus
                              ? (isSelected
                                  ? widget
                                      .calendarStyle.selectedDayTextStyle.color
                                  : focusDate!.foregroundColor)
                              : (isSelected
                                  ? widget
                                      .calendarStyle.selectedDayTextStyle.color
                                  : isCurrentMonth
                                      ? widget
                                          .calendarStyle.dayNumberStyle.color
                                      : widget.calendarStyle
                                          .inactiveDayTextStyle.color);
                          return SizedBox(
                            height: widget.calendarStyle.dayIndicatorSize,
                            child: GestureDetector(
                              onTap: () => _handleDaySelection(day),
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
