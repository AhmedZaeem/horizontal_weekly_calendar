import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/src/horizontal_weekly_calendar_widget.dart';

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
  DateTime _selectedDate = DateTime.now();

  void _handleDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
  }

  Widget _buildCalendarCard(String title, Widget child) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.blue.shade100, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Styles Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendarCard(
              'Standard Calendar',
              _buildStandardCalendar(),
            ),
            _buildCalendarCard(
              'Outlined Calendar',
              _buildOutlinedCalendar(),
            ),
            _buildCalendarCard(
              'Minimal Calendar',
              _buildMinimalCalendar(),
            ),
            _buildCalendarCard(
              'Elevated Calendar',
              _buildElevatedCalendar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCalendar() {
    return HorizontalWeeklyCalendar(
      initialDate: DateTime.now(),
      selectedDate: _selectedDate,
      onDateSelected: _handleDateSelected,
      onNextMonth: () => setState(
          () => _selectedDate = _selectedDate.add(const Duration(days: 30))),
      onPreviousMonth: () => setState(() =>
          _selectedDate = _selectedDate.subtract(const Duration(days: 30))),
      calendarStyle: HorizontalCalendarStyle(
        activeDayColor: Colors.deepPurple,
        dayIndicatorSize: 45,
        selectedDayTextStyle:
            const TextStyle(color: Colors.white, fontSize: 18),
        inactiveDayTextStyle: TextStyle(color: Colors.grey.shade600),
        dayIndicatorShadow: BoxShadow(
          color: Colors.deepPurple.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ),
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.bounceInOut,
      iconColor: Colors.deepPurple,
    );
  }

  Widget _buildOutlinedCalendar() {
    return HorizontalWeeklyCalendar.outlined(
      initialDate: DateTime.now(),
      selectedDate: _selectedDate,
      onDateSelected: _handleDateSelected,
      onNextMonth: () => setState(
          () => _selectedDate = _selectedDate.add(const Duration(days: 30))),
      onPreviousMonth: () => setState(() =>
          _selectedDate = _selectedDate.subtract(const Duration(days: 30))),
      calendarStyle: HorizontalCalendarStyle(
        activeDayColor: Colors.teal,
        dayIndicatorSize: 40,
        dayIndicatorBorder: Border.all(color: Colors.teal, width: 2),
        selectedDayTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        dayNameStyle: const TextStyle(fontSize: 10, color: Colors.teal),
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
      selectedDate: _selectedDate,
      onDateSelected: _handleDateSelected,
      onNextMonth: () => setState(
          () => _selectedDate = _selectedDate.add(const Duration(days: 30))),
      onPreviousMonth: () => setState(() =>
          _selectedDate = _selectedDate.subtract(const Duration(days: 30))),
      calendarStyle: HorizontalCalendarStyle(
        activeDayColor: Colors.orange,
        dayNumberStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        inactiveDayTextStyle: TextStyle(color: Colors.grey.shade400),
      ),
      animationDuration: const Duration(milliseconds: 200),
      enableAnimations: true,
    );
  }

  Widget _buildElevatedCalendar() {
    return HorizontalWeeklyCalendar(
      initialDate: DateTime.now(),
      selectedDate: _selectedDate,
      onDateSelected: _handleDateSelected,
      onNextMonth: () => setState(
          () => _selectedDate = _selectedDate.add(const Duration(days: 30))),
      onPreviousMonth: () => setState(() =>
          _selectedDate = _selectedDate.subtract(const Duration(days: 30))),
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
}
