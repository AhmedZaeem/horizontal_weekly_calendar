import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

enum _PlaygroundMotion { none, subtle, fluid, spring, playful, cinematic }

/// Interactive catalogue for the flagship horizontal and foldable calendars.
class CalendarPlaygroundPage extends StatefulWidget {
  const CalendarPlaygroundPage({super.key});

  @override
  State<CalendarPlaygroundPage> createState() => _CalendarPlaygroundPageState();
}

class _CalendarPlaygroundPageState extends State<CalendarPlaygroundPage> {
  DateTime _focusedDate = DateTime(2026, 8, 15);
  CalendarSelectionMode _selectionMode = CalendarSelectionMode.single;
  CalendarSelection _selection =
      CalendarSelection.single(DateTime(2026, 8, 15));
  CalendarStyle _style = CalendarStyle.materialExpressive;
  CalendarDensity _density = CalendarDensity.comfortable;
  EventIndicatorStyle _indicator = EventIndicatorStyle.stack;
  CalendarScrollBehavior _scrolling = CalendarScrollBehavior.page;
  _PlaygroundMotion _motion = _PlaygroundMotion.fluid;
  CalendarFoldControl _foldControl = CalendarFoldControl.both;
  CalendarFoldState _foldState = CalendarFoldState.collapsed;
  int _visibleDayCount = 7;
  bool _showHeader = true;
  bool _foldable = false;
  bool _disableWeekends = false;
  String _lastCallback = 'Ready — tap a date or use the calendar controls.';

  late final List<CalendarEvent<void>> _events = [
    CalendarEvent<void>(
      id: 'design',
      title: 'Design review',
      start: DateTime(2026, 8, 15, 10),
      end: DateTime(2026, 8, 15, 11),
      color: const Color(0xff7c5cff),
    ),
    CalendarEvent<void>(
      id: 'launch',
      title: 'Launch rehearsal',
      start: DateTime(2026, 8, 17, 14),
      end: DateTime(2026, 8, 17, 16),
      color: const Color(0xff00bfa6),
    ),
    CalendarEvent<void>(
      id: 'travel',
      title: 'Travel day',
      start: DateTime(2026, 8, 19),
      end: DateTime(2026, 8, 20),
      isAllDay: true,
      color: const Color(0xffff9f43),
    ),
  ];

  CalendarMotion get _resolvedMotion => switch (_motion) {
        _PlaygroundMotion.none => CalendarMotion.none(),
        _PlaygroundMotion.subtle => CalendarMotion.subtle(),
        _PlaygroundMotion.fluid => CalendarMotion.fluid(),
        _PlaygroundMotion.spring => CalendarMotion.spring(),
        _PlaygroundMotion.playful => CalendarMotion.playful(),
        _PlaygroundMotion.cinematic => CalendarMotion.cinematic(),
      };

  CalendarBehavior get _behavior => CalendarBehavior(
        visibleDayCount: _visibleDayCount,
        scrolling: _scrolling,
        selectableDayPredicate: _disableWeekends
            ? (date) =>
                date.weekday != DateTime.saturday &&
                date.weekday != DateTime.sunday
            : null,
        selectionBehavior: const CalendarSelectionBehavior(
          singleTap: CalendarSingleTapBehavior.toggle,
          maximumMultipleDates: 5,
          completedRangeTap: CalendarCompletedRangeTap.nearestBoundary,
          maximumRangeDays: 14,
        ),
      );

  CalendarAppearance get _appearance => CalendarAppearance(
        style: _style,
        density: _density,
        eventIndicatorStyle: _indicator,
        showHeader: _showHeader,
        motion: _resolvedMotion,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calendar playground'),
            Text('Every important option, live',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _IntroCard(
            icon: Icons.tune_rounded,
            title: 'Configure the real widget',
            body:
                'Change interaction, layout, style, motion, events, and folding. Every control below updates the public API used by the preview.',
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Live preview',
            trailing: Text(_foldable ? 'FOLDABLE' : 'HORIZONTAL'),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _foldable
                  ? FoldableCalendar<void>(
                      key: const ValueKey('playground-foldable'),
                      focusedDate: _focusedDate,
                      selection: _selection,
                      foldState: _foldState,
                      onFocusedDateChanged: _onFocusedDateChanged,
                      onSelectionChanged: _onSelectionChanged,
                      onFoldStateChanged: (value) => setState(() {
                        _foldState = value;
                        _lastCallback = 'Fold state → ${value.name}';
                      }),
                      behavior: _behavior,
                      appearance: _appearance,
                      events: _events,
                      foldControl: _foldControl,
                    )
                  : HorizontalCalendar<void>.controlled(
                      key: const ValueKey('playground-horizontal'),
                      focusedDate: _focusedDate,
                      selection: _selection,
                      onFocusedDateChanged: _onFocusedDateChanged,
                      onSelectionChanged: _onSelectionChanged,
                      behavior: _behavior,
                      appearance: _appearance,
                      events: _events,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Interaction',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MenuControl<CalendarSelectionMode>(
                  label: 'Selection',
                  value: _selectionMode,
                  values: CalendarSelectionMode.values,
                  onChanged: _changeSelectionMode,
                ),
                _MenuControl<CalendarScrollBehavior>(
                  label: 'Scrolling',
                  value: _scrolling,
                  values: CalendarScrollBehavior.values,
                  onChanged: (value) => setState(() => _scrolling = value),
                ),
                _MenuControl<EventIndicatorStyle>(
                  label: 'Events',
                  value: _indicator,
                  values: EventIndicatorStyle.values,
                  onChanged: (value) => setState(() => _indicator = value),
                ),
                FilterChip(
                  label: const Text('Disable weekends'),
                  selected: _disableWeekends,
                  onSelected: (value) =>
                      setState(() => _disableWeekends = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Presentation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MenuControl<CalendarStyle>(
                      label: 'Style',
                      value: _style,
                      values: CalendarStyle.values,
                      onChanged: (value) => setState(() => _style = value),
                    ),
                    _MenuControl<CalendarDensity>(
                      label: 'Density',
                      value: _density,
                      values: CalendarDensity.values,
                      onChanged: (value) => setState(() => _density = value),
                    ),
                    _MenuControl<_PlaygroundMotion>(
                      label: 'Motion',
                      value: _motion,
                      values: _PlaygroundMotion.values,
                      onChanged: (value) => setState(() => _motion = value),
                    ),
                    FilterChip(
                      label: const Text('Header'),
                      selected: _showHeader,
                      onSelected: (value) =>
                          setState(() => _showHeader = value),
                    ),
                    SizedBox(
                      key: const ValueKey('playground-foldable-toggle'),
                      child: FilterChip(
                        label: const Text('Foldable'),
                        selected: _foldable,
                        onSelected: (value) => setState(() {
                          _foldable = value;
                          _lastCallback = value
                              ? 'Foldable month expansion enabled'
                              : 'Horizontal-only mode enabled';
                        }),
                      ),
                    ),
                    if (_foldable)
                      _MenuControl<CalendarFoldControl>(
                        label: 'Fold control',
                        value: _foldControl,
                        values: CalendarFoldControl.values,
                        onChanged: (value) =>
                            setState(() => _foldControl = value),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Visible dates: $_visibleDayCount'),
                Slider(
                  value: _visibleDayCount.toDouble(),
                  min: 3,
                  max: 14,
                  divisions: 11,
                  label: '$_visibleDayCount',
                  onChanged: (value) =>
                      setState(() => _visibleDayCount = value.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Callback inspector',
            child: SelectableText(
              _lastCallback,
              key: const ValueKey('playground-callback'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          _RecipeCard(
            code: _recipe,
            onCopy: () => _copy(context, _recipe),
          ),
        ],
      ),
    );
  }

  void _changeSelectionMode(CalendarSelectionMode value) {
    setState(() {
      _selectionMode = value;
      _selection = switch (value) {
        CalendarSelectionMode.single => CalendarSelection.single(_focusedDate),
        CalendarSelectionMode.multiple => CalendarSelection.multiple([
            _focusedDate,
            _focusedDate.add(const Duration(days: 2)),
          ]),
        CalendarSelectionMode.range => CalendarSelection.range(
            CalendarDateRange(
              _focusedDate,
              _focusedDate.add(const Duration(days: 3)),
            ),
          ),
      };
      _lastCallback = 'Selection mode → ${value.name}';
    });
  }

  void _onFocusedDateChanged(DateTime value) {
    setState(() {
      _focusedDate = DateTime(value.year, value.month, value.day);
      _lastCallback = 'Focused date → ${_dateLabel(_focusedDate)}';
    });
  }

  void _onSelectionChanged(
    CalendarSelection previous,
    CalendarSelection next,
  ) {
    setState(() {
      _selection = next;
      _lastCallback = 'Selection callback → ${_selectionLabel(next)}';
    });
  }

  String get _recipe => '''
${_foldable ? 'FoldableCalendar' : 'HorizontalCalendar'}.controlled(
  focusedDate: focusedDate,
  selection: selection, // ${_selectionMode.name}
  onFocusedDateChanged: onFocusChanged,
  onSelectionChanged: onSelectionChanged,
  behavior: CalendarBehavior(
    visibleDayCount: $_visibleDayCount,
    scrolling: CalendarScrollBehavior.${_scrolling.name},
  ),
  appearance: CalendarAppearance(
    style: CalendarStyle.${_style.name},
    density: CalendarDensity.${_density.name},
    eventIndicatorStyle: EventIndicatorStyle.${_indicator.name},
    showHeader: $_showHeader,
    motion: CalendarMotion.${_motion.name}(),
  ),
  events: events,
);''';

  static String _dateLabel(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _selectionLabel(CalendarSelection selection) =>
      switch (selection.mode) {
        CalendarSelectionMode.single => selection.selectedDate == null
            ? 'empty'
            : _dateLabel(selection.selectedDate!),
        CalendarSelectionMode.multiple =>
          '${selection.selectedDates.length} dates selected',
        CalendarSelectionMode.range => selection.selectedRange == null
            ? 'range start pending'
            : '${_dateLabel(selection.selectedRange!.start)} → ${_dateLabel(selection.selectedRange!.end)}',
      };

  static Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current calendar recipe copied')),
      );
    }
  }
}

class _MenuControl<T extends Enum> extends StatelessWidget {
  const _MenuControl({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            items: [
              for (final option in values)
                DropdownMenuItem(
                  value: option,
                  child: Text('$label · ${option.name}'),
                ),
            ],
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
          ),
        ),
      );
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      );
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.inverseSurface,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Current Dart recipe',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy recipe',
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded),
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ],
              ),
              SelectableText(
                code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ],
          ),
        ),
      );
}
