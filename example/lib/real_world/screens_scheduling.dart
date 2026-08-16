import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';
import 'package:intl/intl.dart';

import 'data.dart';
import 'shell.dart';

/// Training app built on the horizontal week strip.
///
/// Shows the pattern most products need first: a week of dates with activity
/// indicators, a day summary underneath, and everything driven by one
/// controlled selected date.
class PulseTrainingScreen extends StatefulWidget {
  const PulseTrainingScreen({super.key});

  @override
  State<PulseTrainingScreen> createState() => _PulseTrainingScreenState();
}

class _PulseTrainingScreenState extends State<PulseTrainingScreen> {
  DateTime _selected = demoToday;

  List<CalendarEvent<Booking>> get _sessions => workoutEvents
      .where((event) =>
          event.start.year == _selected.year &&
          event.start.month == _selected.month &&
          event.start.day == _selected.day)
      .toList();

  static const Color _accent = Color(0xFFEF6C4D);

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.jm();
    return ExampleScaffold(
      product: 'Pulse',
      title: 'Training week',
      accent: _accent,
      trailing: IconButton(
        onPressed: () => setState(() => _selected = demoToday),
        icon: const Icon(Icons.today_outlined),
        tooltip: 'Today',
      ),
      children: (context) => [
        ExampleSection(
          title: 'This week',
          caption: 'Swipe the strip to move between weeks.',
          child: Builder(
            builder: (context) => HorizontalCalendar<Booking>(
              selectedDate: _selected,
              onDateSelected: (date) => setState(() => _selected = date),
              events: workoutEvents,
              appearance: CalendarAppearance(
                eventIndicatorStyle: EventIndicatorStyle.dot,
                motion: CalendarMotion.spring(),
                theme: brandCalendarTheme(
                  context,
                  accent: _accent,
                  style: CalendarStyle.soft,
                ),
              ),
            ),
          ),
        ),
        ExampleSection(
          title: 'Weekly goal',
          caption: '4 of 6 planned sessions completed.',
          child: Builder(
            builder: (context) => CalendarWeekProgress(
              startDate: DateTime(2026, 8, 10),
              currentDate: demoToday,
              selectedDate: _selected,
              onDateTap: (date) => setState(() => _selected = date),
              appearance: CalendarAppearance(
                showHeader: false,
                theme: brandCalendarTheme(
                  context,
                  accent: _accent,
                  style: CalendarStyle.soft,
                ),
              ),
            ),
          ),
        ),
        ExampleSection(
          title: DateFormat.MMMMEEEEd().format(_selected),
          caption: _sessions.isEmpty
              ? 'Recovery day'
              : '${_sessions.length} session${_sessions.length == 1 ? '' : 's'} planned',
          child: ExampleCard(
            child: _sessions.isEmpty
                ? const ExampleEmpty(
                    message: 'Nothing scheduled — rest counts as training.',
                    icon: Icons.self_improvement_outlined,
                  )
                : Column(
                    children: [
                      for (final session in _sessions)
                        ExampleRow(
                          accent: session.color ?? const Color(0xFFEF6C4D),
                          title: session.title ?? '',
                          subtitle: session.data?.owner,
                          trailing: time.format(session.start),
                          icon: Icons.fitness_center_outlined,
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

/// Production schedule built on the single-day timeline.
///
/// Overlapping bookings are laid out into deterministic columns, and the
/// current-time line tracks the real clock while the screen is open.
class StudioDayScreen extends StatefulWidget {
  const StudioDayScreen({super.key});

  @override
  State<StudioDayScreen> createState() => _StudioDayScreenState();
}

class _StudioDayScreenState extends State<StudioDayScreen> {
  CalendarEvent<Booking>? _tapped;

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      product: 'Studio Ops',
      title: 'Call sheet',
      accent: const Color(0xFF2E7BEA),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      children: (context) => [
        if (_tapped case final event?)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ExampleCard(
              child: ExampleRow(
                accent: event.color ?? const Color(0xFF2E7BEA),
                title: event.title ?? '',
                subtitle: '${event.data?.owner} · ${event.data?.room ?? 'TBC'}',
                trailing: event.data?.reference,
                icon: Icons.confirmation_number_outlined,
              ),
            ),
          ),
        ExampleSection(
          title: 'Wednesday 12 August',
          caption: 'Tap a block to pull the original booking back out.',
          child: ExampleCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: DayTimeline<Booking>(
              date: demoToday,
              events: studioDayEvents,
              now: DateTime(2026, 8, 12, 11, 20),
              onEventTap: (event) => setState(() => _tapped = event),
              configuration: const CalendarTimelineConfiguration(
                startHour: 7,
                endHour: 19,
                hourHeight: 62,
                viewportHeight: 470,
              ),
              appearance: CalendarAppearance(
                style: CalendarStyle.minimal,
                showHeader: false,
                motion: CalendarMotion.snappy(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Field-service rota built on the seven-column week timeline.
class ShiftBoardScreen extends StatelessWidget {
  const ShiftBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      product: 'Shift Board',
      title: 'Field rota',
      accent: const Color(0xFF1FA37A),
      brightness: Brightness.dark,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      children: (context) => [
        ExampleSection(
          title: 'Week of 10 August',
          caption: 'Scroll sideways for the rest of the week.',
          child: ExampleCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: WeekTimeline<Booking>(
              startDate: DateTime(2026, 8, 10),
              events: shiftEvents,
              now: DateTime(2026, 8, 12, 11, 20),
              configuration: const CalendarTimelineConfiguration(
                startHour: 6,
                endHour: 18,
                hourHeight: 54,
                viewportHeight: 430,
                dayColumnWidth: 132,
              ),
              appearance: CalendarAppearance(
                style: CalendarStyle.midnight,
                showHeader: false,
                motion: CalendarMotion.fluid(),
              ),
            ),
          ),
        ),
        ExampleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coverage',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const ExampleRow(
                accent: Color(0xFF1FA37A),
                title: 'Route 2 · Harbour',
                subtitle: 'Tue, Fri · 06:00–11:00',
                trailing: '2 shifts',
              ),
              const ExampleRow(
                accent: Color(0xFF2E7BEA),
                title: 'Route 4 · North',
                subtitle: 'Mon, Wed · 07:00–12:00',
                trailing: '2 shifts',
              ),
              const ExampleRow(
                accent: Color(0xFFEF6C4D),
                title: 'Route 7 · Riverside',
                subtitle: 'Thu · 08:00–13:00',
                trailing: '1 shift',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Journalling app built on the foldable week-to-month calendar.
///
/// Dragging the calendar vertically expands it continuously; the entry list
/// below always reflects whichever date is selected.
class MarginJournalScreen extends StatefulWidget {
  const MarginJournalScreen({super.key});

  @override
  State<MarginJournalScreen> createState() => _MarginJournalScreenState();
}

class _MarginJournalScreenState extends State<MarginJournalScreen> {
  DateTime _selected = demoToday;
  CalendarFoldState _fold = CalendarFoldState.collapsed;

  @override
  Widget build(BuildContext context) {
    final entry = journalEntries[_selected.day];
    final entryEvents = [
      for (final day in journalEntries.keys)
        CalendarEvent<Booking>(
          id: 'journal-$day',
          start: DateTime(2026, 8, day, 20),
          end: DateTime(2026, 8, day, 21),
          title: journalEntries[day]!.headline,
          color: journalEntries[day]!.accent,
        ),
    ];
    return ExampleScaffold(
      product: 'Margin',
      title: 'Journal',
      accent: const Color(0xFF9B4DE0),
      children: (context) => [
        ExampleSection(
          title: 'August 2026',
          caption: 'Drag the calendar down to open the whole month.',
          child: Builder(
            builder: (context) => FoldableCalendar<Booking>.single(
              focusedDate: _selected,
              selectedDate: _selected,
              onDateSelected: (date) => setState(() => _selected = date),
              foldState: _fold,
              onFoldStateChanged: (state) => setState(() => _fold = state),
              events: entryEvents,
              foldControl: CalendarFoldControl.both,
              expandLabel: 'Open month',
              collapseLabel: 'Back to week',
              appearance: CalendarAppearance(
                motion: CalendarMotion.gentle(),
                theme: brandCalendarTheme(
                  context,
                  accent: const Color(0xFF9B4DE0),
                  style: CalendarStyle.editorial,
                ),
              ),
            ),
          ),
        ),
        ExampleSection(
          title: DateFormat.yMMMMEEEEd().format(_selected),
          child: ExampleCard(
            child: entry == null
                ? const ExampleEmpty(
                    message: 'No entry yet for this day.',
                    icon: Icons.edit_note_outlined,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExampleRow(
                        accent: entry.accent,
                        title: entry.headline,
                        icon: entry.icon,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.detail,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
