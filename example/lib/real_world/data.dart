import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

/// The product payload every real-world screen attaches to its dates.
///
/// Real applications rarely have a bare title: they carry a record that has to
/// come back out of the calendar unchanged. Every screen in this suite stores
/// one of these and reads it back from the callbacks.
@immutable
class Booking {
  const Booking({
    required this.reference,
    required this.owner,
    this.room,
    this.priceCents,
  });

  final String reference;
  final String owner;
  final String? room;
  final int? priceCents;
}

/// A single day of demo content shared by the fitness and journal screens.
@immutable
class DayEntry {
  const DayEntry({
    required this.headline,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String headline;
  final String detail;
  final IconData icon;
  final Color accent;
}

/// Fixed "today" so every screenshot and demo reads identically.
final DateTime demoToday = DateTime(2026, 8, 12);

DateTime _at(int day, int hour, [int minute = 0]) =>
    DateTime(2026, 8, day, hour, minute);

/// Training sessions for the fitness screen.
final List<CalendarEvent<Booking>> workoutEvents = [
  CalendarEvent(
    id: 'w-intervals',
    title: 'Interval run · 8 km',
    start: _at(10, 6, 30),
    end: _at(10, 7, 20),
    color: const Color(0xFFEF6C4D),
    data: const Booking(reference: 'W-1041', owner: 'Coach Amara'),
  ),
  CalendarEvent(
    id: 'w-strength',
    title: 'Lower body strength',
    start: _at(11, 18),
    end: _at(11, 19, 15),
    color: const Color(0xFF5547D7),
    data: const Booking(reference: 'W-1042', owner: 'Coach Amara'),
  ),
  CalendarEvent(
    id: 'w-mobility',
    title: 'Mobility & core',
    start: _at(12, 7),
    end: _at(12, 7, 40),
    color: const Color(0xFF1FA37A),
    data: const Booking(reference: 'W-1043', owner: 'Self-guided'),
  ),
  CalendarEvent(
    id: 'w-tempo',
    title: 'Tempo ride · 32 km',
    start: _at(12, 17, 30),
    end: _at(12, 18, 45),
    color: const Color(0xFF2E7BEA),
    data: const Booking(reference: 'W-1044', owner: 'Coach Amara'),
  ),
  CalendarEvent(
    id: 'w-swim',
    title: 'Open water swim',
    start: _at(14, 6, 45),
    end: _at(14, 7, 45),
    color: const Color(0xFF00A5C4),
    data: const Booking(reference: 'W-1045', owner: 'Lakeside club'),
  ),
  CalendarEvent(
    id: 'w-long',
    title: 'Long run · 18 km',
    start: _at(16, 8),
    end: _at(16, 9, 40),
    color: const Color(0xFFEF6C4D),
    data: const Booking(reference: 'W-1046', owner: 'Coach Amara'),
  ),
];

/// One production studio day for the day timeline screen.
final List<CalendarEvent<Booking>> studioDayEvents = [
  CalendarEvent(
    id: 's-standup',
    title: 'Team standup',
    start: _at(12, 9),
    end: _at(12, 9, 15),
    color: const Color(0xFF5547D7),
    data: const Booking(reference: 'S-3301', owner: 'Whole team', room: 'Zoom'),
  ),
  CalendarEvent(
    id: 's-shoot',
    title: 'Campaign shoot · Studio A',
    start: _at(12, 9, 30),
    end: _at(12, 13),
    color: const Color(0xFFEF6C4D),
    data: const Booking(
      reference: 'S-3302',
      owner: 'Noor Haddad',
      room: 'Studio A',
    ),
  ),
  CalendarEvent(
    id: 's-lighting',
    title: 'Lighting reset',
    start: _at(12, 11),
    end: _at(12, 12),
    color: const Color(0xFFB4881F),
    data: const Booking(
      reference: 'S-3303',
      owner: 'Grip crew',
      room: 'Studio A',
    ),
  ),
  CalendarEvent(
    id: 's-lunch',
    title: 'Crew lunch',
    start: _at(12, 13),
    end: _at(12, 14),
    color: const Color(0xFF1FA37A),
    data: const Booking(reference: 'S-3304', owner: 'Catering'),
  ),
  CalendarEvent(
    id: 's-edit',
    title: 'Rough cut review',
    start: _at(12, 14, 30),
    end: _at(12, 16),
    color: const Color(0xFF2E7BEA),
    data: const Booking(
      reference: 'S-3305',
      owner: 'Editorial',
      room: 'Edit 2',
    ),
  ),
  CalendarEvent(
    id: 's-client',
    title: 'Client walkthrough',
    start: _at(12, 15, 30),
    end: _at(12, 16, 30),
    color: const Color(0xFF9B4DE0),
    data: const Booking(
      reference: 'S-3306',
      owner: 'Account team',
      room: 'Edit 2',
    ),
  ),
  CalendarEvent(
    id: 's-wrap',
    title: 'Wrap & equipment return',
    start: _at(12, 17),
    end: _at(12, 18),
    color: const Color(0xFF64748B),
    data: const Booking(reference: 'S-3307', owner: 'Grip crew'),
  ),
];

/// Field-service shifts spread across a week for the week timeline screen.
final List<CalendarEvent<Booking>> shiftEvents = [
  for (final (index, entry) in <(int, String, int, int, Color)>[
    (10, 'Route 4 · North', 7, 12, Color(0xFF2E7BEA)),
    (10, 'Depot restock', 13, 16, Color(0xFF64748B)),
    (11, 'Route 2 · Harbour', 6, 11, Color(0xFF1FA37A)),
    (11, 'Vehicle service', 14, 17, Color(0xFFB4881F)),
    (12, 'Route 4 · North', 7, 12, Color(0xFF2E7BEA)),
    (12, 'Install · Oakfield', 13, 17, Color(0xFF9B4DE0)),
    (13, 'Route 7 · Riverside', 8, 13, Color(0xFFEF6C4D)),
    (14, 'Route 2 · Harbour', 6, 11, Color(0xFF1FA37A)),
    (14, 'Team debrief', 16, 17, Color(0xFF5547D7)),
    (15, 'Weekend cover', 9, 15, Color(0xFF00A5C4)),
  ].indexed)
    CalendarEvent(
      id: 'shift-$index',
      title: entry.$2,
      start: _at(entry.$1, entry.$3),
      end: _at(entry.$1, entry.$4),
      color: entry.$5,
      data: Booking(reference: 'SH-${4200 + index}', owner: 'Field ops'),
    ),
];

/// Journal entries used by the foldable screen.
final Map<int, DayEntry> journalEntries = {
  9: const DayEntry(
    headline: 'Slow Sunday',
    detail: 'Read two chapters on the balcony. Called home.',
    icon: Icons.local_cafe_outlined,
    accent: Color(0xFFB4881F),
  ),
  10: const DayEntry(
    headline: 'Back to the desk',
    detail: 'Shipped the export pipeline. Felt clear-headed all morning.',
    icon: Icons.bolt_outlined,
    accent: Color(0xFF5547D7),
  ),
  11: const DayEntry(
    headline: 'Long walk',
    detail: 'Ten kilometres along the canal. Sorted out the pricing question.',
    icon: Icons.directions_walk_outlined,
    accent: Color(0xFF1FA37A),
  ),
  12: const DayEntry(
    headline: 'Studio day',
    detail: 'Shoot ran long but the rough cut already looks right.',
    icon: Icons.videocam_outlined,
    accent: Color(0xFFEF6C4D),
  ),
  13: const DayEntry(
    headline: 'Quiet evening',
    detail: 'Cooked properly for once. Early night.',
    icon: Icons.nightlight_outlined,
    accent: Color(0xFF2E7BEA),
  ),
};

/// Parcel movements for the agenda screen, served asynchronously.
class ParcelEventSource implements CalendarEventSource<Booking> {
  ParcelEventSource({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  @override
  Future<List<CalendarEvent<Booking>>> load(
    CalendarVisibleInterval interval,
  ) async {
    await Future<void>.delayed(latency);
    return [
      for (final (index, entry) in <(int, String, int, String, Color)>[
        (11, 'Collected · Rotterdam hub', 17, 'TRK-88213', Color(0xFF64748B)),
        (12, 'Departed · Rotterdam hub', 6, 'TRK-88213', Color(0xFF2E7BEA)),
        (12, 'Customs cleared', 11, 'TRK-88213', Color(0xFFB4881F)),
        (13, 'Arrived · Dublin depot', 9, 'TRK-88213', Color(0xFF1FA37A)),
        (13, 'Out for delivery', 13, 'TRK-88213', Color(0xFFEF6C4D)),
        (
          14,
          'Delivery attempt · signature needed',
          10,
          'TRK-88213',
          Color(0xFF9B4DE0)
        ),
        (15, 'Redelivery scheduled', 8, 'TRK-88213', Color(0xFF00A5C4)),
      ].indexed)
        CalendarEvent(
          id: 'parcel-$index',
          title: entry.$2,
          start: _at(entry.$1, entry.$3),
          end: _at(entry.$1, entry.$3 + 1),
          color: entry.$5,
          data: Booking(reference: entry.$4, owner: 'Ada Mensah'),
        ),
    ];
  }
}

/// Fare-per-day used by the flight carousel screen, in whole euros.
const Map<int, int> flightFares = {
  10: 148,
  11: 132,
  12: 96,
  13: 96,
  14: 118,
  15: 174,
  16: 212,
  17: 168,
  18: 121,
  19: 104,
  20: 99,
  21: 143,
};

/// Clinic slot availability keyed by day of month.
final Map<int, List<(String, int, int, CalendarAvailabilityState)>>
    clinicSlots = {
  12: [
    ('08:30', 8, 30, CalendarAvailabilityState.unavailable),
    ('09:15', 9, 15, CalendarAvailabilityState.available),
    ('10:00', 10, 0, CalendarAvailabilityState.available),
    ('11:30', 11, 30, CalendarAvailabilityState.limited),
    ('14:00', 14, 0, CalendarAvailabilityState.available),
    ('15:45', 15, 45, CalendarAvailabilityState.unavailable),
  ],
  13: [
    ('09:00', 9, 0, CalendarAvailabilityState.available),
    ('10:30', 10, 30, CalendarAvailabilityState.limited),
    ('13:15', 13, 15, CalendarAvailabilityState.available),
    ('16:00', 16, 0, CalendarAvailabilityState.available),
  ],
  14: [
    ('08:00', 8, 0, CalendarAvailabilityState.limited),
    ('11:00', 11, 0, CalendarAvailabilityState.available),
    ('14:30', 14, 30, CalendarAvailabilityState.unavailable),
  ],
};

/// Habit completion values for the streak screen, keyed by day of year offset.
final Map<int, double> habitIntensity = {
  for (var index = 0; index < 224; index += 1)
    index: switch (index % 11) {
      0 || 4 => 0.0,
      1 || 7 => .35,
      2 || 5 || 9 => .7,
      _ => 1.0,
    },
};

/// Contribution values for the year heatmap, keyed by civil date.
Map<DateTime, double> get habitYearValues => {
      for (final entry in habitIntensity.entries)
        DateTime(2026, 1, 1).add(Duration(days: entry.key)): entry.value,
    };

/// Dates the habit was completed, used by the streak strip.
Set<DateTime> get habitCompletedDates => {
      for (var day = 1; day <= 31; day += 1)
        if (day % 4 != 0) DateTime(2026, 8, day),
    };

/// Sleep summary metrics for the insights dashboard.
List<CalendarInsightMetric<Booking>> get habitMetrics => [
      CalendarInsightMetric(
        id: 'streak',
        label: 'Current streak',
        value: '18 days',
        supportingText: 'Longest this year',
        trend: CalendarInsightTrend.up,
        icon: Icons.local_fire_department_outlined,
        progress: .82,
      ),
      CalendarInsightMetric(
        id: 'consistency',
        label: 'Consistency',
        value: '86%',
        supportingText: '+7% vs July',
        trend: CalendarInsightTrend.up,
        icon: Icons.insights_outlined,
        progress: .86,
      ),
      CalendarInsightMetric(
        id: 'rest',
        label: 'Rest days',
        value: '6',
        supportingText: 'Planned, not missed',
        trend: CalendarInsightTrend.steady,
        icon: Icons.self_improvement_outlined,
        progress: .2,
      ),
      CalendarInsightMetric(
        id: 'load',
        label: 'Weekly load',
        value: '412 TSS',
        supportingText: '−4% vs last week',
        trend: CalendarInsightTrend.down,
        icon: Icons.monitor_heart_outlined,
        progress: .64,
      ),
    ];
