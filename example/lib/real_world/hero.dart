import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

import 'brand.dart';
import 'data.dart';

const Color _ink = Color(0xFF070A16);
const Color _violet = Color(0xFF7C6BFF);
const Color _cyan = Color(0xFF4FD1E0);

/// Poster used to render the README banner.
///
/// Every panel is a real calendar widget rather than a drawing, so the banner
/// cannot drift away from what the package actually produces.
class HeroPosterPage extends StatefulWidget {
  const HeroPosterPage({super.key});

  /// Logical size of the rendered banner.
  static const Size canvas = Size(1376, 762);

  @override
  State<HeroPosterPage> createState() => _HeroPosterPageState();
}

class _HeroPosterPageState extends State<HeroPosterPage> {
  @override
  void initState() {
    super.initState();
    // Capture-only route: hide the system chrome so the banner is clean.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _violet,
        brightness: Brightness.dark,
      ),
    );
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: _ink,
        // The banner is a fixed landscape canvas. Rendering it quarter-turned
        // lets a portrait device capture it at full resolution; the captured
        // PNG is rotated back by the capture step.
        body: Center(
          child: FittedBox(
            child: RotatedBox(
              quarterTurns: 1,
              child: SizedBox(
                width: HeroPosterPage.canvas.width,
                height: HeroPosterPage.canvas.height,
                child: const _Poster(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF141737), _ink, Color(0xFF07131F)],
          stops: [0, .55, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(left: -170, top: -150, child: _Glow(_violet)),
          const Positioned(right: -190, bottom: -170, child: _Glow(_cyan)),
          Padding(
            padding: const EdgeInsets.fromLTRB(60, 52, 60, 52),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                // Scaled rather than clipped, so different font metrics
                // shrink the masthead instead of overflowing the canvas.
                SizedBox(
                  width: 496,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(width: 496, child: _Masthead()),
                  ),
                ),
                SizedBox(width: 44),
                Expanded(child: _Panels()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 560,
      height: 560,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: .32), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CalendarBrandMark(
                size: 58, accent: _violet, highlight: _cyan),
            const SizedBox(width: 15),
            const Expanded(
              child: Text(
                'FLUTTER CALENDAR UI KIT',
                maxLines: 1,
                style: TextStyle(
                  color: Color(0xFF9FB0D8),
                  fontSize: 14,
                  letterSpacing: 2.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Every calendar\nyour product needs.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 50,
            height: 1.1,
            letterSpacing: -1.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'One date engine behind week strips, month grids, carousels, '
          'agendas, timelines, native pickers, and home-screen widgets.',
          style: TextStyle(
            color: Color(0xFFB4C2E2),
            fontSize: 17.5,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .38),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withValues(alpha: .12)),
          ),
          child: const Text(
            'horizontal_weekly_calendar',
            style: TextStyle(
              color: Color(0xFF8FE6F0),
              fontSize: 17,
              fontFamily: 'Menlo',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            _Chip('21 visual styles'),
            _Chip('Gesture-driven motion'),
            _Chip('Material + Cupertino'),
            _Chip('Bullet-proof dates'),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: .14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFD6E0F5),
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The right-hand composition of real calendar surfaces.
class _Panels extends StatelessWidget {
  const _Panels();

  static final DateTime _selected = DateTime(2026, 8, 12);

  @override
  Widget build(BuildContext context) {
    // Explicit geometry throughout: several surfaces build through
    // LayoutBuilder and cannot answer intrinsic-size questions.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 168,
          child: _Panel(
            label: 'HorizontalCalendar',
            child: HorizontalCalendar<Booking>(
              selectedDate: _selected,
              onDateSelected: (_) {},
              events: workoutEvents,
              appearance: CalendarAppearance(
                style: CalendarStyle.midnight,
                showHeader: false,
                showSurface: false,
                motion: CalendarMotion.fluid(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 412,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 55,
                child: _Panel(
                  label: 'MonthCalendar',
                  child: MonthCalendar<Booking>.single(
                    month: DateTime(2026, 8),
                    selectedDate: _selected,
                    onDateSelected: (_) {},
                    events: workoutEvents,
                    appearance: const CalendarAppearance(
                      style: CalendarStyle.midnight,
                      density: CalendarDensity.compact,
                      showHeader: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 232,
                      child: _Panel(
                        label: 'CalendarHomeWidget',
                        child: CalendarHomeWidget(
                          data: heroWidgetData,
                          family: CalendarHomeWidgetFamily.medium,
                          content: CalendarHomeWidgetContent.agenda,
                          theme: heroWidgetTheme,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: _Panel(
                        label: 'CalendarStreakStrip',
                        child: CalendarStreakStrip(
                          startDate: DateTime(2026, 8, 9),
                          dayCount: 4,
                          today: _selected,
                          selectedDate: _selected,
                          completedDates: habitCompletedDates,
                          appearance: const CalendarAppearance(
                            style: CalendarStyle.neon,
                            showHeader: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .45),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 11, 15, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8FA0C6),
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
