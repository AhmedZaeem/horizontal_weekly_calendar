import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

class _StudioPalette {
  const _StudioPalette({
    required this.name,
    required this.background,
    required this.gradient,
    required this.foreground,
    required this.secondary,
    required this.accent,
  });

  final String name;
  final Color background;
  final Color gradient;
  final Color foreground;
  final Color secondary;
  final Color accent;
}

const _palettes = [
  _StudioPalette(
    name: 'Midnight',
    background: Color(0xff07111f),
    gradient: Color(0xff183f4d),
    foreground: Color(0xfff7fbff),
    secondary: Color(0xff9fb1c7),
    accent: Color(0xff55d6be),
  ),
  _StudioPalette(
    name: 'Aurora',
    background: Color(0xff19132f),
    gradient: Color(0xff47327d),
    foreground: Color(0xfffffaff),
    secondary: Color(0xffcabfe5),
    accent: Color(0xffb8ffdc),
  ),
  _StudioPalette(
    name: 'Sunset',
    background: Color(0xff321410),
    gradient: Color(0xff86372d),
    foreground: Color(0xfffff8ed),
    secondary: Color(0xffffc9ae),
    accent: Color(0xffffd166),
  ),
  _StudioPalette(
    name: 'Paper',
    background: Color(0xfffffbf3),
    gradient: Color(0xffeee1c9),
    foreground: Color(0xff201c17),
    secondary: Color(0xff74695c),
    accent: Color(0xff9a5b32),
  ),
];

/// Live editor for Flutter previews and the portable native widget payload.
class HomeWidgetStudioPage extends StatefulWidget {
  const HomeWidgetStudioPage({super.key});

  @override
  State<HomeWidgetStudioPage> createState() => _HomeWidgetStudioPageState();
}

class _HomeWidgetStudioPageState extends State<HomeWidgetStudioPage> {
  CalendarHomeWidgetFamily _family = CalendarHomeWidgetFamily.medium;
  CalendarHomeWidgetContent _content = CalendarHomeWidgetContent.week;
  CalendarHomeWidgetDensity _density = CalendarHomeWidgetDensity.comfortable;
  CalendarHomeWidgetSurfaceStyle _surface =
      CalendarHomeWidgetSurfaceStyle.gradient;
  CalendarHomeWidgetHeaderStyle _header = CalendarHomeWidgetHeaderStyle.title;
  CalendarHomeWidgetEventStyle _eventStyle = CalendarHomeWidgetEventStyle.card;
  CalendarHomeWidgetDateShape _dateShape = CalendarHomeWidgetDateShape.rounded;
  CalendarHomeWidgetProgressStyle _progressStyle =
      CalendarHomeWidgetProgressStyle.segmented;
  CalendarHomeWidgetWeekdayFormat _weekday =
      CalendarHomeWidgetWeekdayFormat.short;
  _StudioPalette _palette = _palettes.first;
  double _cornerRadius = 28;
  double _typographyScale = 1;
  double _itemSpacing = 6;
  double _indicatorWidth = 4;
  double _elevation = 8;
  int _maximumEvents = 4;
  bool _showSubtitle = true;
  bool _showLocation = true;
  bool _showEventTime = true;
  bool _showWeekday = true;
  bool _useEventColors = true;
  bool _animateChanges = true;
  String _status = 'Preview is live. Native widget has not been updated.';

  late final CalendarHomeWidgetData _data = CalendarHomeWidgetData(
    generatedAt: DateTime(2026, 8, 15, 8),
    selectedDate: DateTime(2026, 8, 15),
    title: 'Launch week',
    subtitle: 'Your week, one glance away',
    targetDate: DateTime(2026, 8, 24),
    completedCount: 3,
    totalCount: 5,
    action: const CalendarHomeWidgetAction(
      uri: 'calendar-example://calendar',
      label: 'Open calendar',
    ),
    events: [
      CalendarHomeWidgetEvent(
        id: 'review',
        title: 'Design review',
        subtitle: 'Product',
        location: 'Studio A',
        start: DateTime(2026, 8, 15, 10),
        end: DateTime(2026, 8, 15, 11),
        colorValue: 0xff55d6be,
      ),
      CalendarHomeWidgetEvent(
        id: 'rehearsal',
        title: 'Launch rehearsal',
        subtitle: 'Marketing',
        location: 'Stage',
        start: DateTime(2026, 8, 15, 13),
        end: DateTime(2026, 8, 15, 14, 30),
        colorValue: 0xffffd166,
      ),
      CalendarHomeWidgetEvent(
        id: 'ship',
        title: 'Production deploy',
        subtitle: 'Engineering',
        location: 'Remote',
        start: DateTime(2026, 8, 15, 16),
        end: DateTime(2026, 8, 15, 17),
        colorValue: 0xff9f8cff,
      ),
      CalendarHomeWidgetEvent(
        id: 'notes',
        title: 'Publish release notes',
        start: DateTime(2026, 8, 15, 18),
        end: DateTime(2026, 8, 15, 18, 30),
        colorValue: 0xffff7a90,
      ),
    ],
  );

  CalendarHomeWidgetTheme get _theme => CalendarHomeWidgetTheme(
        backgroundColor: _palette.background,
        foregroundColor: _palette.foreground,
        secondaryColor: _palette.secondary,
        accentColor: _palette.accent,
        dividerColor: _palette.accent.withValues(alpha: .2),
        surfaceStyle: _surface,
        gradientColors: [_palette.background, _palette.gradient],
        borderColor: _surface == CalendarHomeWidgetSurfaceStyle.outlined
            ? _palette.accent
            : null,
        borderWidth: 1.5,
        elevation: _elevation,
        cornerRadius: _cornerRadius,
        typographyScale: _typographyScale,
        density: _density,
        headerStyle: _header,
        eventStyle: _eventStyle,
        dateShape: _dateShape,
        progressStyle: _progressStyle,
        weekdayFormat: _weekday,
        itemSpacing: _itemSpacing,
        eventIndicatorWidth: _indicatorWidth,
        maximumEvents: _maximumEvents,
        showSubtitle: _showSubtitle,
        showLocation: _showLocation,
        showEventTime: _showEventTime,
        showWeekday: _showWeekday,
        showProgress: _progressStyle != CalendarHomeWidgetProgressStyle.hidden,
        useEventColors: _useEventColors,
        animateChanges: _animateChanges,
      );

  CalendarHomeWidgetConfiguration get _configuration =>
      CalendarHomeWidgetConfiguration(
        family: _family,
        content: _content,
        theme: _theme,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home-widget studio'),
            Text('Flutter, Android, and WidgetKit contract',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Design the glance',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                )),
                    const SizedBox(height: 6),
                    const Text(
                      'The same serialized configuration drives this responsive preview and the portable subset in the native example hosts.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _StudioPanel(
            title: 'Live preview · ${_family.name} / ${_content.name}',
            child: Container(
              height: _family == CalendarHomeWidgetFamily.large ||
                      _family == CalendarHomeWidgetFamily.extraLarge
                  ? 390
                  : 230,
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox.fromSize(
                  size: _family.previewSize,
                  child: CalendarHomeWidget(
                    key: const ValueKey('home-widget-studio-preview'),
                    data: _data,
                    family: _family,
                    content: _content,
                    theme: _theme,
                    onAction: (action) => setState(() {
                      _status = 'Action callback → ${action.uri}';
                    }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _StudioPanel(
            title: 'Content and size',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StudioMenu<CalendarHomeWidgetFamily>(
                  label: 'Family',
                  value: _family,
                  values: CalendarHomeWidgetFamily.values,
                  onChanged: (value) => setState(() => _family = value),
                ),
                _StudioMenu<CalendarHomeWidgetContent>(
                  label: 'Content',
                  value: _content,
                  values: CalendarHomeWidgetContent.values,
                  onChanged: (value) => setState(() => _content = value),
                ),
                _StudioMenu<CalendarHomeWidgetDensity>(
                  label: 'Density',
                  value: _density,
                  values: CalendarHomeWidgetDensity.values,
                  onChanged: (value) => setState(() => _density = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StudioPanel(
            title: 'Visual language',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final palette in _palettes)
                      ChoiceChip(
                        label: Text(palette.name),
                        avatar: CircleAvatar(backgroundColor: palette.accent),
                        selected: identical(_palette, palette),
                        onSelected: (_) => setState(() => _palette = palette),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StudioMenu<CalendarHomeWidgetSurfaceStyle>(
                      label: 'Surface',
                      value: _surface,
                      values: CalendarHomeWidgetSurfaceStyle.values,
                      onChanged: (value) => setState(() => _surface = value),
                    ),
                    _StudioMenu<CalendarHomeWidgetHeaderStyle>(
                      label: 'Header',
                      value: _header,
                      values: CalendarHomeWidgetHeaderStyle.values,
                      onChanged: (value) => setState(() => _header = value),
                    ),
                    _StudioMenu<CalendarHomeWidgetEventStyle>(
                      label: 'Event',
                      value: _eventStyle,
                      values: CalendarHomeWidgetEventStyle.values,
                      onChanged: (value) => setState(() => _eventStyle = value),
                    ),
                    _StudioMenu<CalendarHomeWidgetDateShape>(
                      label: 'Date',
                      value: _dateShape,
                      values: CalendarHomeWidgetDateShape.values,
                      onChanged: (value) => setState(() => _dateShape = value),
                    ),
                    _StudioMenu<CalendarHomeWidgetProgressStyle>(
                      label: 'Progress',
                      value: _progressStyle,
                      values: CalendarHomeWidgetProgressStyle.values,
                      onChanged: (value) =>
                          setState(() => _progressStyle = value),
                    ),
                    _StudioMenu<CalendarHomeWidgetWeekdayFormat>(
                      label: 'Weekday',
                      value: _weekday,
                      values: CalendarHomeWidgetWeekdayFormat.values,
                      onChanged: (value) => setState(() => _weekday = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StudioPanel(
            title: 'Information rules',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _toggle('Subtitle', _showSubtitle,
                    (value) => _showSubtitle = value),
                _toggle('Location', _showLocation,
                    (value) => _showLocation = value),
                _toggle('Event time', _showEventTime,
                    (value) => _showEventTime = value),
                _toggle(
                    'Weekday', _showWeekday, (value) => _showWeekday = value),
                _toggle('Event colors', _useEventColors,
                    (value) => _useEventColors = value),
                _toggle('Animate', _animateChanges,
                    (value) => _animateChanges = value),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StudioPanel(
            title: 'Fine tuning',
            child: Column(
              children: [
                _slider('Corner radius', _cornerRadius, 0, 48,
                    (value) => _cornerRadius = value),
                _slider('Typography', _typographyScale, .75, 1.6,
                    (value) => _typographyScale = value),
                _slider('Item spacing', _itemSpacing, 0, 16,
                    (value) => _itemSpacing = value),
                _slider('Indicator width', _indicatorWidth, 1, 12,
                    (value) => _indicatorWidth = value),
                _slider('Preview elevation', _elevation, 0, 24,
                    (value) => _elevation = value),
                Row(
                  children: [
                    Expanded(child: Text('Maximum events · $_maximumEvents')),
                    IconButton(
                      tooltip: 'Remove event row',
                      onPressed: _maximumEvents == 0
                          ? null
                          : () => setState(() => _maximumEvents--),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    IconButton(
                      tooltip: 'Add event row',
                      onPressed: _maximumEvents == 12
                          ? null
                          : () => setState(() => _maximumEvents++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StudioPanel(
            title: 'Native bridge and callbacks',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_status, key: const ValueKey('home-widget-studio-status')),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _sendToNative,
                  icon: const Icon(Icons.widgets_outlined),
                  label:
                      const Text('Send this configuration to native widgets'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StudioRecipe(code: _recipe, onCopy: _copyRecipe),
        ],
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> update) =>
      FilterChip(
        label: Text(label),
        selected: value,
        onSelected: (next) => setState(() => update(next)),
      );

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> update,
  ) =>
      Row(
        children: [
          SizedBox(
              width: 132, child: Text('$label · ${value.toStringAsFixed(1)}')),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (next) => setState(() => update(next)),
            ),
          ),
        ],
      );

  Future<void> _sendToNative() async {
    final success = await const CalendarHomeWidgetBridge().update(
      _data,
      configuration: _configuration,
    );
    if (!mounted) return;
    setState(() {
      _status = success
          ? 'Native widget payload updated with ${_family.name}/${_content.name}.'
          : 'No native host is registered on this target; the Flutter preview remains fully usable.';
    });
  }

  Future<void> _copyRecipe() async {
    await Clipboard.setData(ClipboardData(text: _recipe));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Home-widget recipe copied')),
      );
    }
  }

  String get _recipe => '''
final configuration = CalendarHomeWidgetConfiguration(
  family: CalendarHomeWidgetFamily.${_family.name},
  content: CalendarHomeWidgetContent.${_content.name},
  theme: CalendarHomeWidgetTheme(
    surfaceStyle: CalendarHomeWidgetSurfaceStyle.${_surface.name},
    headerStyle: CalendarHomeWidgetHeaderStyle.${_header.name},
    eventStyle: CalendarHomeWidgetEventStyle.${_eventStyle.name},
    dateShape: CalendarHomeWidgetDateShape.${_dateShape.name},
    progressStyle: CalendarHomeWidgetProgressStyle.${_progressStyle.name},
    weekdayFormat: CalendarHomeWidgetWeekdayFormat.${_weekday.name},
    density: CalendarHomeWidgetDensity.${_density.name},
    cornerRadius: ${_cornerRadius.toStringAsFixed(1)},
    typographyScale: ${_typographyScale.toStringAsFixed(2)},
    maximumEvents: $_maximumEvents,
    showSubtitle: $_showSubtitle,
    showLocation: $_showLocation,
    showEventTime: $_showEventTime,
  ),
);

await const CalendarHomeWidgetBridge().update(
  data,
  configuration: configuration,
);''';
}

class _StudioMenu<T extends Enum> extends StatelessWidget {
  const _StudioMenu({
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
        width: 176,
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

class _StudioPanel extends StatelessWidget {
  const _StudioPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      );
}

class _StudioRecipe extends StatelessWidget {
  const _StudioRecipe({required this.code, required this.onCopy});

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
                      'Portable Dart recipe',
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
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
}
