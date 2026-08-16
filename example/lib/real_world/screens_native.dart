import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';
import 'package:intl/intl.dart';

import 'data.dart';
import 'shell.dart';

/// Reminder scheduling that follows iOS conventions end to end.
///
/// The navigation bar, wheels, and month grid all read from the same platform
/// style, so the screen looks native without a platform branch in the app.
class NativeRemindersScreen extends StatefulWidget {
  const NativeRemindersScreen({super.key});

  @override
  State<NativeRemindersScreen> createState() => _NativeRemindersScreenState();
}

class _NativeRemindersScreenState extends State<NativeRemindersScreen> {
  DateTime _month = DateTime(2026, 8);
  DateTime _selected = demoToday;
  DateTime _remindAt = DateTime(2026, 8, 12, 18, 30);

  static const CalendarAppearance _appearance = CalendarAppearance(
    style: CalendarStyle.cupertinoGlass,
    showHeader: false,
  );

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      product: 'Rundown',
      title: 'New reminder',
      accent: const Color(0xFF0A84FF),
      children: (context) => [
        ExampleSection(
          title: 'Due date',
          caption: 'Adaptive chrome, native wheels, one shared style.',
          child: ExampleCard(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Column(
              children: [
                AdaptiveCalendarNavigationBar(
                  focusedDate: _month,
                  onPrevious: () => setState(
                    () => _month = DateTime(_month.year, _month.month - 1),
                  ),
                  onNext: () => setState(
                    () => _month = DateTime(_month.year, _month.month + 1),
                  ),
                  onToday: () => setState(() {
                    _month = DateTime(demoToday.year, demoToday.month);
                    _selected = demoToday;
                  }),
                  appearance: _appearance,
                ),
                const SizedBox(height: 6),
                MonthCalendar<Object?>.single(
                  month: _month,
                  selectedDate: _selected,
                  onDateSelected: (date) => setState(() => _selected = date),
                  appearance: CalendarAppearance(
                    style: CalendarStyle.cupertinoGlass,
                    showHeader: false,
                    motion: CalendarMotion.snappy(),
                  ),
                ),
              ],
            ),
          ),
        ),
        ExampleSection(
          title: 'Remind me at',
          child: ExampleCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: CalendarCupertinoDatePicker(
              value: _remindAt,
              onChanged: (value) => setState(() => _remindAt = value),
              bounds: CalendarDateRange(
                DateTime(2026, 8, 1),
                DateTime(2026, 12, 31),
              ),
              configuration: const CalendarCupertinoPickerConfiguration(
                mode: CalendarCupertinoPickerMode.dateAndTime,
                minuteInterval: 5,
                showDayOfWeek: true,
              ),
              style: const CalendarCupertinoPickerStyle(height: 196),
              appearance: _appearance,
            ),
          ),
        ),
        ExampleCard(
          child: Column(
            children: [
              ExampleRow(
                accent: const Color(0xFF0A84FF),
                title: 'Collect the rushes',
                subtitle: DateFormat.MMMEd().add_jm().format(_remindAt),
                icon: Icons.notifications_active_outlined,
              ),
              ExampleRow(
                accent: const Color(0xFF64748B),
                title: 'Repeat',
                subtitle: 'Never',
                trailing: DateFormat.MMMd().format(_selected),
                icon: Icons.repeat_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sleep tracking built on the celestial date picker.
class LunarSleepScreen extends StatefulWidget {
  const LunarSleepScreen({super.key});

  @override
  State<LunarSleepScreen> createState() => _LunarSleepScreenState();
}

class _LunarSleepScreenState extends State<LunarSleepScreen> {
  DateTime _date = demoToday;

  static const List<(String, String, IconData)> _summary = [
    ('Time asleep', '7h 24m', Icons.bedtime_outlined),
    ('Went to bed', '23:12', Icons.nights_stay_outlined),
    ('Woke up', '06:41', Icons.wb_twilight_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      product: 'Lunar',
      title: 'Sleep log',
      accent: const Color(0xFF7C6BFF),
      brightness: Brightness.dark,
      children: (context) => [
        ExampleSection(
          title: DateFormat.yMMMMEEEEd().format(_date),
          caption: 'Drag sideways to move through the nights.',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CelestialDatePicker(
              value: _date,
              onChanged: (date) => setState(() => _date = date),
              bounds: CalendarDateRange(
                DateTime(2026, 1, 1),
                DateTime(2026, 12, 31),
              ),
              appearance: CalendarAppearance(
                style: CalendarStyle.midnight,
                showHeader: false,
                motion: CalendarMotion.cinematic(),
              ),
              style: const CelestialDatePickerStyle(
                skyHeight: 216,
                skyStyle: CelestialSkyStyle.aurora,
                composition: CelestialComposition.cinematic,
                showConstellations: true,
                showPhaseOrbit: true,
                showDateProgress: true,
              ),
            ),
          ),
        ),
        ExampleSection(
          title: 'Last night',
          child: ExampleCard(
            child: Column(
              children: [
                for (final entry in _summary)
                  ExampleRow(
                    accent: const Color(0xFF7C6BFF),
                    title: entry.$1,
                    trailing: entry.$2,
                    icon: entry.$3,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
