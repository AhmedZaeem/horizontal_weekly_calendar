import 'package:flutter/material.dart';

import 'hero.dart';
import 'home_screen_showcase.dart';
import 'screens_booking.dart';
import 'screens_data.dart';
import 'screens_native.dart';
import 'screens_scheduling.dart';

/// One entry in the real-world example catalogue.
@immutable
class RealWorldExample {
  const RealWorldExample({
    required this.id,
    required this.product,
    required this.summary,
    required this.surface,
    required this.icon,
    required this.accent,
    required this.builder,
  });

  /// Stable route segment, also used as the screenshot file name.
  final String id;

  /// Fictional product the screen belongs to.
  final String product;

  /// What the screen does.
  final String summary;

  /// Library surface the screen is built on.
  final String surface;

  final IconData icon;
  final Color accent;
  final WidgetBuilder builder;

  /// Route this example is registered under.
  String get route => '/real-world/$id';
}

/// Every real-world example, one per calendar surface.
final List<RealWorldExample> realWorldExamples = [
  RealWorldExample(
    id: 'training-week',
    product: 'Pulse',
    summary: 'Week strip with session indicators and a day summary.',
    surface: 'HorizontalCalendar · CalendarWeekProgress',
    icon: Icons.fitness_center_outlined,
    accent: const Color(0xFFEF6C4D),
    builder: (_) => const PulseTrainingScreen(),
  ),
  RealWorldExample(
    id: 'fare-carousel',
    product: 'Skyline',
    summary: 'Date cards carrying live fares, snapping one at a time.',
    surface: 'CalendarDateCarousel',
    icon: Icons.flight_takeoff_outlined,
    accent: const Color(0xFF2E7BEA),
    builder: (_) => const SkylineFaresScreen(),
  ),
  RealWorldExample(
    id: 'clinic-booking',
    product: 'Northside Health',
    summary: 'Month grid with availability rules and 30-minute slots.',
    surface: 'MonthCalendar · CalendarAvailabilityStrip',
    icon: Icons.medical_services_outlined,
    accent: const Color(0xFF1FA37A),
    builder: (_) => const ClinicBookingScreen(),
  ),
  RealWorldExample(
    id: 'stay-range',
    product: 'Aster Stays',
    summary: 'Controlled range selection with a live price breakdown.',
    surface: 'HorizontalCalendar.controlled',
    icon: Icons.hotel_outlined,
    accent: const Color(0xFFB4881F),
    builder: (_) => const AsterStaysScreen(),
  ),
  RealWorldExample(
    id: 'studio-day',
    product: 'Studio Ops',
    summary: 'Overlapping bookings on a live single-day timeline.',
    surface: 'DayTimeline',
    icon: Icons.videocam_outlined,
    accent: const Color(0xFF2E7BEA),
    builder: (_) => const StudioDayScreen(),
  ),
  RealWorldExample(
    id: 'shift-board',
    product: 'Shift Board',
    summary: 'Seven-column field rota on a dark surface.',
    surface: 'WeekTimeline',
    icon: Icons.local_shipping_outlined,
    accent: const Color(0xFF1FA37A),
    builder: (_) => const ShiftBoardScreen(),
  ),
  RealWorldExample(
    id: 'journal',
    product: 'Margin',
    summary: 'Week that folds into a month under your finger.',
    surface: 'FoldableCalendar',
    icon: Icons.edit_note_outlined,
    accent: const Color(0xFF9B4DE0),
    builder: (_) => const MarginJournalScreen(),
  ),
  RealWorldExample(
    id: 'parcel-agenda',
    product: 'Parcel',
    summary: 'Asynchronous tracking history with pull to refresh.',
    surface: 'CalendarAgenda · CalendarEventSource',
    icon: Icons.inventory_2_outlined,
    accent: const Color(0xFFEF6C4D),
    builder: (_) => const ParcelTrackingScreen(),
  ),
  RealWorldExample(
    id: 'habit-streaks',
    product: 'Streak',
    summary: 'Streak strip, year heatmap, and derived signals.',
    surface: 'CalendarStreakStrip · CalendarContributionHeatmap',
    icon: Icons.local_fire_department_outlined,
    accent: const Color(0xFF9B4DE0),
    builder: (_) => const StreakHabitsScreen(),
  ),
  RealWorldExample(
    id: 'release-countdown',
    product: 'Runway',
    summary: 'Countdown to ship day with a daily burn-down.',
    surface: 'CalendarCountdownCard · CalendarHeatmapStrip',
    icon: Icons.rocket_launch_outlined,
    accent: const Color(0xFF5547D7),
    builder: (_) => const LaunchCountdownScreen(),
  ),
  RealWorldExample(
    id: 'native-reminder',
    product: 'Rundown',
    summary: 'iOS chrome, native wheels, and a month grid in one flow.',
    surface: 'AdaptiveCalendarNavigationBar · CalendarCupertinoDatePicker',
    icon: Icons.phone_iphone_outlined,
    accent: const Color(0xFF0A84FF),
    builder: (_) => const NativeRemindersScreen(),
  ),
  RealWorldExample(
    id: 'sleep-log',
    product: 'Lunar',
    summary: 'Sun and moon path standing in for a date wheel.',
    surface: 'CelestialDatePicker',
    icon: Icons.nightlight_outlined,
    accent: const Color(0xFF7C6BFF),
    builder: (_) => const LunarSleepScreen(),
  ),
  RealWorldExample(
    id: 'home-widgets',
    product: 'Glance',
    summary: 'One payload rendered across every widget family.',
    surface: 'CalendarHomeWidget',
    icon: Icons.widgets_outlined,
    accent: const Color(0xFF9F8CFF),
    builder: (_) => const GlanceWidgetsScreen(),
  ),
];

/// Routes for every real-world example, plus the capture-only surfaces.
///
/// The poster and home-screen showcase exist to render the README artwork from
/// live widgets, so the documentation cannot drift from the package.
Map<String, WidgetBuilder> get realWorldRoutes => {
      for (final example in realWorldExamples) example.route: example.builder,
      '/hero': (_) => const HeroPosterPage(),
      '/home-screen': (_) => const HomeScreenShowcasePage(),
    };

/// Catalogue of the real-world examples.
class RealWorldIndexPage extends StatelessWidget {
  const RealWorldIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-world examples'),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        itemCount: realWorldExamples.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Each screen is a small product built on one calendar surface, '
                'with the data model an application would actually pass in.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          final example = realWorldExamples[index - 1];
          return _ExampleTile(example: example);
        },
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.example});

  final RealWorldExample example;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).pushNamed(example.route),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: example.accent.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(example.icon, color: example.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      example.product,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      example.summary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      example.surface,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: example.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
