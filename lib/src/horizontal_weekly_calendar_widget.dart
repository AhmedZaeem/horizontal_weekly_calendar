import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum HorizontalCalendarType {
  standard,
  outlined,
  minimal,
  elevated,
}

enum Weekday {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  final int value;
  const Weekday(this.value);

  static Weekday fromDateTime(int weekday) {
    return Weekday.values.firstWhere((w) => w.value == weekday);
  }
}

class HorizontalCalendarStyle {
  final TextStyle monthHeaderStyle;
  final TextStyle dayNameStyle;
  final TextStyle dayNumberStyle;
  final TextStyle selectedDayTextStyle;
  final TextStyle inactiveDayTextStyle;

  final Color activeDayColor;
  final Color dayIndicatorColor;
  final double dayIndicatorSize;
  final Border? dayIndicatorBorder;
  final BoxShadow? dayIndicatorShadow;
  final bool showParticles;
  final Duration selectionAnimationDuration;
  final Curve selectionAnimationCurve;

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
    this.showParticles = false,
    this.selectionAnimationDuration = const Duration(milliseconds: 300),
    this.selectionAnimationCurve = Curves.easeOutBack,
  });
}

class HorizontalWeeklyCalendar extends StatefulWidget {
  final DateTime initialDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onNextMonth;
  final VoidCallback onPreviousMonth;
  final HorizontalCalendarType calendarType;
  final HorizontalCalendarStyle calendarStyle;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final bool showMonthHeader;
  final IconData? previousMonthIcon;
  final IconData? nextMonthIcon;
  final Color? iconColor;
  final Weekday? startingDay;
  final bool enableAnimations;

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
  });

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
  }) : calendarType = HorizontalCalendarType.outlined;

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
  }) : calendarType = HorizontalCalendarType.minimal;

  @override
  State<HorizontalWeeklyCalendar> createState() =>
      _HorizontalWeeklyCalendarState();
}

class _HorizontalWeeklyCalendarState extends State<HorizontalWeeklyCalendar>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<List<DateTime>> _weeks;
  late AnimationController _selectionController;
  late DateTime _currentDate;

  List<List<DateTime>> _generateWeeks(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    if (widget.startingDay != null) {
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

  int _findWeekIndex(List<List<DateTime>> weeks, DateTime date) {
    for (int i = 0; i < weeks.length; i++) {
      if (weeks[i].any((day) => _isSameDay(day, date))) return i;
    }
    return 0;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

  Widget _buildDayIndicator(DateTime day, bool isSelected) {
    final isMinimal = widget.calendarType == HorizontalCalendarType.minimal;
    final textStyle = isSelected
        ? widget.calendarStyle.selectedDayTextStyle
        : widget.calendarStyle.inactiveDayTextStyle;

    Widget content = Text(
      day.day.toString(),
      style: isMinimal
          ? textStyle.copyWith(
              color: isSelected ? widget.calendarStyle.activeDayColor : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            )
          : textStyle,
    );

    if (isMinimal) {
      return AnimatedContainer(
        duration: widget.calendarStyle.selectionAnimationDuration,
        decoration: BoxDecoration(
          border: isSelected
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
            color: isSelected
                ? widget.calendarStyle.activeDayColor
                : Colors.transparent,
            border: widget.calendarStyle.dayIndicatorBorder ??
                Border.all(
                  color: isSelected
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
          elevation: isSelected ? 8 : 1,
          borderRadius:
              BorderRadius.circular(widget.calendarStyle.dayIndicatorSize),
          child: AnimatedContainer(
            duration: widget.calendarStyle.selectionAnimationDuration,
            curve: widget.calendarStyle.selectionAnimationCurve,
            width: widget.calendarStyle.dayIndicatorSize,
            height: widget.calendarStyle.dayIndicatorSize,
            decoration: BoxDecoration(
              color: isSelected
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
            color: isSelected
                ? widget.calendarStyle.activeDayColor
                : widget.calendarStyle.dayIndicatorColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: content),
        );
    }
  }

  void _handleDaySelection(DateTime day) {
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
              color: widget.iconColor,
              size: isMinimal ? 20 : 24,
            ),
            onPressed: () {
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
            },
          ),
          Text(
            DateFormat(isMinimal ? 'MMM y' : 'MMMM y').format(_currentDate),
            style: widget.calendarStyle.monthHeaderStyle,
          ),
          IconButton(
            icon: Icon(
              widget.nextMonthIcon,
              color: widget.iconColor,
              size: isMinimal ? 20 : 24,
            ),
            onPressed: () {
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
            },
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
                  // 🆕 Calculate equal width for all days
                  final dayWidth = constraints.maxWidth / 7;
                  return AnimatedSwitcher(
                    duration: widget.animationDuration ??
                        const Duration(milliseconds: 300),
                    switchInCurve: widget.animationCurve ?? Curves.easeInOut,
                    child: Row(
                      key: ValueKey(_weeks[index]),
                      mainAxisAlignment: MainAxisAlignment
                          .start, // 🆕 Changed from spaceEvenly
                      children: _weeks[index].map((day) {
                        final isSelected = _isSameDay(day, widget.selectedDate);
                        return SizedBox(
                          // 🆕 Added fixed width container
                          width: dayWidth,
                          child: GestureDetector(
                            onTap: () => _handleDaySelection(day),
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
                                _buildDayIndicator(day, isSelected),
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
