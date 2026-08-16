import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';
import 'package:intl/intl.dart';

import 'data.dart';
import 'shell.dart';

/// Parcel tracking built on the agenda, fed by an asynchronous source.
///
/// The agenda owns loading, error, empty, and populated states, and pull to
/// refresh reloads the same source.
class ParcelTrackingScreen extends StatefulWidget {
  const ParcelTrackingScreen({super.key});

  @override
  State<ParcelTrackingScreen> createState() => _ParcelTrackingScreenState();
}

class _ParcelTrackingScreenState extends State<ParcelTrackingScreen> {
  final ParcelEventSource _source = ParcelEventSource();
  CalendarEvent<Booking>? _selected;

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      product: 'Parcel',
      title: 'TRK-88213',
      accent: const Color(0xFFEF6C4D),
      padding: EdgeInsets.zero,
      children: (context) => [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ExampleCard(
            child: ExampleRow(
              accent: const Color(0xFFEF6C4D),
              title: _selected?.title ?? 'Out for delivery',
              subtitle: _selected == null
                  ? 'Arriving Thursday, before 18:00'
                  : DateFormat.MMMEd().add_jm().format(_selected!.start),
              trailing: _selected?.data?.reference ?? 'TRK-88213',
              icon: Icons.local_shipping_outlined,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Text(
            'Tracking history',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 470,
          child: CalendarAgenda<Booking>(
            interval: CalendarVisibleInterval(
              DateTime(2026, 8, 11),
              DateTime(2026, 8, 17),
            ),
            eventSource: _source,
            onEventTap: (event) => setState(() => _selected = event),
            appearance: CalendarAppearance(
              style: CalendarStyle.paper,
              showHeader: false,
              motion: CalendarMotion.fluid(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Habit tracker built on the heatmap, streak strip, and insight dashboard.
class StreakHabitsScreen extends StatefulWidget {
  const StreakHabitsScreen({super.key});

  @override
  State<StreakHabitsScreen> createState() => _StreakHabitsScreenState();
}

class _StreakHabitsScreenState extends State<StreakHabitsScreen> {
  DateTime _selected = demoToday;

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      product: 'Streak',
      title: 'Morning pages',
      accent: const Color(0xFF9B4DE0),
      brightness: Brightness.dark,
      children: (context) => [
        ExampleSection(
          title: 'This month',
          caption: DateFormat.yMMMMd().format(_selected),
          child: CalendarStreakStrip(
            startDate: DateTime(2026, 8, 1),
            dayCount: 31,
            today: demoToday,
            selectedDate: _selected,
            completedDates: habitCompletedDates,
            onDateTap: (date) => setState(() => _selected = date),
            appearance: const CalendarAppearance(
              style: CalendarStyle.neon,
              showHeader: false,
            ),
          ),
        ),
        ExampleSection(
          title: 'Year at a glance',
          caption: 'Every day since January.',
          child: ExampleCard(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 196,
              child: CalendarContributionHeatmap(
                startDate: DateTime(2026, 1, 1),
                dayCount: 224,
                values: habitYearValues,
                selectedDate: _selected,
                onDateTap: (date) => setState(() => _selected = date),
                appearance: const CalendarAppearance(
                  style: CalendarStyle.aurora,
                  showHeader: false,
                ),
                style: const CalendarHeatmapStyle(
                  design: CalendarHeatmapDesign.pill,
                  cellExtent: 32,
                  cellSpacing: 4,
                  showLabels: false,
                  animate: true,
                ),
              ),
            ),
          ),
        ),
        ExampleSection(
          title: 'Signals',
          child: CalendarInsightsDashboard<Booking>(
            metrics: habitMetrics,
            design: CalendarInsightsDesign.glass,
            appearance: const CalendarAppearance(
              style: CalendarStyle.midnight,
              showHeader: false,
            ),
          ),
        ),
      ],
    );
  }
}

/// Launch countdown built on the countdown card and the heatmap strip.
class LaunchCountdownScreen extends StatelessWidget {
  const LaunchCountdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      product: 'Runway',
      title: 'Release readiness',
      accent: const Color(0xFF5547D7),
      children: (context) => [
        ExampleSection(
          title: 'Ship date',
          caption: 'Progress runs from kickoff to launch.',
          child: CalendarCountdownCard<Booking>(
            targetDate: DateTime(2026, 8, 24),
            referenceDate: demoToday,
            startDate: DateTime(2026, 7, 6),
            title: 'Version 2.0',
            appearance: const CalendarAppearance(
              style: CalendarStyle.bold,
              showHeader: false,
            ),
          ),
        ),
        ExampleSection(
          title: 'Daily burn-down',
          caption: 'Share of the release checklist closed each day.',
          child: CalendarHeatmapStrip(
            startDate: DateTime(2026, 8, 1),
            dayCount: 31,
            values: {
              for (var day = 1; day <= 31; day += 1)
                DateTime(2026, 8, day): (day % 7) / 7,
            },
            selectedDate: demoToday,
            appearance: const CalendarAppearance(
              style: CalendarStyle.materialExpressive,
              showHeader: false,
            ),
            style: const CalendarHeatmapStyle(
              design: CalendarHeatmapDesign.ring,
              animate: true,
              showPercentage: true,
            ),
          ),
        ),
        ExampleCard(
          child: Column(
            children: const [
              ExampleRow(
                accent: Color(0xFF1FA37A),
                title: 'Motion pass complete',
                subtitle: 'Gesture following on every surface',
                trailing: 'Done',
                icon: Icons.check_circle_outline,
              ),
              ExampleRow(
                accent: Color(0xFFB4881F),
                title: 'Screenshots refreshed',
                subtitle: 'Captured on iPhone 17 simulator',
                trailing: 'In review',
                icon: Icons.photo_camera_outlined,
              ),
              ExampleRow(
                accent: Color(0xFF64748B),
                title: 'Migration guide',
                subtitle: 'Draft ready for the release notes',
                trailing: 'Queued',
                icon: Icons.menu_book_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Home-screen and lock-screen widgets rendered from one serializable payload.
class GlanceWidgetsScreen extends StatelessWidget {
  const GlanceWidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = CalendarHomeWidgetData(
      generatedAt: DateTime(2026, 8, 12, 7, 40),
      selectedDate: demoToday,
      title: 'Wednesday',
      subtitle: 'Three things before lunch',
      targetDate: DateTime(2026, 8, 24),
      completedCount: 3,
      totalCount: 5,
      action: const CalendarHomeWidgetAction(
        uri: 'glance://today',
        label: 'Open Glance',
      ),
      events: [
        CalendarHomeWidgetEvent(
          id: 'standup',
          title: 'Team standup',
          subtitle: 'Product',
          location: 'Zoom',
          start: DateTime(2026, 8, 12, 9),
          end: DateTime(2026, 8, 12, 9, 15),
          colorValue: 0xFF5547D7,
        ),
        CalendarHomeWidgetEvent(
          id: 'shoot',
          title: 'Campaign shoot',
          subtitle: 'Studio A',
          location: 'Ground floor',
          start: DateTime(2026, 8, 12, 9, 30),
          end: DateTime(2026, 8, 12, 13),
          colorValue: 0xFFEF6C4D,
        ),
        CalendarHomeWidgetEvent(
          id: 'review',
          title: 'Rough cut review',
          subtitle: 'Editorial',
          start: DateTime(2026, 8, 12, 14, 30),
          end: DateTime(2026, 8, 12, 16),
          colorValue: 0xFF2E7BEA,
        ),
      ],
    );
    const theme = CalendarHomeWidgetTheme(
      surfaceStyle: CalendarHomeWidgetSurfaceStyle.gradient,
      gradientColors: [Color(0xFF241C4A), Color(0xFF0E1020)],
      accentColor: Color(0xFF9F8CFF),
      cornerRadius: 26,
      eventStyle: CalendarHomeWidgetEventStyle.card,
      progressStyle: CalendarHomeWidgetProgressStyle.segmented,
    );

    return ExampleScaffold(
      product: 'Glance',
      title: 'Home screen widgets',
      accent: const Color(0xFF9F8CFF),
      brightness: Brightness.dark,
      children: (context) => [
        ExampleSection(
          title: 'Medium · this week',
          caption: 'One payload, rendered natively on both platforms.',
          child: SizedBox(
            height: 158,
            child: CalendarHomeWidget(
              data: data,
              family: CalendarHomeWidgetFamily.medium,
              content: CalendarHomeWidgetContent.week,
              theme: theme,
            ),
          ),
        ),
        ExampleSection(
          title: 'Large · agenda',
          child: SizedBox(
            height: 320,
            child: CalendarHomeWidget(
              data: data,
              family: CalendarHomeWidgetFamily.large,
              content: CalendarHomeWidgetContent.agenda,
              theme: theme,
            ),
          ),
        ),
        ExampleSection(
          title: 'Small · countdown and progress',
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 158,
                  child: CalendarHomeWidget(
                    data: data,
                    family: CalendarHomeWidgetFamily.small,
                    content: CalendarHomeWidgetContent.countdown,
                    theme: theme,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 158,
                  child: CalendarHomeWidget(
                    data: data,
                    family: CalendarHomeWidgetFamily.small,
                    content: CalendarHomeWidgetContent.progress,
                    theme: theme,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
