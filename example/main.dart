import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/src/calendar_with_event.dart';
import 'package:horizontal_weekly_calendar/weekly_calendar.dart';

void main() => runApp(const CalendarDemoApp());

class CalendarDemoApp extends StatelessWidget {
  const CalendarDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalendarDemoScreen(),
    );
  }
}

class CalendarDemoScreen extends StatefulWidget {
  const CalendarDemoScreen({super.key});

  @override
  State<CalendarDemoScreen> createState() => _CalendarDemoScreenState();
}

class _CalendarDemoScreenState extends State<CalendarDemoScreen> {
  DateTime _selectedTableDate = DateTime.now();
  DateTime _selectedEventDate = DateTime.now();
  DateTime _currentEventMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  // Sample focus dates for TableWeeklyCalendar
  List<FocusDate> get _focusDates => [
        FocusDate(
          date: DateTime.now().subtract(const Duration(days: 2)),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
        FocusDate(
          date: DateTime.now().add(const Duration(days: 1)),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        FocusDate(
          date: DateTime.now().add(const Duration(days: 3)),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ];

  // Sample events for EventCalendar
  List<CalendarEvent> get _events => [
        CalendarEvent(
          id: '1',
          title: 'Team Meeting',
          startTime: DateTime(_selectedEventDate.year, _selectedEventDate.month,
              _selectedEventDate.day, 10, 0),
          endTime: DateTime(_selectedEventDate.year, _selectedEventDate.month,
              _selectedEventDate.day, 11, 0),
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        ),
        CalendarEvent(
          id: '2',
          title: 'Doctor Appointment',
          startTime: DateTime(_selectedEventDate.year, _selectedEventDate.month,
              _selectedEventDate.day, 14, 0),
          endTime: DateTime(_selectedEventDate.year, _selectedEventDate.month,
              _selectedEventDate.day, 15, 0),
          backgroundColor: Colors.deepOrange,
          textColor: Colors.white,
        ),
        CalendarEvent(
          id: '3',
          title: 'Lunch with Alex',
          startTime: DateTime(_selectedEventDate.year, _selectedEventDate.month,
              _selectedEventDate.day + 1, 12, 0),
          endTime: DateTime(_selectedEventDate.year, _selectedEventDate.month,
              _selectedEventDate.day + 1, 13, 0),
          backgroundColor: Colors.green,
          textColor: Colors.white,
        ),
      ];

  void _handleTableDateSelected(DateTime date) {
    setState(() => _selectedTableDate = date);
  }

  void _handleEventDateSelected(DateTime date) {
    setState(() {
      _selectedEventDate = date;
      _currentEventMonth = DateTime(date.year, date.month);
    });
  }

  Widget _buildCalendarCard(String title, Widget child) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.blue.shade100, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCalendar() {
    return HorizontalWeeklyCalendar(
      initialDate: DateTime.now(),
      selectedDate: _selectedTableDate,
      onDateSelected: _handleTableDateSelected,
      onNextMonth: () => setState(() => _selectedTableDate =
          _selectedTableDate.add(const Duration(days: 30))),
      onPreviousMonth: () => setState(() => _selectedTableDate =
          _selectedTableDate.subtract(const Duration(days: 30))),
      calendarStyle: const HorizontalCalendarStyle(
        activeDayColor: Colors.deepPurple,
        dayIndicatorSize: 45,
        selectedDayTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        dayNameStyle: TextStyle(fontSize: 12, color: Colors.deepPurple),
      ),
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.bounceInOut,
      iconColor: Colors.deepPurple,
    );
  }

  Widget _buildOutlinedCalendar() {
    return HorizontalWeeklyCalendar.outlined(
      initialDate: DateTime.now(),
      selectedDate: _selectedTableDate,
      onDateSelected: _handleTableDateSelected,
      onNextMonth: () => setState(() => _selectedTableDate =
          _selectedTableDate.add(const Duration(days: 30))),
      onPreviousMonth: () => setState(() => _selectedTableDate =
          _selectedTableDate.subtract(const Duration(days: 30))),
      calendarStyle: const HorizontalCalendarStyle(
        activeDayColor: Colors.teal,
        dayIndicatorSize: 40,
        dayIndicatorBorder:
            Border.fromBorderSide(BorderSide(color: Colors.teal, width: 2)),
        selectedDayTextStyle:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        dayNameStyle: TextStyle(fontSize: 10, color: Colors.teal),
      ),
      previousMonthIcon: Icons.chevron_left,
      nextMonthIcon: Icons.chevron_right,
      iconColor: Colors.teal,
      enableAnimations: true,
    );
  }

  Widget _buildMinimalCalendar() {
    return HorizontalWeeklyCalendar.minimal(
      initialDate: DateTime.now(),
      selectedDate: _selectedTableDate,
      onDateSelected: _handleTableDateSelected,
      onNextMonth: () => setState(() => _selectedTableDate =
          _selectedTableDate.add(const Duration(days: 30))),
      onPreviousMonth: () => setState(() => _selectedTableDate =
          _selectedTableDate.subtract(const Duration(days: 30))),
      calendarStyle: const HorizontalCalendarStyle(
        activeDayColor: Colors.orange,
        dayNumberStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      animationDuration: const Duration(milliseconds: 200),
      enableAnimations: true,
    );
  }

  Widget _buildElevatedCalendar() {
    return HorizontalWeeklyCalendar(
      initialDate: DateTime.now(),
      selectedDate: _selectedTableDate,
      onDateSelected: _handleTableDateSelected,
      onNextMonth: () => setState(() => _selectedTableDate =
          _selectedTableDate.add(const Duration(days: 30))),
      onPreviousMonth: () => setState(() => _selectedTableDate =
          _selectedTableDate.subtract(const Duration(days: 30))),
      calendarType: HorizontalCalendarType.elevated,
      calendarStyle: HorizontalCalendarStyle(
        activeDayColor: Colors.pink.shade200,
        dayIndicatorSize: 42,
        selectedDayTextStyle:
            const TextStyle(color: Colors.white, fontSize: 16),
        dayIndicatorShadow: BoxShadow(
          color: Colors.pink.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
        monthHeaderStyle: TextStyle(
          fontSize: 20,
          color: Colors.pink.shade600,
          fontWeight: FontWeight.w800,
        ),
      ),
      previousMonthIcon: Icons.keyboard_double_arrow_left,
      nextMonthIcon: Icons.keyboard_double_arrow_right,
      iconColor: Colors.pink.shade600,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Showcase'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendarCard('Standard Calendar', _buildStandardCalendar()),
            _buildCalendarCard('Outlined Calendar', _buildOutlinedCalendar()),
            _buildCalendarCard('Minimal Calendar', _buildMinimalCalendar()),
            _buildCalendarCard('Elevated Calendar', _buildElevatedCalendar()),
            _buildCalendarCard(
              'Table Weekly Calendar',
              TableWeeklyCalendar(
                initialDate: DateTime.now(),
                selectedDate: _selectedTableDate,
                onDateSelected: _handleTableDateSelected,
                onMonthChanged: (_) {},
                calendarStyle: const HorizontalCalendarStyle(
                  activeDayColor: Colors.teal,
                  dayIndicatorSize: 38,
                  selectedDayTextStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  dayNameStyle: TextStyle(fontSize: 11, color: Colors.teal),
                  monthHeaderStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                focusDates: _focusDates,
                showMonthHeader: true,
                iconColor: Colors.teal,
                enableAnimations: true,
                useFocusDateColor: true,
                tablePadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                headerBuilder: (context, currentDate, onPrev, onNext) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: onPrev),
                      Text(
                          'Custom Header: \\${currentDate.month}/\\${currentDate.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: onNext),
                    ],
                  );
                },
              ),
            ),
            _buildCalendarCard(
              'Event Calendar',
              EventCalendar(
                currentMonth: _currentEventMonth,
                selectedDate: _selectedEventDate,
                events: _events,
                onDateSelected: _handleEventDateSelected,
                onNextMonth: () => setState(() {
                  _currentEventMonth = DateTime(
                      _currentEventMonth.year, _currentEventMonth.month + 1);
                }),
                onPreviousMonth: () => setState(() {
                  _currentEventMonth = DateTime(
                      _currentEventMonth.year, _currentEventMonth.month - 1);
                }),
                style: const EventCalendarStyle(
                  activeDayColor: Colors.deepOrange,
                  dayIndicatorSize: 36,
                  selectedDayTextStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  dayNameStyle:
                      TextStyle(fontSize: 11, color: Colors.deepOrange),
                  monthHeaderStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange),
                ),
                eventBuilder: (context, event) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: event.backgroundColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.title,
                          style: TextStyle(
                              color: event.textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
