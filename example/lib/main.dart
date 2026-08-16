// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';
import 'package:horizontal_weekly_calendar/weekly_calendar.dart' as legacy;

import 'calendar_playground.dart';
import 'home_widget_studio.dart';
import 'real_world/index.dart';

/// Route the app opens on, so a screenshot run can land on one screen.
///
/// Pass `--dart-define=CALENDAR_ROUTE=/real-world/journal` to open an example
/// directly instead of navigating to it.
const String _routeOverride = String.fromEnvironment('CALENDAR_ROUTE');

void main() => runApp(const CalendarGalleryApp());

enum _GalleryMotion {
  classic,
  none,
  subtle,
  fluid,
  spring,
  playful,
  snappy,
  gentle,
  cinematic,
  premium,
}

enum _GalleryCategory {
  all,
  horizontal,
  selection,
  pickers,
  native,
  motion,
  events,
  planning,
  data,
  custom,
  legacy,
}

CalendarMotion? _motionFor(_GalleryMotion motion) {
  return switch (motion) {
    _GalleryMotion.classic => null,
    _GalleryMotion.none => CalendarMotion.none(),
    _GalleryMotion.subtle => CalendarMotion.subtle(),
    _GalleryMotion.fluid => CalendarMotion.fluid(),
    _GalleryMotion.spring => CalendarMotion.spring(),
    _GalleryMotion.playful => CalendarMotion.playful(),
    _GalleryMotion.snappy => CalendarMotion.snappy(),
    _GalleryMotion.gentle => CalendarMotion.gentle(),
    _GalleryMotion.cinematic => CalendarMotion.cinematic(),
    _GalleryMotion.premium => CalendarMotion.premium(),
  };
}

class CalendarGalleryApp extends StatefulWidget {
  const CalendarGalleryApp({super.key});

  @override
  State<CalendarGalleryApp> createState() => _CalendarGalleryAppState();
}

class _CalendarGalleryAppState extends State<CalendarGalleryApp> {
  ThemeMode _themeMode = ThemeMode.light;
  CalendarDensity _density = CalendarDensity.comfortable;
  CalendarStyle _style = CalendarStyle.adaptive;
  _GalleryMotion _motion = _GalleryMotion.fluid;
  double _textScale = 1;
  bool _rtl = false;
  bool _highContrast = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Horizontal Calendar 2.0',
      themeMode: _themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return Directionality(
          textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(_textScale),
              highContrast: _highContrast,
            ),
            child: child!,
          ),
        );
      },
      routes: {
        ...realWorldRoutes,
        '/real-world': (_) => const RealWorldIndexPage(),
        '/playground': (_) => const CalendarPlaygroundPage(),
        '/home-widget-studio': (_) => const HomeWidgetStudioPage(),
        '/showcase': (_) => const RecordingShowcase(),
        '/capture/styles': (_) => const CaptureShowcase(kind: 'styles'),
        '/capture/motion': (_) => const CaptureShowcase(kind: 'motion'),
        '/capture/foldable': (_) => const CaptureShowcase(kind: 'foldable'),
        '/capture/native': (_) => const CaptureShowcase(kind: 'native'),
        '/capture/planning': (_) => const CaptureShowcase(kind: 'planning'),
        '/capture/data': (_) => const CaptureShowcase(kind: 'data'),
        '/capture/selection': (_) => const CaptureShowcase(kind: 'selection'),
        '/capture/celestial': (_) => const CaptureShowcase(kind: 'celestial'),
        '/capture/widgets': (_) => const CaptureShowcase(kind: 'widgets'),
        '/capture/legacy': (_) => const CaptureShowcase(kind: 'legacy'),
        '/capture/carousel': (_) => const CaptureShowcase(kind: 'carousel'),
        '/capture/horizon': (_) => const CaptureShowcase(kind: 'horizon'),
        '/capture/heatmaps': (_) => const CaptureShowcase(kind: 'heatmaps'),
        '/capture/responsive': (_) => const CaptureShowcase(kind: 'responsive'),
        '/capture/home-widgets': (_) =>
            const CaptureShowcase(kind: 'home-widgets'),
      },
      initialRoute: _initialRoute(),
      home: _GalleryHome(
        themeMode: _themeMode,
        density: _density,
        style: _style,
        motion: _motion,
        textScale: _textScale,
        rtl: _rtl,
        highContrast: _highContrast,
        onThemeModeChanged: (value) => setState(() => _themeMode = value),
        onDensityChanged: (value) => setState(() => _density = value),
        onStyleChanged: (value) => setState(() => _style = value),
        onMotionChanged: (value) => setState(() => _motion = value),
        onTextScaleChanged: (value) => setState(() => _textScale = value),
        onRtlChanged: (value) => setState(() => _rtl = value),
        onHighContrastChanged: (value) => setState(() => _highContrast = value),
      ),
    );
  }

  String _initialRoute() {
    if (_routeOverride.isNotEmpty) return _routeOverride;
    if (Uri.base.queryParameters['showcase'] == '1') return '/showcase';
    final capture = Uri.base.queryParameters['capture'];
    if (capture != null &&
        const {
          'styles',
          'motion',
          'foldable',
          'native',
          'planning',
          'data',
          'selection',
          'celestial',
          'widgets',
          'legacy',
          'carousel',
          'horizon',
          'heatmaps',
          'responsive',
          'home-widgets',
        }.contains(capture)) {
      return '/capture/$capture';
    }
    return '/';
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5547D7),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF090B13) : const Color(0xFFF5F6FA),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? const Color(0xFF121521) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class _GalleryHome extends StatefulWidget {
  const _GalleryHome({
    required this.themeMode,
    required this.density,
    required this.style,
    required this.motion,
    required this.textScale,
    required this.rtl,
    required this.highContrast,
    required this.onThemeModeChanged,
    required this.onDensityChanged,
    required this.onStyleChanged,
    required this.onMotionChanged,
    required this.onTextScaleChanged,
    required this.onRtlChanged,
    required this.onHighContrastChanged,
  });

  final ThemeMode themeMode;
  final CalendarDensity density;
  final CalendarStyle style;
  final _GalleryMotion motion;
  final double textScale;
  final bool rtl;
  final bool highContrast;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<CalendarDensity> onDensityChanged;
  final ValueChanged<CalendarStyle> onStyleChanged;
  final ValueChanged<_GalleryMotion> onMotionChanged;
  final ValueChanged<double> onTextScaleChanged;
  final ValueChanged<bool> onRtlChanged;
  final ValueChanged<bool> onHighContrastChanged;

  @override
  State<_GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<_GalleryHome> {
  var _selectedDate = DateTime(2026, 8, 5);
  var _focusedDate = DateTime(2026, 8, 5);
  var _selection = CalendarSelection.range(
    CalendarDateRange(DateTime(2026, 8, 5), DateTime(2026, 8, 8)),
  );
  var _foldState = CalendarFoldState.collapsed;
  var _category = _GalleryCategory.all;
  var _nativeDate = DateTime(2026, 8, 5);
  var _multipleSelection = CalendarSelection.multiple([
    DateTime(2026, 8, 5),
    DateTime(2026, 8, 7),
  ]);
  var _rangeSelection = CalendarSelection.range(null);
  var _celestialDate = DateTime(2026, 8, 10);
  var _railDate = DateTime(2026, 8, 5);
  String? _selectedSlot = 'slot-1030';

  CalendarAppearance _appearance({
    CalendarStyle? style,
    HorizontalCalendarThemeData? theme,
    EventIndicatorStyle indicator = EventIndicatorStyle.stack,
  }) {
    return CalendarAppearance(
      style: style ?? widget.style,
      density: widget.density,
      eventIndicatorStyle: indicator,
      theme: theme,
      motion: _motionFor(widget.motion),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Horizontal Calendar 2.0'),
            Text(
              'Interactive UI kit gallery',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Capture routes',
            icon: const Icon(Icons.video_library_outlined),
            onSelected: (route) => Navigator.pushNamed(context, route),
            itemBuilder: (context) => const [
              PopupMenuItem(value: '/showcase', child: Text('Hero capture')),
              PopupMenuItem(
                value: '/capture/styles',
                child: Text('Style capture'),
              ),
              PopupMenuItem(
                value: '/capture/motion',
                child: Text('Motion capture'),
              ),
              PopupMenuItem(
                value: '/capture/foldable',
                child: Text('Foldable capture'),
              ),
              PopupMenuItem(
                value: '/capture/native',
                child: Text('Native capture'),
              ),
              PopupMenuItem(
                value: '/capture/planning',
                child: Text('Planning capture'),
              ),
              PopupMenuItem(
                value: '/capture/data',
                child: Text('Data capture'),
              ),
              PopupMenuItem(
                value: '/capture/selection',
                child: Text('Selection capture'),
              ),
              PopupMenuItem(
                value: '/capture/celestial',
                child: Text('Celestial capture'),
              ),
              PopupMenuItem(
                value: '/capture/widgets',
                child: Text('Date widgets capture'),
              ),
              PopupMenuItem(
                value: '/capture/carousel',
                child: Text('Carousel capture'),
              ),
              PopupMenuItem(
                value: '/capture/horizon',
                child: Text('Horizon capture'),
              ),
              PopupMenuItem(
                value: '/capture/heatmaps',
                child: Text('Heatmap capture'),
              ),
              PopupMenuItem(
                value: '/capture/responsive',
                child: Text('Responsive widgets capture'),
              ),
              PopupMenuItem(
                value: '/capture/legacy',
                child: Text('Legacy compatibility capture'),
              ),
              PopupMenuItem(
                value: '/capture/home-widgets',
                child: Text('Home widgets capture'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _galleryHero(context)),
          SliverToBoxAdapter(child: _controls(context)),
          SliverToBoxAdapter(child: _categoryFilters()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
            sliver: SliverList.list(
              children: [
                _section(
                  context,
                  category: _GalleryCategory.custom,
                  eyebrow: 'DEVELOPER TOOLS',
                  title: 'Explore the API instead of guessing at it',
                  description:
                      'Two live studios expose the real calendar and home-widget options, callback state, responsive behavior, and copyable Dart recipes.',
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth >= 720
                          ? (constraints.maxWidth - 14) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          SizedBox(
                            width: width,
                            child: _catalogToolCard(
                              context,
                              icon: Icons.auto_awesome_mosaic_rounded,
                              title: 'Real-world examples',
                              description:
                                  'Thirteen small products — training, booking, rotas, tracking, habits, reminders, and widgets — one per calendar surface.',
                              route: '/real-world',
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _catalogToolCard(
                              context,
                              icon: Icons.tune_rounded,
                              title: 'Calendar playground',
                              description:
                                  'Style, density, selection, motion, scrolling, events, disabled dates, and foldable mode.',
                              route: '/playground',
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _catalogToolCard(
                              context,
                              icon: Icons.widgets_rounded,
                              title: 'Home-widget studio',
                              description:
                                  'Every size and content type, portable themes, information rules, fine tuning, and native updates.',
                              route: '/home-widget-studio',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.horizontal,
                  eyebrow: 'THREE-LINE SETUP',
                  title: 'Beautiful by default',
                  description:
                      'Adaptive controls, locale-aware labels, keyboard navigation, and resilient compact scrolling.',
                  child: _calendarFrame(
                    HorizontalCalendar<Object?>(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.horizontal,
                  eyebrow: 'SIGNATURE PRESETS',
                  title: 'One API, distinct personalities',
                  description:
                      'Complete themes can be used as-is, inherited, copied, or replaced at the component level.',
                  child: _presetCarousel(context),
                ),
                _section(
                  context,
                  category: _GalleryCategory.motion,
                  eyebrow: 'MOTION LAB',
                  title:
                      'From silent to playful — without custom animation code',
                  description:
                      'Selection, paging, event markers, hover, and folding use one reusable motion choreography.',
                  child: _calendarFrame(
                    HorizontalCalendar<DemoEvent>(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                      appearance: _appearance(
                        style: CalendarStyle.materialExpressive,
                      ),
                      events: demoEvents,
                    ),
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.native,
                  eyebrow: 'NATIVE ADAPTATION',
                  title:
                      'Material where it belongs. Cupertino where it belongs.',
                  description:
                      'Navigation controls, target sizes, motion, modal presentation, and visual tokens adapt together.',
                  child: _calendarFrame(
                    Column(
                      children: [
                        AdaptiveCalendarNavigationBar(
                          focusedDate: _nativeDate,
                          onPrevious: () => setState(() {
                            _nativeDate = DateTime(
                              _nativeDate.year,
                              _nativeDate.month - 1,
                              _nativeDate.day,
                            );
                          }),
                          onNext: () => setState(() {
                            _nativeDate = DateTime(
                              _nativeDate.year,
                              _nativeDate.month + 1,
                              _nativeDate.day,
                            );
                          }),
                          onToday: () =>
                              setState(() => _nativeDate = DateTime.now()),
                          appearance: _appearance(),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: () => _openAdaptivePicker(),
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: Text(
                                'Open calendar · ${_nativeDate.day}',
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openCupertinoWheel(),
                              icon: const Icon(Icons.view_week_outlined),
                              label: const Text('Open Cupertino wheel'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CalendarCupertinoDatePicker(
                          value: _nativeDate,
                          onChanged: (date) =>
                              setState(() => _nativeDate = date),
                          bounds: CalendarDateRange(
                            DateTime(2026, 1, 1),
                            DateTime(2027, 12, 31),
                          ),
                          configuration:
                              const CalendarCupertinoPickerConfiguration(
                            showDayOfWeek: true,
                          ),
                          appearance: _appearance(
                            style: CalendarStyle.cupertinoTinted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.horizontal,
                  eyebrow: 'DATE CAROUSEL',
                  title: 'Horizontal cards for booking, travel, and content',
                  description:
                      'Typed metadata, badges, events, bounds, custom cards, and optional page snapping.',
                  child: CalendarDateCarousel<DemoEvent>(
                    startDate: DateTime(2026, 8, 3),
                    dayCount: 14,
                    selectedDate: _selectedDate,
                    onDateSelected: (date) =>
                        setState(() => _selectedDate = date),
                    items: demoCarouselItems,
                    events: demoEvents,
                    appearance: _appearance(style: CalendarStyle.pill),
                    scrolling: CalendarScrollBehavior.page,
                    visualStyle: const CalendarCarouselVisualStyle(
                      layout: CalendarCarouselLayout.spotlight,
                      selectedScale: 1.035,
                      inactiveScale: .96,
                      inactiveOpacity: .76,
                      spacing: 12,
                      elevation: 8,
                      borderRadius: 24,
                    ),
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.selection,
                  eyebrow: 'SELECTION LAB',
                  title: 'Single, multiple, and range — all truly controlled',
                  description:
                      'Every tap updates visible state immediately. Limits, empty selection, completed ranges, and disabled dates use one rule engine.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _DemoLabel('SINGLE DATE'),
                      HorizontalCalendar<Object?>(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) =>
                            setState(() => _selectedDate = date),
                        appearance:
                            _appearance(style: CalendarStyle.materialYou),
                      ),
                      const SizedBox(height: 18),
                      const _DemoLabel('MULTIPLE · UP TO 4'),
                      HorizontalCalendar<Object?>.controlled(
                        focusedDate: _focusedDate,
                        selection: _multipleSelection,
                        onFocusedDateChanged: (date) =>
                            setState(() => _focusedDate = date),
                        onSelectionChanged: (_, next) =>
                            setState(() => _multipleSelection = next),
                        behavior: const CalendarBehavior(
                          selectionBehavior: CalendarSelectionBehavior(
                            maximumMultipleDates: 4,
                            allowEmptyMultiple: true,
                          ),
                        ),
                        appearance: _appearance(style: CalendarStyle.aurora),
                      ),
                      const SizedBox(height: 18),
                      const _DemoLabel('DATE RANGE · TAP TO RESTART'),
                      HorizontalCalendar<Object?>.controlled(
                        focusedDate: _focusedDate,
                        selection: _rangeSelection,
                        onFocusedDateChanged: (date) =>
                            setState(() => _focusedDate = date),
                        onSelectionChanged: (_, next) =>
                            setState(() => _rangeSelection = next),
                        behavior: const CalendarBehavior(
                          selectionBehavior: CalendarSelectionBehavior(
                            maximumRangeDays: 10,
                          ),
                        ),
                        appearance: _appearance(style: CalendarStyle.sunset),
                      ),
                    ],
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.pickers,
                  eyebrow: 'HORIZON PICKER',
                  title: 'Move through dates as the sky changes',
                  description:
                      'An original date scrubber with decorative sun, moon, phase, drag, keyboard, month controls, bounds, and disabled-date handling.',
                  child: CelestialDatePicker(
                    value: _celestialDate,
                    onChanged: (date) => setState(() => _celestialDate = date),
                    bounds: CalendarDateRange(
                      DateTime(2026, 1, 1),
                      DateTime(2027, 12, 31),
                    ),
                    selectableDayPredicate: (date) =>
                        date.weekday != DateTime.friday,
                    appearance: _appearance(style: CalendarStyle.midnight),
                    celestialMotion: const CelestialMotion(
                      duration: Duration(milliseconds: 900),
                      arcHeight: .78,
                      drift: .28,
                      parallax: .42,
                      trailLength: .72,
                      starTwinkle: .78,
                    ),
                    style: const CelestialDatePickerStyle(
                      skyHeight: 210,
                      skyStyle: CelestialSkyStyle.aurora,
                      composition: CelestialComposition.cinematic,
                      showClouds: true,
                      showConstellations: true,
                      showPhaseOrbit: true,
                      showDateProgress: true,
                    ),
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.data,
                  eyebrow: 'CALENDAR INSIGHTS',
                  title:
                      'Heatmaps and streaks that speak the same design language',
                  description:
                      'Activity intensity and completion state stay accessible, tappable, localized, and horizontally compact.',
                  child: Column(
                    children: [
                      CalendarHeatmapStrip(
                        startDate: DateTime(2026, 8, 1),
                        dayCount: 31,
                        values: demoHeatmapValues,
                        selectedDate: _selectedDate,
                        onDateTap: (date) =>
                            setState(() => _selectedDate = date),
                        appearance: _appearance(style: CalendarStyle.neon),
                        style: const CalendarHeatmapStyle(
                          design: CalendarHeatmapDesign.ring,
                          animate: true,
                          showPercentage: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 196,
                        child: CalendarContributionHeatmap(
                          startDate: DateTime(2026, 1, 1),
                          dayCount: 365,
                          values: demoContributionValues,
                          selectedDate: _selectedDate,
                          onDateTap: (date) =>
                              setState(() => _selectedDate = date),
                          appearance: _appearance(style: CalendarStyle.aurora),
                          style: const CalendarHeatmapStyle(
                            design: CalendarHeatmapDesign.pill,
                            cellExtent: 32,
                            cellSpacing: 5,
                            showLabels: false,
                            animate: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      CalendarStreakStrip(
                        startDate: DateTime(2026, 8, 1),
                        dayCount: 31,
                        today: DateTime(2026, 8, 10),
                        selectedDate: _selectedDate,
                        completedDates: demoCompletedDates,
                        onDateTap: (date) =>
                            setState(() => _selectedDate = date),
                        appearance: _appearance(style: CalendarStyle.soft),
                      ),
                      const SizedBox(height: 18),
                      CalendarInsightsDashboard<DemoEvent>(
                        title: 'Your calendar, decoded',
                        subtitle: 'A useful summary without losing the dates.',
                        metrics: demoInsightMetrics,
                        design: CalendarInsightsDesign.glass,
                        appearance:
                            _appearance(style: CalendarStyle.cupertinoGlass),
                      ),
                    ],
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.data,
                  eyebrow: 'PHONE HOME WIDGETS',
                  title: 'Calendar context before the app even opens',
                  description:
                      'One serializable contract powers responsive Flutter previews, Android launcher widgets, and the WidgetKit extension.',
                  child: Column(
                    children: [
                      SizedBox(
                        height: 170,
                        child: CalendarHomeWidget(
                          data: demoHomeWidgetData,
                          family: CalendarHomeWidgetFamily.medium,
                          content: CalendarHomeWidgetContent.week,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CalendarHomeWidget(
                                data: demoHomeWidgetData,
                                family: CalendarHomeWidgetFamily.small,
                                content: CalendarHomeWidgetContent.today,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CalendarHomeWidget(
                                data: demoHomeWidgetData,
                                family: CalendarHomeWidgetFamily.small,
                                content: CalendarHomeWidgetContent.countdown,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/home-widget-studio',
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('Open all home-widget controls'),
                      ),
                    ],
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.planning,
                  eyebrow: 'FOLDABLE',
                  title:
                      'Week when you need speed. Month when you need context.',
                  description:
                      'Tap the handle or drag vertically. Focus, selection, events, and bounds remain shared.',
                  child: _calendarFrame(
                    FoldableCalendar<DemoEvent>(
                      focusedDate: _focusedDate,
                      selection: _selection,
                      foldState: _foldState,
                      onFocusedDateChanged: (date) =>
                          setState(() => _focusedDate = date),
                      onSelectionChanged: (_, next) =>
                          setState(() => _selection = next),
                      onFoldStateChanged: (state) =>
                          setState(() => _foldState = state),
                      appearance: _appearance(
                        theme: HorizontalCalendarThemeData.glass(
                          brightness: Theme.of(context).brightness,
                        ),
                      ),
                      events: demoEvents,
                      foldControl: CalendarFoldControl.button,
                      expandLabel: 'Open month view',
                      collapseLabel: 'Return to week',
                    ),
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.events,
                  eyebrow: 'EVENT-RICH STRIP',
                  title: 'Typed data without calendar boilerplate',
                  description:
                      'Cross-midnight events are bucketed once per date and custom builders receive complete immutable day state.',
                  child: _calendarFrame(
                    HorizontalCalendar<DemoEvent>.controlled(
                      focusedDate: _focusedDate,
                      selection: _multipleSelection,
                      onFocusedDateChanged: (date) =>
                          setState(() => _focusedDate = date),
                      onSelectionChanged: (_, next) =>
                          setState(() => _multipleSelection = next),
                      events: demoEvents,
                      appearance:
                          _appearance(indicator: EventIndicatorStyle.count),
                    ),
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.events,
                  eyebrow: 'AGENDA',
                  title: 'The story behind each day',
                  description:
                      'Synchronous or asynchronous events, grouped by civil date with typed callbacks and refresh states.',
                  height: 520,
                  child: CalendarAgenda<DemoEvent>(
                    interval: CalendarVisibleInterval(
                      DateTime(2026, 8, 3),
                      DateTime(2026, 8, 10),
                    ),
                    events: demoEvents,
                    appearance: _appearance(),
                    onEventTap: _showEvent,
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.custom,
                  eyebrow: 'CUSTOM BUILDERS',
                  title: 'Own every pixel without rebuilding the engine',
                  description:
                      'Custom content still receives normalized selection, focus, availability, events, range position, and semantics.',
                  child: _calendarFrame(
                    HorizontalCalendar<DemoEvent>.controlled(
                      focusedDate: _focusedDate,
                      selection: _selection,
                      onFocusedDateChanged: (date) =>
                          setState(() => _focusedDate = date),
                      onSelectionChanged: (_, next) =>
                          setState(() => _selection = next),
                      events: demoEvents,
                      appearance: _appearance(),
                      builders: CalendarBuilders<DemoEvent>(
                        dayBuilder: (context, state) =>
                            _GalleryDay(state: state),
                      ),
                    ),
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.planning,
                  eyebrow: 'DATE RAIL',
                  title: 'A vertical date axis for feeds and journeys',
                  description:
                      'Lazy, typed, event-aware date rows work as a schedule sidebar or as the spine of a chronological feed.',
                  child: SizedBox(
                    height: 360,
                    child: CalendarDateRail<DemoEvent>(
                      startDate: DateTime(2026, 8, 1),
                      dayCount: 31,
                      selectedDate: _railDate,
                      onDateSelected: (date) =>
                          setState(() => _railDate = date),
                      items: demoCarouselItems,
                      events: demoEvents,
                      appearance: _appearance(style: CalendarStyle.paper),
                    ),
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.planning,
                  eyebrow: 'PLANNING BUILDING BLOCKS',
                  title: 'Ribbons, milestones, and bookable availability',
                  description:
                      'Compose complete scheduling flows with overlap-aware intervals, project dates, and controlled time slots.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _DemoLabel('SCHEDULE RIBBON'),
                      CalendarScheduleRibbon<DemoEvent>(
                        date: DateTime(2026, 8, 5),
                        intervals: demoScheduleIntervals,
                        startHour: 8,
                        endHour: 18,
                        minuteWidth: 1.4,
                        now: DateTime(2026, 8, 5, 11, 20),
                        appearance: _appearance(style: CalendarStyle.terminal),
                      ),
                      const SizedBox(height: 20),
                      const _DemoLabel('MILESTONES'),
                      SizedBox(
                        height: 138,
                        child: CalendarMilestoneTimeline<DemoEvent>(
                          milestones: demoMilestones,
                          currentDate: DateTime(2026, 8, 10),
                          design: CalendarMilestoneDesign.roadmap,
                          appearance: _appearance(style: CalendarStyle.luxury),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _DemoLabel('AVAILABILITY'),
                      CalendarAvailabilityStrip<DemoEvent>(
                        slots: demoAvailability,
                        selectedSlotId: _selectedSlot,
                        onSlotSelected: (slot) =>
                            setState(() => _selectedSlot = slot.id),
                        layout: CalendarAvailabilityLayout.auto,
                        design: CalendarAvailabilityDesign.schedule,
                        appearance:
                            _appearance(style: CalendarStyle.cupertinoTinted),
                      ),
                    ],
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.planning,
                  eyebrow: 'DATE INDICATORS',
                  title: 'Small surfaces with real calendar intelligence',
                  description:
                      'Countdowns, weekly progress, and range summaries adapt their geometry to narrow screens and large text.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CalendarCountdownCard<DemoEvent>(
                        startDate: DateTime(2026, 8, 1),
                        referenceDate: DateTime(2026, 8, 5),
                        targetDate: DateTime(2026, 8, 18),
                        title: 'Design system launch',
                        data: const DemoEvent('Calendar team', 'launch'),
                        appearance: _appearance(style: CalendarStyle.sunset),
                      ),
                      const SizedBox(height: 18),
                      CalendarWeekProgress(
                        startDate: DateTime(2026, 8, 3),
                        currentDate: DateTime(2026, 8, 5),
                        selectedDate: _selectedDate,
                        onDateTap: (date) =>
                            setState(() => _selectedDate = date),
                        appearance: _appearance(style: CalendarStyle.soft),
                      ),
                      const SizedBox(height: 18),
                      CalendarDateRangeSummary<DemoEvent>(
                        range: CalendarDateRange(
                          DateTime(2026, 8, 3),
                          DateTime(2026, 8, 18),
                        ),
                        referenceDate: DateTime(2026, 8, 8),
                        title: 'Release runway',
                        data: const DemoEvent('Release team', 'range'),
                        appearance: _appearance(style: CalendarStyle.luxury),
                      ),
                    ],
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.legacy,
                  eyebrow: 'LEGACY SAFE',
                  title: 'Every 1.x calendar still has a home',
                  description:
                      'The original widgets remain usable and deprecated with clear migration paths, so upgrading never forces a rewrite.',
                  child: _legacyGallery(),
                ),
                _section(
                  context,
                  category: _GalleryCategory.planning,
                  eyebrow: 'DAY TIMELINE',
                  title: 'Overlaps that stay readable',
                  description:
                      'Connected collisions use deterministic columns while taps return the original typed event.',
                  child: DayTimeline<DemoEvent>(
                    date: DateTime(2026, 8, 5),
                    events: demoEvents,
                    now: DateTime(2026, 8, 5, 11, 20),
                    configuration: const CalendarTimelineConfiguration(
                      startHour: 8,
                      endHour: 18,
                      viewportHeight: 560,
                    ),
                    appearance: _appearance(),
                    onEventTap: _showEvent,
                  ),
                ),
                _section(
                  context,
                  category: _GalleryCategory.planning,
                  eyebrow: 'WEEK TIMELINE',
                  title: 'The full working week',
                  description:
                      'Contiguous day columns, configurable hours, current time, and compact horizontal navigation.',
                  child: WeekTimeline<DemoEvent>(
                    startDate: DateTime(2026, 8, 3),
                    dayCount: 5,
                    events: demoEvents,
                    now: DateTime(2026, 8, 5, 11, 20),
                    configuration: const CalendarTimelineConfiguration(
                      startHour: 8,
                      endHour: 18,
                      viewportHeight: 560,
                      dayColumnWidth: 210,
                    ),
                    appearance: _appearance(),
                    onEventTap: _showEvent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _galleryHero(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              Color.lerp(colors.primary, colors.tertiary, .72)!,
              const Color(0xFF111938),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: .25),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIME, DESIGNED.',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'The horizontal calendar\nUI kit for Flutter.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        height: .98,
                        letterSpacing: -1.4,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Week strips, native pickers, celestial motion, planning surfaces, insights, and legacy-safe migration—built around one predictable date engine.',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 18),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroTag('21 visual styles'),
                    _HeroTag('11 page transitions'),
                    _HeroTag('Material + Cupertino'),
                    _HeroTag('Legacy safe'),
                  ],
                ),
              ],
            );
            final emblem = Container(
              width: compact ? 116 : 172,
              height: compact ? 116 : 172,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .1),
                border: Border.all(color: Colors.white24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: compact ? 58 : 82,
                  ),
                  Positioned(
                    top: compact ? 15 : 20,
                    right: compact ? 6 : 10,
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFFD166),
                      size: 28,
                    ),
                  ),
                ],
              ),
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [emblem, const SizedBox(height: 22), copy],
              );
            }
            return Row(
              children: [
                Expanded(child: copy),
                const SizedBox(width: 36),
                emblem,
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _controls(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                    value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                ButtonSegment(
                    value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
              ],
              selected: {widget.themeMode},
              onSelectionChanged: (value) =>
                  widget.onThemeModeChanged(value.single),
            ),
            DropdownButton<CalendarDensity>(
              value: widget.density,
              items: CalendarDensity.values
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.name),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) widget.onDensityChanged(value);
              },
            ),
            DropdownButton<CalendarStyle>(
              value: widget.style,
              items: CalendarStyle.values
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.name),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) widget.onStyleChanged(value);
              },
            ),
            DropdownButton<_GalleryMotion>(
              value: widget.motion,
              items: _GalleryMotion.values
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text('${value.name} motion'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) widget.onMotionChanged(value);
              },
            ),
            FilterChip(
              label: const Text('RTL'),
              selected: widget.rtl,
              onSelected: widget.onRtlChanged,
            ),
            FilterChip(
              label: const Text('High contrast'),
              selected: widget.highContrast,
              onSelected: widget.onHighContrastChanged,
            ),
            SizedBox(
              width: 190,
              child: Row(
                children: [
                  const Icon(Icons.text_fields, size: 18),
                  Expanded(
                    child: Slider(
                      value: widget.textScale,
                      min: 1,
                      max: 2,
                      divisions: 4,
                      label: '${widget.textScale}×',
                      onChanged: widget.onTextScaleChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          for (final category in _GalleryCategory.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: _category == category,
                onSelected: (_) => setState(() => _category = category),
              ),
            ),
        ],
      ),
    );
  }

  Widget _presetCarousel(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final presets = <(String, HorizontalCalendarThemeData)>[
      (
        'Material 3',
        HorizontalCalendarThemeData.material3(brightness: brightness)
      ),
      (
        'Cupertino',
        HorizontalCalendarThemeData.cupertino(brightness: brightness)
      ),
      ('Neutral', HorizontalCalendarThemeData.neutral(brightness: brightness)),
      ('Glass', HorizontalCalendarThemeData.glass(brightness: brightness)),
      (
        'Editorial',
        HorizontalCalendarThemeData.editorial(brightness: brightness)
      ),
      ('Bold', HorizontalCalendarThemeData.bold(brightness: brightness)),
      (
        'Material Expressive',
        HorizontalCalendarThemeData.materialExpressive(brightness: brightness)
      ),
      (
        'Cupertino Glass',
        HorizontalCalendarThemeData.cupertinoGlass(brightness: brightness)
      ),
      ('Minimal', HorizontalCalendarThemeData.minimal(brightness: brightness)),
      ('Pill', HorizontalCalendarThemeData.pill(brightness: brightness)),
      ('Soft', HorizontalCalendarThemeData.soft(brightness: brightness)),
      ('Neon', HorizontalCalendarThemeData.neon(brightness: brightness)),
      (
        'Monochrome',
        HorizontalCalendarThemeData.monochrome(brightness: brightness)
      ),
      ('Aurora', HorizontalCalendarThemeData.aurora(brightness: brightness)),
      ('Sunset', HorizontalCalendarThemeData.sunset(brightness: brightness)),
      (
        'Midnight',
        HorizontalCalendarThemeData.midnight(brightness: brightness)
      ),
      ('Paper', HorizontalCalendarThemeData.paper(brightness: brightness)),
      (
        'Terminal',
        HorizontalCalendarThemeData.terminal(brightness: brightness)
      ),
      ('Luxury', HorizontalCalendarThemeData.luxury(brightness: brightness)),
      (
        'Material You',
        HorizontalCalendarThemeData.materialYou(brightness: brightness)
      ),
      (
        'Cupertino Tinted',
        HorizontalCalendarThemeData.cupertinoTinted(brightness: brightness)
      ),
    ];
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final preset = presets[index];
          return SizedBox(
            width: 430,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(preset.$1,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                HorizontalCalendar<DemoEvent>(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) =>
                      setState(() => _selectedDate = date),
                  appearance: _appearance(theme: preset.$2),
                  events: demoEvents,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _legacyGallery() {
    const legacyStyle = legacy.HorizontalCalendarStyle(
      activeDayColor: Color(0xFF5547D7),
      dayIndicatorSize: 42,
      selectionAnimationDuration: Duration(milliseconds: 260),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DemoLabel('ORIGINAL HORIZONTAL WEEKLY CALENDAR'),
        legacy.HorizontalWeeklyCalendar(
          initialDate: _focusedDate,
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
          onNextMonth: () => setState(() {
            _focusedDate = DateTime(
              _focusedDate.year,
              _focusedDate.month + 1,
              1,
            );
          }),
          onPreviousMonth: () => setState(() {
            _focusedDate = DateTime(
              _focusedDate.year,
              _focusedDate.month - 1,
              1,
            );
          }),
          calendarType: legacy.HorizontalCalendarType.elevated,
          calendarStyle: legacyStyle,
        ),
        const SizedBox(height: 24),
        const _DemoLabel('TABLE WEEKLY CALENDAR'),
        legacy.TableWeeklyCalendar(
          initialDate: _focusedDate,
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
          onMonthChanged: (date) => setState(() => _focusedDate = date),
          focusDates: [
            legacy.FocusDate(
              date: DateTime(2026, 8, 12),
              backgroundColor: const Color(0xFFFFD166),
              foregroundColor: const Color(0xFF191510),
            ),
          ],
          calendarStyle: legacyStyle,
        ),
        const SizedBox(height: 24),
        const _DemoLabel('EVENT CALENDAR'),
        SizedBox(
          height: 520,
          child: legacy.EventCalendar(
            currentMonth: _focusedDate,
            selectedDate: _selectedDate,
            events: _legacyEvents,
            startHour: 8,
            endHour: 16,
            onDateSelected: (date) => setState(() => _selectedDate = date),
            onNextMonth: () => setState(() {
              _focusedDate = DateTime(
                _focusedDate.year,
                _focusedDate.month + 1,
                1,
              );
            }),
            onPreviousMonth: () => setState(() {
              _focusedDate = DateTime(
                _focusedDate.year,
                _focusedDate.month - 1,
                1,
              );
            }),
            style: const legacy.EventCalendarStyle(
              timeSlotHeight: 48,
              hourSlotHeight: 48,
              calendarStyle: legacyStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _catalogToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String route,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerHigh,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(description),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Open live studio',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: colors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendarFrame(Widget child) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: child,
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required _GalleryCategory category,
    required String eyebrow,
    required String title,
    required String description,
    required Widget child,
    double? height,
  }) {
    if (_category != _GalleryCategory.all && _category != category) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: height == null
                  ? child
                  : SizedBox(height: height, child: child),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAdaptivePicker() async {
    final date = await showAdaptiveCalendarPicker(
      context: context,
      initialDate: _nativeDate,
      bounds: CalendarDateRange(
        DateTime(2026, 1, 1),
        DateTime(2027, 12, 31),
      ),
      appearance: _appearance(),
      materialConfiguration: const CalendarMaterialPickerConfiguration(
        confirmSelection: true,
        showQuickActions: true,
        headline: 'Plan something remarkable',
        helpText: 'Pick a day, then confirm when it feels right.',
      ),
    );
    if (date != null && mounted) setState(() => _nativeDate = date);
  }

  Future<void> _openCupertinoWheel() async {
    final date = await showAdaptiveCalendarPicker(
      context: context,
      initialDate: _nativeDate,
      bounds: CalendarDateRange(
        DateTime(2026, 1, 1),
        DateTime(2027, 12, 31),
      ),
      appearance: _appearance(style: CalendarStyle.cupertinoTinted),
      cupertinoPresentation: CalendarCupertinoPickerPresentation.wheel,
      cupertinoWheelConfiguration:
          const CalendarCupertinoPickerConfiguration(showDayOfWeek: true),
    );
    if (date != null && mounted) setState(() => _nativeDate = date);
  }

  void _showEvent(CalendarEvent<DemoEvent> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${event.title} · ${event.data!.owner}')),
    );
  }
}

class RecordingShowcase extends StatefulWidget {
  const RecordingShowcase({super.key});

  @override
  State<RecordingShowcase> createState() => _RecordingShowcaseState();
}

class _RecordingShowcaseState extends State<RecordingShowcase> {
  var _selected = DateTime(2026, 8, 5);

  @override
  Widget build(BuildContext context) {
    final theme = HorizontalCalendarThemeData.bold(
      brightness: Theme.of(context).brightness,
    );
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  children: [
                    Text(
                      'Your calendar should feel like your app.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Horizontal Calendar 2.0',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 36),
                    HorizontalCalendar<DemoEvent>(
                      selectedDate: _selected,
                      onDateSelected: (date) =>
                          setState(() => _selected = date),
                      appearance: CalendarAppearance(
                        theme: theme,
                        eventIndicatorStyle: EventIndicatorStyle.stack,
                        motion: CalendarMotion.playful(),
                      ),
                      events: demoEvents,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 330,
                      child: CalendarAgenda<DemoEvent>(
                        interval: CalendarVisibleInterval(
                          DateTime(2026, 8, 3),
                          DateTime(2026, 8, 10),
                        ),
                        events: demoEvents,
                        appearance: CalendarAppearance(theme: theme),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CaptureShowcase extends StatefulWidget {
  const CaptureShowcase({super.key, required this.kind});

  final String kind;

  @override
  State<CaptureShowcase> createState() => _CaptureShowcaseState();
}

class _CaptureShowcaseState extends State<CaptureShowcase> {
  var _selected = DateTime(2026, 8, 5);
  var _focused = DateTime(2026, 8, 5);
  var _fold = CalendarFoldState.collapsed;
  var _selection = CalendarSelection.single(DateTime(2026, 8, 5));
  String? _selectedSlot = 'slot-1030';

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.kind) {
      'styles' => 'A calendar for every product language.',
      'motion' => 'Motion that makes time feel tangible.',
      'foldable' => 'One week. One month. One continuous thought.',
      'native' => 'Native where it matters.',
      'planning' => 'From date choice to the shape of the day.',
      'data' => 'Turn dates into progress.',
      'selection' => 'Every selection mode. One predictable contract.',
      'celestial' => 'Let the sky carry you through time.',
      'widgets' => 'The building blocks of a complete scheduling flow.',
      'legacy' => 'The future arrived without breaking the past.',
      'carousel' => 'Dates with depth, hierarchy, and momentum.',
      'horizon' => 'A date transition written across the sky.',
      'heatmaps' => 'Make every day of progress visible.',
      'responsive' => 'Calendar UI that respects every screen.',
      'home-widgets' => 'Your calendar, alive on the home screen.',
      _ => 'Horizontal Calendar 2.0',
    };
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'horizontal_weekly_calendar 2.0',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 34),
                    _surface(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _surface(BuildContext context) {
    return switch (widget.kind) {
      'styles' => Column(
          children: [
            _captureCalendar(CalendarStyle.materialExpressive),
            const SizedBox(height: 18),
            _captureCalendar(CalendarStyle.cupertinoGlass),
            const SizedBox(height: 18),
            _captureCalendar(CalendarStyle.neon),
          ],
        ),
      'motion' => Column(
          children: [
            _captureCalendar(
              CalendarStyle.bold,
              motion: CalendarMotion.cinematic(),
            ),
            const SizedBox(height: 20),
            CalendarDateCarousel<DemoEvent>(
              startDate: DateTime(2026, 8, 3),
              dayCount: 10,
              selectedDate: _selected,
              onDateSelected: (date) => setState(() => _selected = date),
              items: demoCarouselItems,
              events: demoEvents,
              appearance: CalendarAppearance(
                style: CalendarStyle.pill,
                motion: CalendarMotion.premium(),
              ),
              visualStyle: const CalendarCarouselVisualStyle(
                layout: CalendarCarouselLayout.spotlight,
              ),
            ),
          ],
        ),
      'foldable' => FoldableCalendar<DemoEvent>(
          focusedDate: _focused,
          selection: _selection,
          foldState: _fold,
          onFocusedDateChanged: (date) => setState(() => _focused = date),
          onSelectionChanged: (_, next) => setState(() => _selection = next),
          onFoldStateChanged: (state) => setState(() => _fold = state),
          events: demoEvents,
          foldControl: CalendarFoldControl.button,
          appearance: CalendarAppearance(
            style: CalendarStyle.cupertinoGlass,
            motion: CalendarMotion.spring(),
          ),
        ),
      'native' => Column(
          children: [
            AdaptiveCalendarNavigationBar(
              focusedDate: _focused,
              onPrevious: () => setState(() {
                _focused = DateTime(_focused.year, _focused.month - 1, 1);
              }),
              onNext: () => setState(() {
                _focused = DateTime(_focused.year, _focused.month + 1, 1);
              }),
              onToday: () => setState(() => _focused = DateTime.now()),
              appearance: const CalendarAppearance(
                style: CalendarStyle.cupertinoGlass,
              ),
            ),
            const SizedBox(height: 14),
            _captureCalendar(CalendarStyle.cupertinoGlass),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => showAdaptiveCalendarPicker(
                context: context,
                initialDate: _selected,
                appearance: const CalendarAppearance(
                  style: CalendarStyle.cupertinoTinted,
                ),
                cupertinoPresentation:
                    CalendarCupertinoPickerPresentation.wheel,
              ),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Open styled Cupertino wheel'),
            ),
          ],
        ),
      'planning' => LayoutBuilder(
          builder: (context, constraints) {
            final timeline = DayTimeline<DemoEvent>(
              date: DateTime(2026, 8, 5),
              events: demoEvents,
              now: DateTime(2026, 8, 5, 11, 20),
              configuration: const CalendarTimelineConfiguration(
                startHour: 8,
                endHour: 18,
                viewportHeight: 520,
              ),
              appearance: const CalendarAppearance(
                style: CalendarStyle.materialExpressive,
              ),
            );
            final agenda = SizedBox(
              height: 520,
              child: CalendarAgenda<DemoEvent>(
                interval: CalendarVisibleInterval(
                  DateTime(2026, 8, 3),
                  DateTime(2026, 8, 10),
                ),
                events: demoEvents,
                appearance: const CalendarAppearance(
                  style: CalendarStyle.minimal,
                ),
              ),
            );
            if (constraints.maxWidth < 820) {
              return Column(
                  children: [timeline, const SizedBox(height: 18), agenda]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: timeline),
                const SizedBox(width: 18),
                Expanded(child: agenda),
              ],
            );
          },
        ),
      'data' => Column(
          children: [
            CalendarInsightsDashboard<DemoEvent>(
              title: 'Your calendar, decoded',
              subtitle: 'Signals that remain useful at a glance.',
              metrics: demoInsightMetrics,
              design: CalendarInsightsDesign.glass,
              appearance: const CalendarAppearance(
                style: CalendarStyle.cupertinoGlass,
              ),
            ),
            const SizedBox(height: 20),
            CalendarHeatmapStrip(
              startDate: DateTime(2026, 8, 1),
              dayCount: 31,
              values: demoHeatmapValues,
              selectedDate: _selected,
              onDateTap: (date) => setState(() => _selected = date),
              style: const CalendarHeatmapStyle(
                design: CalendarHeatmapDesign.ring,
                showPercentage: true,
              ),
              appearance: const CalendarAppearance(
                style: CalendarStyle.neon,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 196,
              child: CalendarContributionHeatmap(
                startDate: DateTime(2026, 1, 1),
                dayCount: 365,
                values: demoContributionValues,
                selectedDate: _selected,
                onDateTap: (date) => setState(() => _selected = date),
                appearance: const CalendarAppearance(
                  style: CalendarStyle.aurora,
                ),
                style: const CalendarHeatmapStyle(
                  design: CalendarHeatmapDesign.pill,
                  cellExtent: 32,
                  cellSpacing: 5,
                  showLabels: false,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CalendarStreakStrip(
              startDate: DateTime(2026, 8, 1),
              dayCount: 31,
              today: DateTime(2026, 8, 10),
              selectedDate: _selected,
              completedDates: demoCompletedDates,
              onDateTap: (date) => setState(() => _selected = date),
              appearance: const CalendarAppearance(style: CalendarStyle.soft),
            ),
          ],
        ),
      'selection' => Column(
          children: [
            HorizontalCalendar<DemoEvent>.controlled(
              focusedDate: _focused,
              selection: _selection,
              onFocusedDateChanged: (date) => setState(() => _focused = date),
              onSelectionChanged: (_, next) =>
                  setState(() => _selection = next),
              behavior: const CalendarBehavior(
                selectionBehavior: CalendarSelectionBehavior(
                  singleTap: CalendarSingleTapBehavior.toggle,
                ),
              ),
              events: demoEvents,
              appearance: CalendarAppearance(
                style: CalendarStyle.materialYou,
                motion: CalendarMotion.fluid(),
              ),
            ),
            const SizedBox(height: 20),
            CalendarDateCarousel<DemoEvent>.controlled(
              startDate: DateTime(2026, 8, 1),
              dayCount: 18,
              selection: _selection,
              onSelectionChanged: (_, next) =>
                  setState(() => _selection = next),
              items: demoCarouselItems,
              events: demoEvents,
              scrolling: CalendarScrollBehavior.page,
              appearance: const CalendarAppearance(
                style: CalendarStyle.aurora,
              ),
            ),
          ],
        ),
      'celestial' => CelestialDatePicker(
          value: _selected,
          onChanged: (date) => setState(() => _selected = date),
          bounds: CalendarDateRange(
            DateTime(2026, 1, 1),
            DateTime(2027, 12, 31),
          ),
          appearance: CalendarAppearance(
            style: CalendarStyle.midnight,
            motion: CalendarMotion.fluid(),
          ),
        ),
      'widgets' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CalendarScheduleRibbon<DemoEvent>(
              date: DateTime(2026, 8, 5),
              intervals: demoScheduleIntervals,
              startHour: 8,
              endHour: 18,
              now: DateTime(2026, 8, 5, 11, 20),
              appearance:
                  const CalendarAppearance(style: CalendarStyle.terminal),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 138,
              child: CalendarMilestoneTimeline<DemoEvent>(
                milestones: demoMilestones,
                currentDate: DateTime(2026, 8, 10),
                design: CalendarMilestoneDesign.roadmap,
                appearance:
                    const CalendarAppearance(style: CalendarStyle.luxury),
              ),
            ),
            const SizedBox(height: 20),
            CalendarAvailabilityStrip<DemoEvent>(
              slots: demoAvailability,
              selectedSlotId: _selectedSlot,
              onSlotSelected: (slot) => setState(() => _selectedSlot = slot.id),
              layout: CalendarAvailabilityLayout.auto,
              design: CalendarAvailabilityDesign.schedule,
              appearance: const CalendarAppearance(
                style: CalendarStyle.cupertinoTinted,
              ),
            ),
            const SizedBox(height: 20),
            CalendarCountdownCard<DemoEvent>(
              startDate: DateTime(2026, 8, 1),
              referenceDate: DateTime(2026, 8, 5),
              targetDate: DateTime(2026, 8, 18),
              title: 'Package 2.0 launch',
              data: const DemoEvent('Calendar team', 'launch'),
              appearance: const CalendarAppearance(
                style: CalendarStyle.sunset,
              ),
            ),
          ],
        ),
      'carousel' => Column(
          children: [
            CalendarDateCarousel<DemoEvent>(
              startDate: DateTime(2026, 8, 1),
              dayCount: 18,
              selectedDate: _selected,
              onDateSelected: (date) => setState(() => _selected = date),
              items: demoCarouselItems,
              events: demoEvents,
              scrolling: CalendarScrollBehavior.page,
              appearance: CalendarAppearance(
                style: CalendarStyle.aurora,
                motion: CalendarMotion.premium(),
              ),
              visualStyle: const CalendarCarouselVisualStyle(
                layout: CalendarCarouselLayout.spotlight,
                selectedScale: 1.035,
                inactiveScale: .96,
                inactiveOpacity: .76,
                spacing: 12,
                elevation: 8,
                borderRadius: 24,
              ),
            ),
            const SizedBox(height: 28),
            CalendarDateCarousel<DemoEvent>(
              startDate: DateTime(2026, 8, 1),
              dayCount: 18,
              selectedDate: _selected,
              onDateSelected: (date) => setState(() => _selected = date),
              items: demoCarouselItems,
              events: demoEvents,
              appearance:
                  const CalendarAppearance(style: CalendarStyle.editorial),
              visualStyle: const CalendarCarouselVisualStyle(
                layout: CalendarCarouselLayout.editorial,
                inactiveScale: .95,
                inactiveOpacity: .72,
                useGradient: false,
              ),
            ),
          ],
        ),
      'horizon' => CelestialDatePicker(
          value: _selected,
          onChanged: (date) => setState(() => _selected = date),
          bounds: CalendarDateRange(
            DateTime(2026, 1, 1),
            DateTime(2027, 12, 31),
          ),
          appearance: const CalendarAppearance(style: CalendarStyle.midnight),
          celestialMotion: const CelestialMotion(
            duration: Duration(milliseconds: 1100),
            arcHeight: .82,
            drift: .36,
            parallax: .5,
            rotation: .36,
            trailLength: .86,
            starTwinkle: .9,
          ),
          style: const CelestialDatePickerStyle(
            skyHeight: 280,
            skyStyle: CelestialSkyStyle.aurora,
            composition: CelestialComposition.cinematic,
            showClouds: true,
            showConstellations: true,
            showPhaseOrbit: true,
            showDateProgress: true,
          ),
        ),
      'heatmaps' => Column(
          children: [
            for (final design in CalendarHeatmapDesign.values) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  design.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              CalendarHeatmapStrip(
                startDate: DateTime(2026, 8, 1),
                dayCount: 31,
                selectedDate: _selected,
                values: demoHeatmapValues,
                onDateTap: (date) => setState(() => _selected = date),
                style: CalendarHeatmapStyle(
                  design: design,
                  animate: true,
                  showPercentage: design == CalendarHeatmapDesign.ring,
                ),
                appearance: const CalendarAppearance(
                  style: CalendarStyle.neon,
                ),
              ),
              const SizedBox(height: 18),
            ],
            SizedBox(
              height: 196,
              child: CalendarContributionHeatmap(
                startDate: DateTime(2026, 1, 1),
                dayCount: 365,
                values: demoContributionValues,
                selectedDate: _selected,
                onDateTap: (date) => setState(() => _selected = date),
                appearance:
                    const CalendarAppearance(style: CalendarStyle.aurora),
                style: const CalendarHeatmapStyle(
                  design: CalendarHeatmapDesign.pill,
                  cellExtent: 32,
                  cellSpacing: 5,
                  showLabels: false,
                ),
              ),
            ),
          ],
        ),
      'responsive' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CalendarCountdownCard<DemoEvent>(
              startDate: DateTime(2026, 8, 1),
              referenceDate: DateTime(2026, 8, 5),
              targetDate: DateTime(2026, 8, 18),
              title: 'Package of the week premiere',
              data: const DemoEvent('Calendar team', 'launch'),
              appearance: const CalendarAppearance(style: CalendarStyle.sunset),
            ),
            const SizedBox(height: 20),
            CalendarWeekProgress(
              startDate: DateTime(2026, 8, 3),
              currentDate: DateTime(2026, 8, 5),
              selectedDate: _selected,
              onDateTap: (date) => setState(() => _selected = date),
              appearance:
                  const CalendarAppearance(style: CalendarStyle.materialYou),
            ),
            const SizedBox(height: 20),
            CalendarDateRangeSummary<DemoEvent>(
              range: CalendarDateRange(
                DateTime(2026, 8, 3),
                DateTime(2026, 8, 18),
              ),
              referenceDate: DateTime(2026, 8, 9),
              title: 'Launch runway',
              data: const DemoEvent('Release team', 'range'),
              appearance: const CalendarAppearance(style: CalendarStyle.luxury),
            ),
          ],
        ),
      'home-widgets' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 18,
              runSpacing: 18,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CalendarHomeWidget(
                    data: demoHomeWidgetData,
                    family: CalendarHomeWidgetFamily.small,
                    content: CalendarHomeWidgetContent.today,
                    theme: const CalendarHomeWidgetTheme(
                      backgroundColor: Color(0xfffffbf3),
                      foregroundColor: Color(0xff201c17),
                      secondaryColor: Color(0xff74695c),
                      accentColor: Color(0xff9a5b32),
                      surfaceStyle: CalendarHomeWidgetSurfaceStyle.gradient,
                      gradientColors: [
                        Color(0xfffffbf3),
                        Color(0xffeee1c9),
                      ],
                      headerStyle: CalendarHomeWidgetHeaderStyle.compact,
                      cornerRadius: 32,
                    ),
                  ),
                ),
                SizedBox(
                  width: 360,
                  height: 170,
                  child: CalendarHomeWidget(
                    data: demoHomeWidgetData,
                    family: CalendarHomeWidgetFamily.medium,
                    content: CalendarHomeWidgetContent.week,
                    theme: const CalendarHomeWidgetTheme(
                      backgroundColor: Color(0xff19132f),
                      foregroundColor: Color(0xfffffaff),
                      secondaryColor: Color(0xffcabfe5),
                      accentColor: Color(0xffb8ffdc),
                      surfaceStyle: CalendarHomeWidgetSurfaceStyle.gradient,
                      gradientColors: [
                        Color(0xff19132f),
                        Color(0xff47327d),
                      ],
                      weekdayFormat: CalendarHomeWidgetWeekdayFormat.short,
                      dateShape: CalendarHomeWidgetDateShape.rounded,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 340,
              child: CalendarHomeWidget(
                data: demoHomeWidgetData,
                family: CalendarHomeWidgetFamily.large,
                content: CalendarHomeWidgetContent.agenda,
                theme: const CalendarHomeWidgetTheme(
                  backgroundColor: Color(0xff171225),
                  foregroundColor: Color(0xfffff8ed),
                  secondaryColor: Color(0xffffc9ae),
                  accentColor: Color(0xffffbc66),
                  surfaceStyle: CalendarHomeWidgetSurfaceStyle.gradient,
                  gradientColors: [
                    Color(0xff171225),
                    Color(0xff552a32),
                  ],
                  eventStyle: CalendarHomeWidgetEventStyle.card,
                  maximumEvents: 4,
                  itemSpacing: 8,
                  cornerRadius: 34,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CalendarHomeWidget(
                    data: demoHomeWidgetData,
                    family: CalendarHomeWidgetFamily.accessory,
                    theme: const CalendarHomeWidgetTheme(
                      backgroundColor: Color(0xff07111f),
                      accentColor: Color(0xff55d6be),
                      surfaceStyle: CalendarHomeWidgetSurfaceStyle.outlined,
                      borderColor: Color(0xff55d6be),
                      cornerRadius: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 110,
                    child: CalendarHomeWidget(
                      data: demoHomeWidgetData,
                      family: CalendarHomeWidgetFamily.compact,
                      content: CalendarHomeWidgetContent.progress,
                      theme: const CalendarHomeWidgetTheme(
                        backgroundColor: Color(0xff07111f),
                        foregroundColor: Color(0xfff7fbff),
                        secondaryColor: Color(0xff9fb1c7),
                        accentColor: Color(0xff55d6be),
                        progressStyle:
                            CalendarHomeWidgetProgressStyle.segmented,
                        surfaceStyle: CalendarHomeWidgetSurfaceStyle.gradient,
                        gradientColors: [
                          Color(0xff07111f),
                          Color(0xff183f4d),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 170,
              child: CalendarHomeWidget(
                data: demoHomeWidgetData,
                family: CalendarHomeWidgetFamily.medium,
                content: CalendarHomeWidgetContent.nextEvent,
                theme: const CalendarHomeWidgetTheme(
                  backgroundColor: Color(0xff321410),
                  foregroundColor: Color(0xfffff8ed),
                  secondaryColor: Color(0xffffc9ae),
                  accentColor: Color(0xffffd166),
                  surfaceStyle: CalendarHomeWidgetSurfaceStyle.outlined,
                  borderColor: Color(0xffffd166),
                  borderWidth: 2,
                  headerStyle: CalendarHomeWidgetHeaderStyle.month,
                  eventStyle: CalendarHomeWidgetEventStyle.dot,
                  cornerRadius: 22,
                ),
              ),
            ),
          ],
        ),
      'legacy' => _legacySurface(),
      _ => _captureCalendar(CalendarStyle.bold),
    };
  }

  Widget _legacySurface() {
    const legacyStyle = legacy.HorizontalCalendarStyle(
      activeDayColor: Color(0xFF5547D7),
      dayIndicatorSize: 42,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DemoLabel('HORIZONTAL WEEKLY CALENDAR · 1.x'),
        legacy.HorizontalWeeklyCalendar(
          initialDate: _focused,
          selectedDate: _selected,
          onDateSelected: (date) => setState(() => _selected = date),
          onNextMonth: () => setState(() {
            _focused = DateTime(_focused.year, _focused.month + 1, 1);
          }),
          onPreviousMonth: () => setState(() {
            _focused = DateTime(_focused.year, _focused.month - 1, 1);
          }),
          calendarType: legacy.HorizontalCalendarType.elevated,
          calendarStyle: legacyStyle,
        ),
        const SizedBox(height: 28),
        const _DemoLabel('TABLE WEEKLY CALENDAR · 1.x'),
        legacy.TableWeeklyCalendar(
          initialDate: _focused,
          selectedDate: _selected,
          onDateSelected: (date) => setState(() => _selected = date),
          onMonthChanged: (date) => setState(() => _focused = date),
          focusDates: [
            legacy.FocusDate(
              date: DateTime(2026, 8, 12),
              backgroundColor: const Color(0xFFFFD166),
              foregroundColor: const Color(0xFF191510),
            ),
          ],
          calendarStyle: legacyStyle,
        ),
        const SizedBox(height: 28),
        const _DemoLabel('EVENT CALENDAR · 1.x'),
        SizedBox(
          height: 520,
          child: legacy.EventCalendar(
            currentMonth: _focused,
            selectedDate: _selected,
            events: _legacyEvents,
            startHour: 8,
            endHour: 16,
            onDateSelected: (date) => setState(() => _selected = date),
            onNextMonth: () => setState(() {
              _focused = DateTime(_focused.year, _focused.month + 1, 1);
            }),
            onPreviousMonth: () => setState(() {
              _focused = DateTime(_focused.year, _focused.month - 1, 1);
            }),
            style: const legacy.EventCalendarStyle(
              timeSlotHeight: 48,
              hourSlotHeight: 48,
              calendarStyle: legacyStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _captureCalendar(
    CalendarStyle style, {
    CalendarMotion? motion,
  }) {
    return HorizontalCalendar<DemoEvent>(
      selectedDate: _selected,
      onDateSelected: (date) => setState(() => _selected = date),
      events: demoEvents,
      appearance: CalendarAppearance(
        style: style,
        eventIndicatorStyle: EventIndicatorStyle.stack,
        motion: motion ?? CalendarMotion.fluid(),
      ),
    );
  }
}

class DemoEvent {
  const DemoEvent(this.owner, this.category);

  final String owner;
  final String category;
}

class _HeroTag extends StatelessWidget {
  const _HeroTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DemoLabel extends StatelessWidget {
  const _DemoLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

final _legacyEvents = <legacy.CalendarEvent>[
  legacy.CalendarEvent(
    id: 'legacy-planning',
    title: 'Planning',
    startTime: DateTime(2026, 8, 5, 9),
    endTime: DateTime(2026, 8, 5, 10, 30),
    backgroundColor: const Color(0xFF5547D7),
  ),
  legacy.CalendarEvent(
    id: 'legacy-review',
    title: 'Review',
    startTime: DateTime(2026, 8, 6, 12),
    endTime: DateTime(2026, 8, 6, 13),
    backgroundColor: const Color(0xFF00A896),
  ),
];

final demoCarouselItems = <CalendarCarouselItem<DemoEvent>>[
  CalendarCarouselItem(
    date: DateTime(2026, 8, 4),
    title: 'Launch plan',
    subtitle: 'Product studio',
    badge: '2',
    data: const DemoEvent('Maya', 'Product'),
  ),
  CalendarCarouselItem(
    date: DateTime(2026, 8, 5),
    title: 'Design day',
    subtitle: 'Reviews and research',
    badge: '3',
    data: const DemoEvent('Noah', 'Design'),
  ),
  CalendarCarouselItem(
    date: DateTime(2026, 8, 7),
    title: 'Ship night',
    subtitle: 'Production deploy',
    badge: 'LIVE',
    data: const DemoEvent('Omar', 'Engineering'),
  ),
];

final demoHeatmapValues = <DateTime, double>{
  for (var day = 1; day <= 31; day += 1)
    DateTime(2026, 8, day): ((day * 37) % 100) / 100,
};

final demoContributionValues = <DateTime, double>{
  for (var day = 0; day < 365; day += 1)
    DateTime(2026, 1, 1 + day): ((day * 29 + (day ~/ 7) * 17) % 100) / 100,
};

final demoCompletedDates = <DateTime>{
  for (final day in [1, 2, 3, 5, 6, 7, 8, 10]) DateTime(2026, 8, day),
};

final demoScheduleIntervals = <CalendarScheduleInterval<DemoEvent>>[
  CalendarScheduleInterval(
    id: 'standup',
    title: 'Stand-up',
    start: DateTime(2026, 8, 5, 9),
    end: DateTime(2026, 8, 5, 9, 45),
    color: const Color(0xFF6857E5),
    data: const DemoEvent('Core team', 'Engineering'),
  ),
  CalendarScheduleInterval(
    id: 'research',
    title: 'Research calls',
    start: DateTime(2026, 8, 5, 9, 20),
    end: DateTime(2026, 8, 5, 11, 30),
    color: const Color(0xFF008E87),
    data: const DemoEvent('Lina', 'Research'),
  ),
  CalendarScheduleInterval(
    id: 'prototype',
    title: 'Prototype',
    start: DateTime(2026, 8, 5, 13),
    end: DateTime(2026, 8, 5, 16),
    color: const Color(0xFFE34B87),
    data: const DemoEvent('Noah', 'Design'),
  ),
];

final demoInsightMetrics = <CalendarInsightMetric<DemoEvent>>[
  CalendarInsightMetric(
    id: 'focus',
    label: 'Focus time',
    value: '14.5h',
    supportingText: '2.5h above last week',
    trend: CalendarInsightTrend.up,
    progress: .72,
    icon: Icons.bolt_rounded,
    data: const DemoEvent('Focus', 'insight-focus'),
  ),
  CalendarInsightMetric(
    id: 'streak',
    label: 'Active streak',
    value: '12 days',
    supportingText: 'Your longest this quarter',
    trend: CalendarInsightTrend.steady,
    progress: .86,
    icon: Icons.local_fire_department_rounded,
    accentColor: Color(0xffff8a65),
    data: const DemoEvent('Streak', 'insight-streak'),
  ),
  CalendarInsightMetric(
    id: 'open',
    label: 'Open windows',
    value: '6',
    supportingText: 'Across the next seven days',
    trend: CalendarInsightTrend.down,
    icon: Icons.timelapse_rounded,
    accentColor: Color(0xff4dd0e1),
    data: const DemoEvent('Availability', 'insight-open'),
  ),
  CalendarInsightMetric(
    id: 'balance',
    label: 'Meeting balance',
    value: '68%',
    supportingText: 'Two focus-first days protected',
    trend: CalendarInsightTrend.up,
    progress: .68,
    icon: Icons.balance_rounded,
    accentColor: Color(0xff9575cd),
    data: const DemoEvent('Balance', 'insight-balance'),
  ),
];

final demoHomeWidgetData = CalendarHomeWidgetData(
  generatedAt: DateTime(2026, 8, 10, 8),
  selectedDate: DateTime(2026, 8, 10),
  title: 'Creative week',
  subtitle: 'Three focused days ahead',
  targetDate: DateTime(2026, 8, 18),
  completedCount: 5,
  totalCount: 7,
  events: [
    CalendarHomeWidgetEvent(
      id: 'design-review',
      title: 'Design review',
      start: DateTime(2026, 8, 10, 9),
      end: DateTime(2026, 8, 10, 10),
      location: 'Studio',
      colorValue: 0xff9f8cff,
    ),
    CalendarHomeWidgetEvent(
      id: 'release-sync',
      title: 'Release sync',
      start: DateTime(2026, 8, 10, 11, 30),
      end: DateTime(2026, 8, 10, 12),
      location: 'Product room',
      colorValue: 0xffffbc66,
    ),
    CalendarHomeWidgetEvent(
      id: 'deep-work',
      title: 'Deep work',
      start: DateTime(2026, 8, 10, 14),
      end: DateTime(2026, 8, 10, 16),
      colorValue: 0xff4dd0e1,
    ),
  ],
  action: const CalendarHomeWidgetAction(
    uri: 'calendar-example://day/2026-08-10',
    label: 'Open August 10',
  ),
);

final demoMilestones = <CalendarMilestone<DemoEvent>>[
  CalendarMilestone(
    id: 'research-complete',
    date: DateTime(2026, 8, 3),
    title: 'Research complete',
    subtitle: '42 interviews',
    data: const DemoEvent('Lina', 'Research'),
  ),
  CalendarMilestone(
    id: 'beta',
    date: DateTime(2026, 8, 10),
    title: 'Private beta',
    subtitle: 'Today',
    data: const DemoEvent('Maya', 'Product'),
  ),
  CalendarMilestone(
    id: 'launch',
    date: DateTime(2026, 8, 24),
    title: 'Public launch',
    subtitle: 'All platforms',
    data: const DemoEvent('Core team', 'Product'),
  ),
];

final demoAvailability = <CalendarAvailabilitySlot<DemoEvent>>[
  CalendarAvailabilitySlot(
    id: 'slot-0900',
    start: DateTime(2026, 8, 5, 9),
    end: DateTime(2026, 8, 5, 9, 30),
    label: '9:00',
    data: const DemoEvent('Studio A', 'Booking'),
  ),
  CalendarAvailabilitySlot(
    id: 'slot-1030',
    start: DateTime(2026, 8, 5, 10, 30),
    end: DateTime(2026, 8, 5, 11),
    state: CalendarAvailabilityState.limited,
    label: '10:30 · 1 left',
    data: const DemoEvent('Studio B', 'Booking'),
  ),
  CalendarAvailabilitySlot(
    id: 'slot-1200',
    start: DateTime(2026, 8, 5, 12),
    end: DateTime(2026, 8, 5, 12, 30),
    state: CalendarAvailabilityState.unavailable,
    label: '12:00 · full',
    data: const DemoEvent('Studio A', 'Booking'),
  ),
  CalendarAvailabilitySlot(
    id: 'slot-1430',
    start: DateTime(2026, 8, 5, 14, 30),
    end: DateTime(2026, 8, 5, 15),
    label: '14:30',
    data: const DemoEvent('Studio C', 'Booking'),
  ),
];

class _GalleryDay extends StatelessWidget {
  const _GalleryDay({required this.state});

  final CalendarDayState<DemoEvent> state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: state.isSelected ? scheme.primary : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${state.date.day}',
              style: TextStyle(
                color: state.isSelected ? scheme.onPrimary : scheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (state.eventCount > 0)
              Text(
                '${state.eventCount} event${state.eventCount == 1 ? '' : 's'}',
                style: TextStyle(
                  color: state.isSelected
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final demoEvents = <CalendarEvent<DemoEvent>>[
  CalendarEvent(
    id: 'launch-plan',
    title: 'Launch planning',
    semanticLabel: 'Launch planning with the product team',
    start: DateTime(2026, 8, 4, 9),
    end: DateTime(2026, 8, 4, 10, 30),
    color: const Color(0xFF6857E5),
    data: const DemoEvent('Maya', 'Product'),
  ),
  CalendarEvent(
    id: 'design-review',
    title: 'Design review',
    start: DateTime(2026, 8, 5, 10),
    end: DateTime(2026, 8, 5, 12),
    color: const Color(0xFFE34B87),
    data: const DemoEvent('Noah', 'Design'),
  ),
  CalendarEvent(
    id: 'customer-call',
    title: 'Customer call',
    start: DateTime(2026, 8, 5, 10, 30),
    end: DateTime(2026, 8, 5, 11, 30),
    color: const Color(0xFF008E87),
    data: const DemoEvent('Lina', 'Research'),
  ),
  CalendarEvent(
    id: 'build-sprint',
    title: 'Build sprint',
    start: DateTime(2026, 8, 6),
    end: DateTime(2026, 8, 8),
    isAllDay: true,
    color: const Color(0xFFF29C38),
    data: const DemoEvent('Core team', 'Engineering'),
  ),
  CalendarEvent(
    id: 'night-deploy',
    title: 'Production deploy',
    start: DateTime(2026, 8, 7, 23),
    end: DateTime(2026, 8, 8, 1),
    color: const Color(0xFF4385F5),
    data: const DemoEvent('Omar', 'Engineering'),
  ),
];
