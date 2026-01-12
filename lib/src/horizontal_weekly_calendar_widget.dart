import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Defines visual variations of the horizontal calendar
enum HorizontalCalendarType {
  /// Default circular day indicators
  standard,

  /// Outlined containers with border
  outlined,

  /// Simplified text-based display
  minimal,

  /// Material-elevated containers
  elevated,
}

/// Represents days of the week with ISO 8601 numbering (Monday = 1)
enum Weekday {
  /// Sets the first day of the week to monday
  monday(1),

  /// Sets the first day of the week to Tuesday
  tuesday(2),

  /// Sets the first day of the week to Wednesday
  wednesday(3),

  /// Sets the first day of the week to Thursday
  thursday(4),

  /// Sets the first day of the week to Friday
  friday(5),

  /// Sets the first day of the week to Saturday
  saturday(6),

  /// Sets the first day of the week to Sunday
  sunday(7);

  /// Gets the value of the day
  final int value;
  const Weekday(this.value);

  /// Converts DateTime.weekday (1-7) to Weekday enum
  static Weekday fromDateTime(int weekday) {
    return Weekday.values.firstWhere((w) => w.value == weekday);
  }
}

/// Contains all visual styling parameters for the calendar
class HorizontalCalendarStyle {
  /// Style for month/year header text
  final TextStyle monthHeaderStyle;

  /// Style for weekday abbreviation labels
  final TextStyle dayNameStyle;

  /// Base style for day numbers
  final TextStyle dayNumberStyle;

  /// Style for selected day numbers
  final TextStyle selectedDayTextStyle;

  /// Style for non-selected days in current month
  final TextStyle inactiveDayTextStyle;

  /// Primary color for selected states
  final Color activeDayColor;

  /// Background color for day indicators
  final Color dayIndicatorColor;

  /// Diameter of day indicator circles
  final double dayIndicatorSize;

  /// Custom border for day indicators
  final Border? dayIndicatorBorder;

  /// Shadow effect for elevated variants
  final BoxShadow? dayIndicatorShadow;

  /// Enables particle effects on selection (if implemented)
  final bool showParticles;

  /// Duration for selection animations
  final Duration selectionAnimationDuration;

  /// Curve for selection animations
  final Curve selectionAnimationCurve;

  /// Style for disabled day numbers
  final TextStyle disabledDayTextStyle;

  /// Background color for disabled day indicators
  final Color disabledDayColor;

  /// Creates a style configuration for the calendar
  const HorizontalCalendarStyle({
    this.monthHeaderStyle =
        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    this.dayNameStyle = const TextStyle(fontSize: 12),
    this.dayNumberStyle = const TextStyle(fontSize: 16),
    this.activeDayColor = Colors.blue,
    this.dayIndicatorColor = Colors.transparent,
    this.dayIndicatorSize = 40,
    this.dayIndicatorBorder,
    this.dayIndicatorShadow,
    this.selectedDayTextStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.inactiveDayTextStyle = const TextStyle(fontSize: 16),
    this.disabledDayTextStyle =
        const TextStyle(fontSize: 16, color: Colors.grey),
    this.disabledDayColor = Colors.transparent,
    this.showParticles = false,
    this.selectionAnimationDuration = const Duration(milliseconds: 300),
    this.selectionAnimationCurve = Curves.easeOutBack,
  });
}

/// A horizontally scrollable weekly calendar widget with multiple visual styles
class HorizontalWeeklyCalendar extends StatefulWidget {
  /// Initial displayed month
  final DateTime initialDate;

  /// Currently selected date
  final DateTime selectedDate;

  /// Callback when user selects a date
  final ValueChanged<DateTime> onDateSelected;

  /// Callback when calendar advances to next month
  final Function() onNextMonth;

  /// Callback when calendar returns to previous month
  final Function() onPreviousMonth;

  /// Visual variant of the calendar
  final HorizontalCalendarType calendarType;

  /// Complete styling configuration
  final HorizontalCalendarStyle calendarStyle;

  /// Custom duration for month transition animations
  final Duration? animationDuration;

  /// Custom curve for month transition animations
  final Curve? animationCurve;

  /// Toggles month header visibility
  final bool showMonthHeader;

  /// Custom icon for previous month navigation
  final IconData? previousMonthIcon;

  /// Custom icon for next month navigation
  final IconData? nextMonthIcon;

  /// Color for navigation icons
  final Color? iconColor;

  /// Override default week starting day
  final Weekday? startingDay;

  /// Global toggle for all animations
  final bool enableAnimations;

  /// Minimum selectable date
  final DateTime? minDate;

  /// Maximum selectable date
  final DateTime? maxDate;

  /// Default constructor for standard calendar
  const HorizontalWeeklyCalendar({
    super.key,
    required this.initialDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onNextMonth,
    required this.onPreviousMonth,
    this.calendarType = HorizontalCalendarType.standard,
    this.calendarStyle = const HorizontalCalendarStyle(),
    this.animationDuration,
    this.animationCurve,
    this.showMonthHeader = true,
    this.previousMonthIcon = Icons.chevron_left,
    this.nextMonthIcon = Icons.chevron_right,
    this.iconColor,
    this.startingDay,
    this.enableAnimations = true,
    this.minDate,
    this.maxDate,
  });

  /// Preconfigured constructor for outlined variant
  const HorizontalWeeklyCalendar.outlined({
    super.key,
    required this.initialDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onNextMonth,
    required this.onPreviousMonth,
    this.calendarStyle = const HorizontalCalendarStyle(),
    this.animationDuration,
    this.animationCurve,
    this.showMonthHeader = true,
    this.previousMonthIcon = Icons.chevron_left,
    this.nextMonthIcon = Icons.chevron_right,
    this.iconColor,
    this.startingDay,
    this.enableAnimations = true,
    this.minDate,
    this.maxDate,
  }) : calendarType = HorizontalCalendarType.outlined;

  /// Preconfigured constructor for minimal variant
  const HorizontalWeeklyCalendar.minimal({
    super.key,
    required this.initialDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onNextMonth,
    required this.onPreviousMonth,
    this.calendarStyle = const HorizontalCalendarStyle(
      dayIndicatorSize: 32,
      monthHeaderStyle: TextStyle(fontSize: 14),
      selectedDayTextStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    this.animationDuration,
    this.animationCurve,
    this.showMonthHeader = true,
    this.previousMonthIcon = Icons.chevron_left,
    this.nextMonthIcon = Icons.chevron_right,
    this.iconColor,
    this.startingDay,
    this.enableAnimations = true,
    this.minDate,
    this.maxDate,
  }) : calendarType = HorizontalCalendarType.minimal;

  @override
  State<HorizontalWeeklyCalendar> createState() =>
      _HorizontalWeeklyCalendarState();
}

/// State class for calendar widget handling layout and interactions
class _HorizontalWeeklyCalendarState extends State<HorizontalWeeklyCalendar>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<List<DateTime>> _weeks;
  late AnimationController _selectionController;
  late DateTime _currentDate;

  /// Generates week lists based on current month and starting day
  List<List<DateTime>> _generateWeeks(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    if (widget.startingDay != null) {
      // Custom week start logic
      int daysToSubtract =
          (firstDayOfMonth.weekday - widget.startingDay!.value) % 7;
      DateTime weekStart =
          firstDayOfMonth.subtract(Duration(days: daysToSubtract));

      int daysToAdd =
          (widget.startingDay!.value + 6 - lastDayOfMonth.weekday) % 7;
      DateTime weekEnd = lastDayOfMonth.add(Duration(days: daysToAdd));

      final totalDays = weekEnd.difference(weekStart).inDays + 1;
      final numberOfWeeks = (totalDays / 7).ceil();

      return List.generate(numberOfWeeks, (weekIndex) {
        return List.generate(7, (dayIndex) {
          return weekStart.add(Duration(days: (weekIndex * 7) + dayIndex));
        });
      });
    } else {
      // Default month week generation
      final int totalDays = lastDayOfMonth.day;
      final int numberOfWeeks = (totalDays + 6) ~/ 7;
      List<List<DateTime>> weeks = [];

      for (int weekIndex = 0; weekIndex < numberOfWeeks; weekIndex++) {
        List<DateTime> week = [];
        for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
          final dayNumber = (weekIndex * 7) + dayOffset + 1;
          if (dayNumber > totalDays) break;
          week.add(DateTime(date.year, date.month, dayNumber));
        }
        weeks.add(week);
      }
      return weeks;
    }
  }

  /// Finds the week index containing a specific date
  int _findWeekIndex(List<List<DateTime>> weeks, DateTime date) {
    for (int i = 0; i < weeks.length; i++) {
      if (weeks[i].any((day) => _isSameDay(day, date))) return i;
    }
    return 0;
  }

  /// Date comparison helper
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
    _currentDate = widget.initialDate;
    _weeks = _generateWeeks(_currentDate);
    _pageController = PageController(
      initialPage: _findWeekIndex(_weeks, widget.selectedDate),
      viewportFraction: 1,
    );
    _selectionController = AnimationController(
      vsync: this,
      duration: widget.calendarStyle.selectionAnimationDuration,
    );
  }

  @override
  void didUpdateWidget(HorizontalWeeklyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startingDay != widget.startingDay ||
        oldWidget.selectedDate != widget.selectedDate) {
      _weeks = _generateWeeks(_currentDate);
      final newPage = _findWeekIndex(_weeks, widget.selectedDate);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(newPage);
      }
    }
  }

  /// Builds individual day indicator based on current style
  Widget _buildDayIndicator(DateTime day, bool isSelected, bool isDisabled) {
    final isMinimal = widget.calendarType == HorizontalCalendarType.minimal;
    final textStyle = isDisabled
        ? widget.calendarStyle.disabledDayTextStyle
        : isSelected
            ? widget.calendarStyle.selectedDayTextStyle
            : widget.calendarStyle.inactiveDayTextStyle;

    Widget content = Text(
      day.day.toString(),
      style: isMinimal
          ? textStyle.copyWith(
              color: isDisabled
                  ? widget.calendarStyle.disabledDayTextStyle.color
                  : isSelected
                      ? widget.calendarStyle.activeDayColor
                      : null,
              fontWeight: isSelected && !isDisabled ? FontWeight.bold : null,
            )
          : textStyle,
    );

    if (isMinimal) {
      return AnimatedContainer(
        duration: widget.calendarStyle.selectionAnimationDuration,
        decoration: BoxDecoration(
          border: isSelected && !isDisabled
              ? Border(
                  bottom: BorderSide(
                    color: widget.calendarStyle.activeDayColor,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: content,
      );
    }

    switch (widget.calendarType) {
      case HorizontalCalendarType.outlined:
        return AnimatedContainer(
          duration: widget.calendarStyle.selectionAnimationDuration,
          curve: widget.calendarStyle.selectionAnimationCurve,
          width: widget.calendarStyle.dayIndicatorSize,
          height: widget.calendarStyle.dayIndicatorSize,
          decoration: BoxDecoration(
            color: isDisabled
                ? widget.calendarStyle.disabledDayColor
                : isSelected
                    ? widget.calendarStyle.activeDayColor
                    : Colors.transparent,
            border: widget.calendarStyle.dayIndicatorBorder ??
                Border.all(
                  color: isDisabled
                      ? widget.calendarStyle.disabledDayTextStyle.color ??
                          Colors.grey
                      : isSelected
                          ? widget.calendarStyle.activeDayColor
                          : Colors.grey,
                  width: 1.5,
                ),
            borderRadius:
                BorderRadius.circular(widget.calendarStyle.dayIndicatorSize),
            boxShadow: widget.calendarStyle.dayIndicatorShadow != null
                ? [widget.calendarStyle.dayIndicatorShadow!]
                : null,
          ),
          child: Center(child: content),
        );

      case HorizontalCalendarType.elevated:
        return Material(
          elevation: isDisabled ? 0 : (isSelected ? 8 : 1),
          borderRadius:
              BorderRadius.circular(widget.calendarStyle.dayIndicatorSize),
          child: AnimatedContainer(
            duration: widget.calendarStyle.selectionAnimationDuration,
            curve: widget.calendarStyle.selectionAnimationCurve,
            width: widget.calendarStyle.dayIndicatorSize,
            height: widget.calendarStyle.dayIndicatorSize,
            decoration: BoxDecoration(
              color: isDisabled
                  ? widget.calendarStyle.disabledDayColor
                  : isSelected
                      ? widget.calendarStyle.activeDayColor
                      : Colors.white,
              borderRadius:
                  BorderRadius.circular(widget.calendarStyle.dayIndicatorSize),
            ),
            child: Center(child: content),
          ),
        );

      default:
        return AnimatedContainer(
          duration: widget.calendarStyle.selectionAnimationDuration,
          curve: widget.calendarStyle.selectionAnimationCurve,
          width: widget.calendarStyle.dayIndicatorSize,
          height: widget.calendarStyle.dayIndicatorSize,
          decoration: BoxDecoration(
            color: isDisabled
                ? widget.calendarStyle.disabledDayColor
                : isSelected
                    ? widget.calendarStyle.activeDayColor
                    : widget.calendarStyle.dayIndicatorColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: content),
        );
    }
  }

  /// Handles date selection logic and month transitions
  void _handleDaySelection(DateTime day) {
    if (_isDateDisabled(day)) return;
    widget.onDateSelected(day);
    final selectedMonth = DateTime(day.year, day.month);
    if (selectedMonth != DateTime(_currentDate.year, _currentDate.month)) {
      setState(() {
        _currentDate = selectedMonth;
        _weeks = _generateWeeks(_currentDate);
        final newPage = _findWeekIndex(_weeks, day);
        if (widget.enableAnimations) {
          _pageController.animateToPage(
            newPage,
            duration:
                widget.animationDuration ?? const Duration(milliseconds: 300),
            curve: widget.animationCurve ?? Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(newPage);
        }
      });
      if (day.isBefore(_currentDate)) {
        widget.onPreviousMonth();
      } else {
        widget.onNextMonth();
      }
    }
    if (widget.enableAnimations) {
      _selectionController.forward(from: 0);
    }
  }

  /// Builds the month header with navigation controls
  Widget _buildMonthHeader() {
    final isMinimal = widget.calendarType == HorizontalCalendarType.minimal;

    return Padding(
      padding: isMinimal
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              widget.previousMonthIcon,
              color: _canNavigateToPreviousMonth()
                  ? widget.iconColor
                  : (widget.iconColor ?? Theme.of(context).iconTheme.color)?.withOpacity(0.3),
              size: isMinimal ? 20 : 24,
            ),
            onPressed: _canNavigateToPreviousMonth()
                ? () {
              setState(() {
                _currentDate =
                    DateTime(_currentDate.year, _currentDate.month - 1);
                _weeks = _generateWeeks(_currentDate);
                final newPage = _findWeekIndex(_weeks, _currentDate);
                if (widget.enableAnimations) {
                  _pageController.animateToPage(
                    newPage,
                    duration: widget.animationDuration ??
                        const Duration(milliseconds: 300),
                    curve: widget.animationCurve ?? Curves.easeInOut,
                  );
                } else {
                  _pageController.jumpToPage(newPage);
                }
              });
              widget.onPreviousMonth();
            }
                : null,
          ),
          Text(
            DateFormat(isMinimal ? 'MMM y' : 'MMMM y').format(_currentDate),
            style: widget.calendarStyle.monthHeaderStyle,
          ),
          IconButton(
            icon: Icon(
              widget.nextMonthIcon,
              color: _canNavigateToNextMonth()
                  ? widget.iconColor
                  : (widget.iconColor ?? Theme.of(context).iconTheme.color)?.withOpacity(0.3),
              size: isMinimal ? 20 : 24,
            ),
            onPressed: _canNavigateToNextMonth()
                ? () {
              setState(() {
                _currentDate =
                    DateTime(_currentDate.year, _currentDate.month + 1);
                _weeks = _generateWeeks(_currentDate);
                final newPage = _findWeekIndex(_weeks, _currentDate);
                if (widget.enableAnimations) {
                  _pageController.animateToPage(
                    newPage,
                    duration: widget.animationDuration ??
                        const Duration(milliseconds: 300),
                    curve: widget.animationCurve ?? Curves.easeInOut,
                  );
                } else {
                  _pageController.jumpToPage(newPage);
                }
              });
              widget.onNextMonth();
            }
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showMonthHeader) _buildMonthHeader(),
        SizedBox(
          height: widget.calendarStyle.dayIndicatorSize * 2,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _weeks.length,
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final dayWidth = constraints.maxWidth / 7;
                  return AnimatedSwitcher(
                    duration: widget.animationDuration ??
                        const Duration(milliseconds: 300),
                    switchInCurve: widget.animationCurve ?? Curves.easeInOut,
                    child: Row(
                      key: ValueKey(_weeks[index]),
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _weeks[index].map((day) {
                        final isSelected = _isSameDay(day, widget.selectedDate);
                        final isDisabled = _isDateDisabled(day);
                        return SizedBox(
                          width: dayWidth,
                          child: GestureDetector(
                            onTap: isDisabled
                                ? null
                                : () => _handleDaySelection(day),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.calendarType !=
                                    HorizontalCalendarType.minimal)
                                  Text(
                                    DateFormat('E').format(day).substring(0, 2),
                                    style: widget.calendarStyle.dayNameStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 4),
                                _buildDayIndicator(day, isSelected, isDisabled),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _selectionController.dispose();
    super.dispose();
  }
}
