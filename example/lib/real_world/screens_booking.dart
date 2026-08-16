import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';
import 'package:intl/intl.dart';

import 'data.dart';
import 'shell.dart';

/// Fare finder built on the date carousel.
///
/// Each card carries the real fare record, so accepting a date hands the
/// application back the object it supplied rather than a bare `DateTime`.
class SkylineFaresScreen extends StatefulWidget {
  const SkylineFaresScreen({super.key});

  @override
  State<SkylineFaresScreen> createState() => _SkylineFaresScreenState();
}

class _SkylineFaresScreenState extends State<SkylineFaresScreen> {
  DateTime _selected = DateTime(2026, 8, 12);
  final CalendarDateCarouselController _controller =
      CalendarDateCarouselController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _fare => flightFares[_selected.day] ?? 0;

  bool get _isCheapest =>
      _fare == flightFares.values.reduce((a, b) => a < b ? a : b);

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final entry in flightFares.entries)
        CalendarCarouselItem<Booking>(
          date: DateTime(2026, 8, entry.key),
          title: '€${entry.value}',
          subtitle: 'AMS → LIS',
          badge: entry.value <= 100 ? 'Low' : null,
          data: Booking(
            reference: 'SK${400 + entry.key}',
            owner: 'Ada Mensah',
            priceCents: entry.value * 100,
          ),
        ),
    ];
    return ExampleScaffold(
      product: 'Skyline',
      title: 'AMS → LIS',
      accent: const Color(0xFF2E7BEA),
      trailing: TextButton(
        onPressed: () => _controller.revealDate(DateTime(2026, 8, 20)),
        child: const Text('Jump to 20th'),
      ),
      children: (context) => [
        ExampleSection(
          title: 'Pick a departure',
          caption: 'Cards snap one at a time and settle on a spring.',
          child: CalendarDateCarousel<Booking>(
            controller: _controller,
            startDate: DateTime(2026, 8, 10),
            dayCount: flightFares.length,
            selectedDate: _selected,
            onDateSelected: (date) => setState(() => _selected = date),
            items: items,
            scrolling: CalendarScrollBehavior.page,
            cardExtent: 132,
            cardHeight: 158,
            visualStyle: const CalendarCarouselVisualStyle(
              layout: CalendarCarouselLayout.spotlight,
              showEventCount: false,
            ),
            appearance: CalendarAppearance(
              style: CalendarStyle.glass,
              showHeader: false,
              motion: CalendarMotion.premium(),
            ),
          ),
        ),
        ExampleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    '€$_fare',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'return, per traveller',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (_isCheapest)
                    const Chip(
                      label: Text('Cheapest'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ExampleRow(
                accent: const Color(0xFF2E7BEA),
                title: DateFormat.yMMMMEEEEd().format(_selected),
                subtitle: '07:35 → 09:50 · 2h 15m · direct',
                trailing: 'KL1693',
                icon: Icons.flight_takeoff_outlined,
              ),
              const ExampleRow(
                accent: Color(0xFF64748B),
                title: 'Return the following Sunday',
                subtitle: '18:05 → 22:20 · 2h 15m · direct',
                trailing: 'KL1698',
                icon: Icons.flight_land_outlined,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Appointment booking built on the month grid plus an availability strip.
class ClinicBookingScreen extends StatefulWidget {
  const ClinicBookingScreen({super.key});

  @override
  State<ClinicBookingScreen> createState() => _ClinicBookingScreenState();
}

class _ClinicBookingScreenState extends State<ClinicBookingScreen> {
  DateTime _selected = demoToday;
  String? _slotId;

  List<CalendarAvailabilitySlot<Booking>> get _slots {
    final entries = clinicSlots[_selected.day] ?? const [];
    return [
      for (final entry in entries)
        CalendarAvailabilitySlot<Booking>(
          id: '${_selected.day}-${entry.$1}',
          start: DateTime(
            _selected.year,
            _selected.month,
            _selected.day,
            entry.$2,
            entry.$3,
          ),
          end: DateTime(
            _selected.year,
            _selected.month,
            _selected.day,
            entry.$2,
            entry.$3,
          ).add(const Duration(minutes: 30)),
          state: entry.$4,
          data: Booking(reference: 'NH-${entry.$1}', owner: 'Dr. Reyes'),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final slots = _slots;
    return ExampleScaffold(
      product: 'Northside Health',
      title: 'Book an appointment',
      accent: const Color(0xFF1FA37A),
      children: (context) => [
        ExampleSection(
          title: 'August 2026',
          caption: 'Weekends and past dates are not selectable.',
          child: ExampleCard(
            padding: const EdgeInsets.all(10),
            child: Builder(
              builder: (context) => MonthCalendar<Booking>.single(
                month: DateTime(2026, 8),
                selectedDate: _selected,
                onDateSelected: (date) => setState(() {
                  _selected = date;
                  _slotId = null;
                }),
                bounds: CalendarDateRange(demoToday, DateTime(2026, 9, 30)),
                behavior: CalendarBehavior(
                  selectableDayPredicate: (date) =>
                      date.weekday != DateTime.saturday &&
                      date.weekday != DateTime.sunday &&
                      clinicSlots.containsKey(date.day),
                ),
                appearance: CalendarAppearance(
                  showHeader: false,
                  motion: CalendarMotion.subtle(),
                  theme: brandCalendarTheme(
                    context,
                    accent: const Color(0xFF1FA37A),
                  ),
                ),
              ),
            ),
          ),
        ),
        ExampleSection(
          title: 'Available times',
          caption: slots.isEmpty
              ? 'No clinic hours on this date.'
              : '30-minute consultations with Dr. Reyes.',
          child: slots.isEmpty
              ? const ExampleCard(
                  child: ExampleEmpty(
                    message: 'Choose a weekday to see open slots.',
                    icon: Icons.schedule_outlined,
                  ),
                )
              : Builder(
                  builder: (context) => CalendarAvailabilityStrip<Booking>(
                    slots: slots,
                    selectedSlotId: _slotId,
                    onSlotSelected: (slot) => setState(() => _slotId = slot.id),
                    layout: CalendarAvailabilityLayout.grid,
                    design: CalendarAvailabilityDesign.card,
                    minimumItemWidth: 104,
                    appearance: CalendarAppearance(
                      showHeader: false,
                      theme: brandCalendarTheme(
                        context,
                        accent: const Color(0xFF1FA37A),
                      ),
                    ),
                  ),
                ),
        ),
        if (_slotId != null)
          ExampleCard(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Holding ${_slotId!.split('-').last} on '
                    '${DateFormat.MMMEd().format(_selected)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _slotId = null),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Stay booking built on controlled range selection.
class AsterStaysScreen extends StatefulWidget {
  const AsterStaysScreen({super.key});

  @override
  State<AsterStaysScreen> createState() => _AsterStaysScreenState();
}

class _AsterStaysScreenState extends State<AsterStaysScreen> {
  CalendarSelection _selection = CalendarSelection.range(
    CalendarDateRange(DateTime(2026, 8, 12), DateTime(2026, 8, 16)),
  );
  DateTime _focused = demoToday;

  int get _nights {
    final range = _selection.selectedRange;
    if (range == null) return 0;
    return range.end.difference(range.start).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final range = _selection.selectedRange;
    final format = DateFormat.MMMd();
    return ExampleScaffold(
      product: 'Aster Stays',
      title: 'Harbour Loft, Porto',
      accent: const Color(0xFFB4881F),
      children: (context) => [
        ExampleSection(
          title: 'Choose your dates',
          caption: 'Tap a start date, then an end date.',
          child: Builder(
            builder: (context) => HorizontalCalendar<Booking>.controlled(
              focusedDate: _focused,
              selection: _selection,
              onFocusedDateChanged: (date) => setState(() => _focused = date),
              onSelectionChanged: (_, next) =>
                  setState(() => _selection = next),
              bounds: CalendarDateRange(demoToday, DateTime(2026, 12, 31)),
              // The selection object carries the mode; behavior only adds the
              // house rules on top of it.
              behavior: const CalendarBehavior(
                selectionBehavior: CalendarSelectionBehavior(
                  maximumRangeDays: 21,
                  completedRangeTap: CalendarCompletedRangeTap.restart,
                ),
              ),
              appearance: CalendarAppearance(
                motion: CalendarMotion.cinematic(),
                theme: brandCalendarTheme(
                  context,
                  accent: const Color(0xFFB4881F),
                  style: CalendarStyle.luxury,
                ),
              ),
            ),
          ),
        ),
        ExampleSection(
          title: 'Stay summary',
          child: ExampleCard(
            child: Column(
              children: [
                ExampleRow(
                  accent: const Color(0xFFB4881F),
                  title: range == null
                      ? 'Select a check-in date'
                      : '${format.format(range.start)} → '
                          '${format.format(range.end)}',
                  subtitle: _nights == 0
                      ? 'Minimum two nights'
                      : '$_nights night${_nights == 1 ? '' : 's'} · 2 guests',
                  icon: Icons.hotel_outlined,
                ),
                const ExampleRow(
                  accent: Color(0xFF64748B),
                  title: 'Loft with harbour view',
                  subtitle: 'Free cancellation until 48h before arrival',
                  trailing: '€184/night',
                  icon: Icons.king_bed_outlined,
                ),
                const Divider(height: 22),
                Row(
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    Text(
                      '€${_nights * 184}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _nights >= 2 ? () {} : null,
                    child: const Text('Reserve'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
