import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../weekly_calendar.dart';

/// Represents an event in the calendar with its properties.
class CalendarEvent {
  /// Unique identifier for the event.
  final String id;

  /// The title of the event.
  final String title;

  /// The unique identifier for the event.
  final DateTime startTime;

  /// The start time of the event.
  final DateTime endTime;

  /// Color of the background of the event.
  final Color backgroundColor;

  /// Color of the text in the event.
  final Color textColor;

  /// Creates a calendar event with the specified properties.
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  });
}

/// Style configuration for the event calendar, allowing customization of appearance.
class EventCalendarStyle {
  /// Height of each time slot in the calendar.
  final double timeSlotHeight;

  /// Height of each time slot in the calendar.
  final double timeColumnWidth;

  /// Height of each time slot in the calendar.
  final TextStyle timeTextStyle;

  /// Style for the text of the events in the calendar.
  final TextStyle eventTextStyle;

  /// Padding for the event containers in the calendar.
  final EdgeInsets eventPadding;

  /// Border radius for the event containers in the calendar.
  final BorderRadius eventBorderRadius;

  /// Color of the grid lines in the calendar.
  final Color gridColor;

  /// Width of the grid lines in the calendar.
  final double gridWidth;

  /// Height of the header for each day in the calendar.
  final double dayHeaderHeight;

  /// Style for the text of the month header in the calendar.
  final TextStyle monthHeaderStyle;

  /// Style for the text of the day names in the calendar.
  final TextStyle dayNameStyle;

  /// Style for the text of the day numbers in the calendar.
  final TextStyle dayNumberStyle;

  /// Color of the active day in the calendar.
  final Color activeDayColor;

  /// Color of the day indicator circle in the calendar.
  final Color dayIndicatorColor;

  /// Size of the day indicator circle in the calendar.
  final double dayIndicatorSize;

  /// Style for the text of the selected day in the calendar.
  final TextStyle selectedDayTextStyle;

  /// Style for the text of inactive days in the calendar.
  final TextStyle inactiveDayTextStyle;

  /// Color of the divider line between time slots.
  final Color dividerColor;

  /// Thickness of the divider line between time slots.
  final double dividerThickness;

  /// Indent for the divider line at the start of each time slot.
  final double dividerIndent;

  /// Indent for the divider line at the start of each time slot.
  final double dividerEndIndent;

  /// Style for the divider line between time slots.
  final BorderStyle dividerStyle;

  /// Height of each hour slot (distance between hour timestamps)
  final double hourSlotHeight;

  /// Divider color between the calendar header and the events grid.
  final Color headerDividerColor;

  /// Divider thickness between the calendar header and the events grid.
  final double headerDividerThickness;

  /// Divider indent between the calendar header and the events grid.
  final double headerDividerIndent;

  /// Divider end indent between the calendar header and the events grid.
  final double headerDividerEndIndent;

  /// Style for the horizontal calendar, allowing customization of appearance.
  final HorizontalCalendarStyle calendarStyle;

  /// Margin between overlapping events displayed side by side.
  final double overlappingEventMargin;

  /// Creates a style configuration for the event calendar.
  const EventCalendarStyle({
    this.timeSlotHeight = 60.0,
    this.hourSlotHeight = 60.0,
    this.timeColumnWidth = 80.0,
    this.timeTextStyle = const TextStyle(fontSize: 12),
    this.eventTextStyle = const TextStyle(fontSize: 12, color: Colors.white),
    this.eventPadding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    this.eventBorderRadius = const BorderRadius.all(Radius.circular(4)),
    this.gridColor = Colors.grey,
    this.gridWidth = 0.5,
    this.dayHeaderHeight = 70.0,
    this.monthHeaderStyle =
        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    this.dayNameStyle = const TextStyle(fontSize: 12),
    this.dayNumberStyle = const TextStyle(fontSize: 16),
    this.activeDayColor = Colors.blue,
    this.dayIndicatorColor = Colors.transparent,
    this.dayIndicatorSize = 32.0,
    this.selectedDayTextStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.inactiveDayTextStyle = const TextStyle(fontSize: 16),
    this.dividerColor = Colors.grey,
    this.dividerThickness = 1.0,
    this.dividerIndent = 0.0,
    this.dividerEndIndent = 0.0,
    this.dividerStyle = BorderStyle.solid,
    this.headerDividerColor = Colors.grey,
    this.headerDividerThickness = 1.0,
    this.headerDividerIndent = 0.0,
    this.headerDividerEndIndent = 0.0,
    this.calendarStyle = const HorizontalCalendarStyle(),
    this.overlappingEventMargin = 2.0,
  });
}

/// A calendar widget that displays events for each day of the week.
class EventCalendar extends StatefulWidget {
  /// The currently displayed month in the calendar.
  final DateTime currentMonth;

  /// The currently selected date in the calendar.
  final DateTime selectedDate;

  /// List of events to display in the calendar.
  final List<CalendarEvent> events;

  /// Callback when the user selects a date.
  final ValueChanged<DateTime> onDateSelected;

  /// Callback when the user selects a date.
  final VoidCallback onNextMonth;

  /// Callback when the user navigates to the next month.
  final VoidCallback onPreviousMonth;

  /// The style configuration for the calendar, allowing customization of appearance.
  final EventCalendarStyle style;

  /// The hour at which the calendar starts displaying time slots.
  final int startHour;

  /// The hour at which the calendar starts displaying time slots.
  final int endHour;

  /// Builder for events, allowing customization of how each event is displayed.
  final Widget Function(BuildContext, CalendarEvent)? eventBuilder;

  /// Builder for time slots, allowing customization of how each time slot is displayed.
  final Widget Function(BuildContext, DateTime)? timeSlotBuilder;

  /// Minimum selectable date
  final DateTime? minDate;

  /// Maximum selectable date
  final DateTime? maxDate;

  /// Creates a calendar widget that displays events for each day of the week.
  const EventCalendar({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.onNextMonth,
    required this.onPreviousMonth,
    this.style = const EventCalendarStyle(),
    this.startHour = 7,
    this.endHour = 19,
    this.eventBuilder,
    this.timeSlotBuilder,
    this.minDate,
    this.maxDate,
  });

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _timeColumnController = ScrollController();

  @override
  void initState() {
    super.initState();
    _verticalController.addListener(_syncScroll);
    _timeColumnController.addListener(_syncScroll);
  }

  void _syncScroll() {
    if (_verticalController.offset != _timeColumnController.offset) {
      if (_verticalController.hasClients && _timeColumnController.hasClients) {
        _timeColumnController.jumpTo(_verticalController.offset);
      }
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _timeColumnController.dispose();
    super.dispose();
  }

  Map<DateTime, List<CalendarEvent>> _groupEventsByDay(
      List<CalendarEvent> events) {
    final grouped = <DateTime, List<CalendarEvent>>{};
    for (final event in events) {
      final date = DateTime(
          event.startTime.year, event.startTime.month, event.startTime.day);
      grouped.putIfAbsent(date, () => []).add(event);
    }
    return grouped;
  }

  List<CalendarEvent> _eventsForDay(
      DateTime day, Map<DateTime, List<CalendarEvent>> groupedEvents) {
    return groupedEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  void didUpdateWidget(EventCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.currentMonth != widget.currentMonth) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedEvents = _groupEventsByDay(widget.events);
    final totalHours = widget.endHour - widget.startHour;
    final timelineHeight = totalHours * widget.style.timeSlotHeight;
    final dayWidth =
        (MediaQuery.of(context).size.width - widget.style.timeColumnWidth) / 7;

    return Column(
      children: [
        HorizontalWeeklyCalendar(
          initialDate: widget.currentMonth,
          selectedDate: widget.selectedDate,
          onDateSelected: (date) {
            widget.onDateSelected(date);
            setState(() {});
          },
          calendarStyle: widget.style.calendarStyle,
          onNextMonth: widget.onNextMonth,
          onPreviousMonth: widget.onPreviousMonth,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
        ),
        Divider(
          color: widget.style.headerDividerColor,
          thickness: widget.style.headerDividerThickness,
          indent: widget.style.headerDividerIndent,
          endIndent: widget.style.headerDividerEndIndent,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: widget.style.timeColumnWidth,
                child: _buildTimeColumn(timelineHeight, _timeColumnController),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalController,
                  child: SizedBox(
                    width: dayWidth * 7,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: _verticalController,
                      child: Stack(
                        children: [
                          _buildGridLines(dayWidth, timelineHeight),
                          ..._buildEvents(
                              groupedEvents, dayWidth, timelineHeight),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeColumn(double timelineHeight, ScrollController controller) {
    final totalSlots = (widget.endHour - widget.startHour);
    return ListView.builder(
      controller: controller,
      physics: const ClampingScrollPhysics(),
      itemCount: totalSlots + 1,
      itemBuilder: (context, index) {
        if (index < totalSlots) {
          final hour = widget.startHour + index;
          return SizedBox(
            height: widget.style.hourSlotHeight,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 0),
                child: Text(
                  DateFormat('HH:00').format(DateTime(0, 0, 0, hour)),
                  style: widget.style.timeTextStyle,
                ),
              ),
            ),
          );
        } else {
          // return SizedBox(
          //   height: widget.style.hourSlotHeight / 2 + 24,
          //   child: Align(
          //     alignment: Alignment.topRight,
          //     child: Padding(
          //       padding: const EdgeInsets.only(right: 8, top: 0),
          //       child: Text(
          //         DateFormat('HH:30')
          //             .format(DateTime(0, 0, 0, widget.endHour - 1)),
          //         style: widget.style.timeTextStyle,
          //       ),
          //     ),
          //   ),
          // );
        }
        return null;
      },
    );
  }

  Widget _buildGridLines(double dayWidth, double timelineHeight) {
    final totalSlots = (widget.endHour - widget.startHour);
    return Column(
      children: [
        for (int i = 0; i < totalSlots; i++)
          Stack(
            children: [
              SizedBox(
                height: widget.style.hourSlotHeight,
                child: Row(
                  children: [
                    for (int j = 0; j < 7; j++) Container(width: dayWidth),
                  ],
                ),
              ),
              Positioned(
                top: (widget.style.hourSlotHeight -
                        widget.style.dividerThickness) /
                    2,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    for (int j = 0; j < 7; j++)
                      Container(
                        width: dayWidth,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: widget.style.dividerColor,
                              width: widget.style.dividerThickness,
                              style: widget.style.dividerStyle,
                            ),
                            right: BorderSide(
                              color: widget.style.gridColor
                                  .withValues(alpha: (0.2 * 255)),
                              width: widget.style.gridWidth,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  bool _eventsOverlap(CalendarEvent a, CalendarEvent b) {
    return a.startTime.isBefore(b.endTime) && b.startTime.isBefore(a.endTime);
  }

  List<List<CalendarEvent>> _groupOverlappingEvents(List<CalendarEvent> events) {
    if (events.isEmpty) return [];

    final sortedEvents = List<CalendarEvent>.from(events)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final List<List<CalendarEvent>> groups = [];

    for (final event in sortedEvents) {
      bool addedToGroup = false;

      for (final group in groups) {
        if (group.any((e) => _eventsOverlap(e, event))) {
          group.add(event);
          addedToGroup = true;
          break;
        }
      }

      if (!addedToGroup) {
        groups.add([event]);
      }
    }

    final List<List<CalendarEvent>> mergedGroups = [];
    for (final group in groups) {
      bool merged = false;
      for (final mergedGroup in mergedGroups) {
        if (group.any((e1) => mergedGroup.any((e2) => _eventsOverlap(e1, e2)))) {
          mergedGroup.addAll(group);
          merged = true;
          break;
        }
      }
      if (!merged) {
        mergedGroups.add(List.from(group));
      }
    }

    return mergedGroups;
  }

  List<Widget> _buildEvents(
    Map<DateTime, List<CalendarEvent>> groupedEvents,
    double dayWidth,
    double timelineHeight,
  ) {
    final events = <Widget>[];
    final dayEvents = _eventsForDay(widget.selectedDate, groupedEvents);
    final totalWidth = dayWidth * 7;
    final margin = widget.style.overlappingEventMargin;

    final overlappingGroups = _groupOverlappingEvents(dayEvents);

    for (final group in overlappingGroups) {
      final groupSize = group.length;
      final eventWidth = (totalWidth - (margin * (groupSize - 1))) / groupSize;

      for (int i = 0; i < group.length; i++) {
        final event = group[i];
        final rect = _calculateEventRect(event, dayWidth, widget.style.timeSlotHeight);
        final left = i * (eventWidth + margin);

        events.add(
          Positioned(
            left: left,
            top: rect.top,
            width: eventWidth,
            height: rect.height,
            child: SizedBox.expand(
              child: widget.eventBuilder?.call(context, event) ??
                  _buildDefaultEvent(event),
            ),
          ),
        );
      }
    }
    return events;
  }

  Widget _buildDefaultEvent(CalendarEvent event) {
    return Container(
      margin: EdgeInsets.zero,
      padding: widget.style.eventPadding,
      decoration: BoxDecoration(
        color: event.backgroundColor,
        borderRadius: widget.style.eventBorderRadius,
      ),
      child: Center(
        child: Text(
          event.title,
          style: widget.style.eventTextStyle.copyWith(color: event.textColor),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Rect _calculateEventRect(
      CalendarEvent event, double columnWidth, double timeSlotHeight) {
    final hourSlotHeight = widget.style.hourSlotHeight;
    final dayStart = DateTime(
        event.startTime.year, event.startTime.month, event.startTime.day);
    final startOffset = event.startTime.difference(dayStart).inMinutes;
    final endOffset = event.endTime.difference(dayStart).inMinutes;
    final top = ((startOffset / 60) * hourSlotHeight) -
        (widget.startHour * hourSlotHeight);
    final height = ((endOffset - startOffset) / 60) * hourSlotHeight;
    return Rect.fromLTWH(0, top, columnWidth, height);
  }
}
