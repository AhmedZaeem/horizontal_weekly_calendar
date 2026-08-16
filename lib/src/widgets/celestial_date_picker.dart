import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../configuration/calendar_configuration.dart';
import '../domain/calendar_date_math.dart';
import '../models/calendar_selection.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';

/// Atmospheric palette used by the built-in celestial painter.
enum CelestialSkyStyle {
  /// Warm early-morning light.
  dawn,

  /// Bright clear daytime color.
  day,

  /// Warm evening color fading into night.
  dusk,

  /// Deep night with pronounced stars.
  midnight,

  /// Violet, indigo, and teal atmospheric bands.
  aurora,

  /// Restrained grayscale treatment.
  monochrome,
}

/// Overall horizon composition layered over a [CelestialSkyStyle].
enum CelestialComposition {
  /// Soft atmosphere with quiet depth.
  serene,

  /// Visible orbital geometry and celestial trails.
  orbital,

  /// Low-detail treatment for compact application surfaces.
  minimal,

  /// Rich layered atmosphere suited to showcase experiences.
  cinematic,
}

/// Motion choreography for sun, moon, stars, and horizon layers.
@immutable
class CelestialMotion {
  /// Creates celestial motion tokens.
  const CelestialMotion({
    this.duration = const Duration(milliseconds: 720),
    this.curve = Curves.easeInOutCubicEmphasized,
    this.arcHeight = .62,
    this.drift = .18,
    this.parallax = .22,
    this.rotation = .2,
    this.trailLength = .4,
    this.starTwinkle = .45,
  })  : assert(arcHeight >= 0 && arcHeight <= 1),
        assert(drift >= 0 && drift <= 1),
        assert(parallax >= 0 && parallax <= 1),
        assert(rotation >= 0 && rotation <= math.pi * 2),
        assert(trailLength >= 0 && trailLength <= 1),
        assert(starTwinkle >= 0 && starTwinkle <= 1);

  /// Duration of a controlled-date transition.
  final Duration duration;

  /// Timing curve for the shared celestial path.
  final Curve curve;

  /// Vertical amplitude of the sun path.
  final double arcHeight;

  /// Horizontal atmospheric drift applied during a transition.
  final double drift;

  /// Relative movement of distant sky layers.
  final double parallax;

  /// Maximum decorative body rotation in radians.
  final double rotation;

  /// Length and opacity of sun and moon motion trails.
  final double trailLength;

  /// Strength of deterministic star pulsing.
  final double starTwinkle;
}

/// Immutable visual state supplied by [CelestialDatePicker].
@immutable
class CelestialPickerState {
  /// Creates celestial state for one controlled date.
  const CelestialPickerState({
    required this.date,
    required this.dayProgress,
    required this.monthProgress,
    required this.moonPhase,
    required this.isSelectable,
    required this.semanticLabel,
    this.previousDate,
    this.visualProgress,
    this.transitionProgress = 1,
  });

  /// Normalized controlled civil date.
  final DateTime date;

  /// Expressive position of the sun across the horizon, from zero through one.
  final double dayProgress;

  /// Progress through the current month, from zero through one.
  final double monthProgress;

  /// Approximate visual lunar phase, from zero through one.
  final double moonPhase;

  /// Whether the date passes bounds and the enabled-day predicate.
  final bool isSelectable;

  /// Localized accessibility description.
  final String semanticLabel;

  /// Previous controlled date while a transition is running.
  final DateTime? previousDate;

  /// Continuous, unwrapped position used by the built-in orbital paths.
  final double? visualProgress;

  /// Progress through the current retargetable transition.
  final double transitionProgress;
}

/// Builds a custom celestial sky while retaining picker interaction.
typedef CelestialSkyBuilder = Widget Function(
  BuildContext context,
  CelestialPickerState state,
);

/// Presentation configuration for [CelestialDatePicker].
@immutable
class CelestialDatePickerStyle {
  /// Creates celestial picker presentation.
  const CelestialDatePickerStyle({
    this.skyHeight = 190,
    this.horizonPadding = 22,
    this.sunColor = const Color(0xFFFFC857),
    this.moonColor = const Color(0xFFE8EEFF),
    this.daySkyColor = const Color(0xFF77C7FF),
    this.nightSkyColor = const Color(0xFF101A3D),
    this.horizonColor = const Color(0xFF234E52),
    this.starColor = const Color(0xCCFFFFFF),
    this.showMonthControls = true,
    this.showPhaseLabel = true,
    this.skyStyle = CelestialSkyStyle.midnight,
    this.compact = false,
    this.showClouds = false,
    this.showConstellations = false,
    this.showPhaseOrbit = false,
    this.showHorizonGlow = true,
    this.showDateProgress = false,
    this.composition = CelestialComposition.serene,
    this.showDateCapsule = true,
  })  : assert(skyHeight >= 140),
        assert(horizonPadding >= 0);

  /// Height of the painted horizon.
  final double skyHeight;

  /// Horizontal inset used by the celestial path.
  final double horizonPadding;

  /// Sun fill color.
  final Color sunColor;

  /// Moon fill color.
  final Color moonColor;

  /// Bright sky color.
  final Color daySkyColor;

  /// Dark sky color.
  final Color nightSkyColor;

  /// Horizon and landscape color.
  final Color horizonColor;

  /// Decorative star color.
  final Color starColor;

  /// Whether month navigation controls are visible.
  final bool showMonthControls;

  /// Whether the approximate visual phase label is visible.
  final bool showPhaseLabel;

  /// Built-in atmospheric palette.
  final CelestialSkyStyle skyStyle;

  /// Whether controls and typography use compact geometry.
  final bool compact;

  /// Whether soft parallax cloud forms are painted.
  final bool showClouds;

  /// Whether deterministic constellation links are painted.
  final bool showConstellations;

  /// Whether the moon's path is outlined.
  final bool showPhaseOrbit;

  /// Whether a soft glow is painted above the horizon.
  final bool showHorizonGlow;

  /// Whether an accessible date-cycle progress rail is painted.
  final bool showDateProgress;

  /// Layer density and celestial geometry.
  final CelestialComposition composition;

  /// Whether the sky includes a floating civil-date capsule.
  final bool showDateCapsule;
}

/// Original horizon-based date scrubber with expressive sun and moon feedback.
///
/// Celestial positions are decorative date-derived values. The widget does not
/// calculate location-aware sunrise, sunset, moonrise, or astronomical events.
class CelestialDatePicker extends StatefulWidget {
  /// Creates a controlled celestial date picker.
  const CelestialDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.bounds,
    this.selectableDayPredicate,
    this.appearance = const CalendarAppearance(
      style: CalendarStyle.midnight,
      showHeader: false,
    ),
    this.style = const CelestialDatePickerStyle(),
    this.celestialMotion = const CelestialMotion(),
    this.skyBuilder,
    this.previousLabel = 'Previous day',
    this.nextLabel = 'Next day',
  });

  /// Controlled selected civil date.
  final DateTime value;

  /// Reports one accepted normalized date.
  final ValueChanged<DateTime> onChanged;

  /// Optional inclusive bounds.
  final CalendarDateRange? bounds;

  /// Optional enabled-day rule.
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Shared theme and motion configuration.
  final CalendarAppearance appearance;

  /// Celestial-specific visual configuration.
  final CelestialDatePickerStyle style;

  /// Sun, moon, and atmospheric motion choreography.
  final CelestialMotion celestialMotion;

  /// Optional complete sky replacement.
  final CelestialSkyBuilder? skyBuilder;

  /// Accessibility label for previous-day control.
  final String previousLabel;

  /// Accessibility label for next-day control.
  final String nextLabel;

  @override
  State<CelestialDatePicker> createState() => _CelestialDatePickerState();
}

class _CelestialDatePickerState extends State<CelestialDatePicker>
    with SingleTickerProviderStateMixin {
  double _dragDistance = 0;
  late final AnimationController _celestialController;
  late double _fromVisualProgress;
  late double _toVisualProgress;
  DateTime? _previousDate;

  DateTime get _date => CalendarDateMath.dateOnly(widget.value);

  @override
  void initState() {
    super.initState();
    _fromVisualProgress = _dateProgress(_date);
    _toVisualProgress = _fromVisualProgress;
    _celestialController = AnimationController(
      vsync: this,
      duration: widget.celestialMotion.duration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant CelestialDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _celestialController.duration = widget.celestialMotion.duration;
    final oldDate = CalendarDateMath.dateOnly(oldWidget.value);
    if (CalendarDateMath.isSameDay(oldDate, _date)) return;

    final current = _currentVisualProgress(oldWidget.celestialMotion.curve);
    final delta = CalendarDateMath.civilDayDifference(oldDate, _date);
    final monthLength = DateTime(_date.year, _date.month + 1, 0).day;
    _previousDate = oldDate;
    _fromVisualProgress = current;
    _toVisualProgress += delta / math.max(1, monthLength);

    if (MediaQuery.disableAnimationsOf(context) ||
        widget.celestialMotion.duration == Duration.zero) {
      _celestialController.value = 1;
    } else {
      _celestialController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _celestialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, widget.appearance);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    if (MediaQuery.disableAnimationsOf(context) &&
        _celestialController.value != 1) {
      _celestialController.value = 1;
    }
    final state = _stateFor(_date, locale);

    return Material(
      color: Colors.transparent,
      child: Focus(
        onKeyEvent: _handleKey,
        child: Semantics(
          container: true,
          label: state.semanticLabel,
          value: DateFormat.yMMMMEEEEd(locale).format(state.date),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(theme.surfaceBorderRadius),
              border: Border.all(color: theme.borderColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(theme.contentPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _header(context, state, theme, locale),
                  const SizedBox(height: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (_) => _dragDistance = 0,
                    onHorizontalDragUpdate: (details) {
                      _dragDistance += details.primaryDelta ?? 0;
                    },
                    onHorizontalDragEnd: (_) => _finishDrag(context),
                    child: AnimatedBuilder(
                      animation: _celestialController,
                      builder: (context, _) {
                        final progress =
                            _celestialController.value.clamp(0.0, 1.0);
                        final visual = _currentVisualProgress(
                          widget.celestialMotion.curve,
                        );
                        final animatedState = _stateFor(
                          _date,
                          locale,
                          visualProgress: visual,
                          transitionProgress: progress,
                          previousDate: _previousDate,
                        );
                        return widget.skyBuilder?.call(
                              context,
                              animatedState,
                            ) ??
                            ClipRRect(
                              key: const ValueKey('celestial-sky-viewport'),
                              borderRadius: BorderRadius.circular(
                                math.min(theme.dayBorderRadius, 28),
                              ),
                              child: Stack(
                                clipBehavior: Clip.hardEdge,
                                alignment: Alignment.bottomCenter,
                                children: [
                                  CustomPaint(
                                    painter: _CelestialSkyPainter(
                                      state: animatedState,
                                      style: widget.style,
                                      motion: widget.celestialMotion,
                                      theme: theme,
                                    ),
                                    child: SizedBox(
                                      height: widget.style.skyHeight,
                                      width: double.infinity,
                                    ),
                                  ),
                                  if (widget.style.showDateCapsule)
                                    Positioned(
                                      bottom: widget.style.showDateProgress
                                          ? 22
                                          : 12,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: theme.backgroundColor
                                              .withValues(alpha: .82),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                          border: Border.all(
                                            color: theme.borderColor
                                                .withValues(alpha: .72),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            DateFormat.MMMd(locale)
                                                .format(animatedState.date),
                                            style:
                                                theme.eventTextStyle.copyWith(
                                              color: theme.textColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _dayControls(theme),
                  if (widget.style.showPhaseLabel) ...[
                    const SizedBox(height: 6),
                    Text(
                      _phaseLabel(state.moonPhase),
                      style: theme.eventTextStyle.copyWith(
                        color: theme.mutedTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    CelestialPickerState state,
    HorizontalCalendarThemeData theme,
    String? locale,
  ) {
    final title = Text(
      widget.style.compact
          ? DateFormat.yMMMd(locale).format(state.date)
          : DateFormat.yMMMMEEEEd(locale).format(state.date),
      textAlign: TextAlign.center,
      style: theme.headerTextStyle.copyWith(color: theme.textColor),
    );
    if (!widget.style.showMonthControls) return title;
    return Row(
      children: [
        IconButton(
          key: const ValueKey('celestial-previous-month'),
          tooltip: 'Previous month',
          onPressed: () => _propose(
              DateTime(
                _date.year,
                _date.month - 1,
                math.min(_date.day, DateTime(_date.year, _date.month, 0).day),
              ),
              -1),
          icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
        ),
        Expanded(child: title),
        IconButton(
          key: const ValueKey('celestial-next-month'),
          tooltip: 'Next month',
          onPressed: () {
            final targetMonth = DateTime(_date.year, _date.month + 1);
            final lastDay =
                DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
            _propose(
              DateTime(targetMonth.year, targetMonth.month,
                  math.min(_date.day, lastDay)),
              1,
            );
          },
          icon: const Icon(Icons.keyboard_double_arrow_right_rounded),
        ),
      ],
    );
  }

  Widget _dayControls(HorizontalCalendarThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          key: const ValueKey('celestial-previous-day'),
          tooltip: widget.previousLabel,
          onPressed: () => _step(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        SizedBox(width: widget.style.compact ? 8 : 16),
        Text(
          '${_date.day}',
          style: theme.headerTextStyle.copyWith(
            color: theme.textColor,
            fontSize: widget.style.compact ? 24 : 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(width: widget.style.compact ? 8 : 16),
        IconButton.filledTonal(
          key: const ValueKey('celestial-next-day'),
          tooltip: widget.nextLabel,
          onPressed: () => _step(1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _step(Directionality.of(context) == TextDirection.rtl ? 1 : -1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _step(Directionality.of(context) == TextDirection.rtl ? -1 : 1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _propose(DateTime(_date.year, _date.month - 1, _date.day), -1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _propose(DateTime(_date.year, _date.month + 1, _date.day), 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _finishDrag(BuildContext context) {
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final steps = (-_dragDistance / 34).round() * direction;
    _dragDistance = 0;
    if (steps != 0) {
      _propose(CalendarDateMath.addDays(_date, steps), steps.sign);
    }
  }

  void _step(int direction) {
    _propose(CalendarDateMath.addDays(_date, direction), direction);
  }

  void _propose(DateTime target, int direction) {
    final resolved = _nearestSelectable(target, direction);
    if (resolved == null || CalendarDateMath.isSameDay(resolved, _date)) return;
    widget.onChanged(resolved);
  }

  DateTime? _nearestSelectable(DateTime target, int direction) {
    var candidate = CalendarDateMath.dateOnly(target);
    final bounds = widget.bounds;
    if (bounds != null) {
      candidate = CalendarDateMath.clamp(candidate, bounds.start, bounds.end);
    }
    if (_isSelectable(candidate)) return candidate;
    final step = direction == 0 ? 1 : direction.sign;
    for (var index = 0; index < 3660; index += 1) {
      candidate = CalendarDateMath.addDays(candidate, step);
      if (bounds != null && !bounds.contains(candidate)) return null;
      if (_isSelectable(candidate)) return candidate;
    }
    return null;
  }

  bool _isSelectable(DateTime date) {
    if (widget.bounds != null && !widget.bounds!.contains(date)) return false;
    return widget.selectableDayPredicate?.call(date) ?? true;
  }

  double _currentVisualProgress(Curve curve) {
    final raw = _celestialController.value.clamp(0.0, 1.0);
    final curved = curve.transform(raw).clamp(0.0, 1.0);
    return _fromVisualProgress +
        ((_toVisualProgress - _fromVisualProgress) * curved);
  }

  double _dateProgress(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    return lastDay == 1 ? 0 : (date.day - 1) / (lastDay - 1);
  }

  CelestialPickerState _stateFor(
    DateTime date,
    String? locale, {
    double? visualProgress,
    double transitionProgress = 1,
    DateTime? previousDate,
  }) {
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    final monthProgress = lastDay == 1 ? 0.0 : (date.day - 1) / (lastDay - 1);
    final animatedProgress = visualProgress == null
        ? monthProgress
        : visualProgress - visualProgress.floorToDouble();
    final ordinal = CalendarDateMath.civilDayDifference(
      DateTime(2000, 1, 6),
      date,
    );
    final moonPhase = (ordinal % 29.530588853) / 29.530588853;
    final phase = moonPhase < 0 ? moonPhase + 1 : moonPhase;
    return CelestialPickerState(
      date: date,
      dayProgress: animatedProgress,
      monthProgress: animatedProgress,
      moonPhase: phase,
      isSelectable: _isSelectable(date),
      semanticLabel:
          '${DateFormat.yMMMMEEEEd(locale).format(date)}, ${_phaseLabel(phase)}',
      previousDate: previousDate,
      visualProgress: visualProgress,
      transitionProgress: transitionProgress,
    );
  }
}

class _CelestialSkyPainter extends CustomPainter {
  const _CelestialSkyPainter({
    required this.state,
    required this.style,
    required this.motion,
    required this.theme,
  });

  final CelestialPickerState state;
  final CelestialDatePickerStyle style;
  final CelestialMotion motion;
  final HorizontalCalendarThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(math.min(theme.dayBorderRadius, 28));
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(rect, radius));
    final skyColors = _skyColors(style);
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: skyColors,
        stops: List<double>.generate(
          skyColors.length,
          (index) => index / (skyColors.length - 1),
        ),
      ).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), sky);

    final rawProgress = state.visualProgress ?? state.monthProgress;
    final twinkle =
        .65 + math.sin(rawProgress * math.pi * 8) * .35 * motion.starTwinkle;
    final starPaint = Paint()
      ..color = style.starColor.withValues(
        alpha: (style.starColor.a * twinkle).clamp(0.0, 1.0),
      );
    final starPoints = <Offset>[];
    final starCount = switch (style.composition) {
      CelestialComposition.minimal => 5,
      CelestialComposition.serene => 14,
      CelestialComposition.orbital => 18,
      CelestialComposition.cinematic => 26,
    };
    for (var index = 0; index < starCount; index += 1) {
      final x = ((index * 67 + state.date.day * 13) % 100) / 100 * size.width;
      final y = ((index * 41 + state.date.month * 17) % 55) / 100 * size.height;
      final point = Offset(x, y);
      starPoints.add(point);
      canvas.drawCircle(point, index.isEven ? 1.4 : .8, starPaint);
    }
    if (style.showConstellations) {
      final constellation = Paint()
        ..color = style.starColor.withValues(alpha: .22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8;
      final maximumLink = size.width * .24;
      for (var index = 1; index < starPoints.length; index += 1) {
        if (index % 4 == 0) continue;
        final first = starPoints[index - 1];
        final second = starPoints[index];
        if ((second - first).distance <= maximumLink) {
          canvas.drawLine(first, second, constellation);
        }
      }
    }

    final left = style.horizonPadding;
    final width =
        math.max(1.0, size.width - style.horizonPadding * 2).toDouble();
    final horizonY = size.height * .72;
    final cycle = rawProgress - rawProgress.floorToDouble();
    final angle = cycle * math.pi * 2;
    double wrapped(double progress) => progress - progress.floorToDouble();
    Offset positionFor(double bodyProgress, double amplitude) {
      final progress = wrapped(bodyProgress);
      final drift = math.sin(
            state.transitionProgress * math.pi,
          ) *
          motion.drift *
          size.width *
          .05;
      return Offset(
        left + width * progress + drift,
        horizonY - math.sin(progress * math.pi) * size.height * amplitude,
      );
    }

    final sunProgress = cycle;
    final moonProgress = wrapped(cycle + .5);
    final sunAmplitude = .18 + motion.arcHeight * .32;
    final moonAmplitude = .14 + motion.arcHeight * .25;
    final sun = positionFor(sunProgress, sunAmplitude);
    final moon = positionFor(
      moonProgress,
      moonAmplitude,
    );

    if (style.showPhaseOrbit ||
        style.composition == CelestialComposition.orbital) {
      final orbit = Path();
      for (var index = 0; index <= 48; index += 1) {
        final point = positionFor(index / 48, moonAmplitude);
        if (index == 0) {
          orbit.moveTo(point.dx, point.dy);
        } else {
          orbit.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        orbit,
        Paint()
          ..color = style.moonColor.withValues(alpha: .18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    if (motion.trailLength > 0 &&
        style.composition != CelestialComposition.minimal) {
      for (var index = 5; index >= 1; index -= 1) {
        final distance = index * .045 * motion.trailLength;
        final opacity = (6 - index) / 34 * motion.trailLength;
        final sunTrail = positionFor(sunProgress - distance, sunAmplitude);
        final moonTrail = positionFor(
          moonProgress - distance,
          moonAmplitude,
        );
        canvas.drawCircle(
          sunTrail,
          3 + (5 - index) * .6,
          Paint()..color = style.sunColor.withValues(alpha: opacity),
        );
        canvas.drawCircle(
          moonTrail,
          2.5 + (5 - index) * .45,
          Paint()..color = style.moonColor.withValues(alpha: opacity),
        );
      }
    }

    if (style.showClouds) {
      final cloudPaint = Paint()
        ..color = Colors.white.withValues(alpha: .12 + motion.parallax * .12);
      final cloudShift = math.sin(angle) * size.width * motion.parallax * .08;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * .24 + cloudShift, size.height * .38),
          width: size.width * .28,
          height: 18,
        ),
        cloudPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * .76 - cloudShift, size.height * .48),
          width: size.width * .22,
          height: 14,
        ),
        cloudPaint,
      );
    }

    if (style.composition == CelestialComposition.cinematic) {
      final hazeRect = Rect.fromLTWH(0, horizonY - 70, size.width, 86);
      canvas.drawRect(
        hazeRect,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(
              ((sun.dx / size.width) * 2 - 1).clamp(-1, 1),
              1,
            ),
            radius: 1.1,
            colors: [
              style.sunColor.withValues(alpha: .2),
              Colors.transparent,
            ],
          ).createShader(hazeRect),
      );
    }

    canvas.drawCircle(
      sun,
      17,
      Paint()
        ..color = style.sunColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      sun,
      11,
      Paint()..color = style.sunColor,
    );
    final rayPaint = Paint()
      ..color = style.sunColor.withValues(alpha: .48)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final rayRotation =
        angle * motion.rotation + state.transitionProgress * motion.rotation;
    for (var index = 0; index < 8; index += 1) {
      final rayAngle = rayRotation + index / 8 * math.pi * 2;
      canvas.drawLine(
        sun + Offset(math.cos(rayAngle) * 14, math.sin(rayAngle) * 14),
        sun + Offset(math.cos(rayAngle) * 20, math.sin(rayAngle) * 20),
        rayPaint,
      );
    }
    canvas.drawCircle(
      moon,
      10,
      Paint()..color = style.moonColor,
    );
    final phaseDistance = (state.moonPhase - .5) * 12;
    final phaseRotation = angle * motion.rotation;
    canvas.drawCircle(
      moon +
          Offset(
            math.cos(phaseRotation) * phaseDistance,
            math.sin(phaseRotation) * phaseDistance - 1,
          ),
      9,
      Paint()..color = style.nightSkyColor.withValues(alpha: .84),
    );

    if (style.showHorizonGlow) {
      canvas.drawRect(
        Rect.fromLTWH(0, horizonY - 28, size.width, 38),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              style.sunColor.withValues(alpha: 0),
              style.sunColor.withValues(alpha: .16),
            ],
          ).createShader(Rect.fromLTWH(0, horizonY - 28, size.width, 38)),
      );
    }

    final horizon = Path()
      ..moveTo(0, size.height * .74)
      ..quadraticBezierTo(
        size.width * .3,
        size.height * .62,
        size.width * .55,
        size.height * .76,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .88,
        size.width,
        size.height * .7,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(horizon, Paint()..color = style.horizonColor);

    if (style.composition == CelestialComposition.cinematic ||
        style.composition == CelestialComposition.serene) {
      final foreground = Path()
        ..moveTo(0, size.height * .88)
        ..quadraticBezierTo(
          size.width * .3,
          size.height * .8,
          size.width * .62,
          size.height * .92,
        )
        ..quadraticBezierTo(
          size.width * .84,
          size.height,
          size.width,
          size.height * .86,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        foreground,
        Paint()
          ..color = Color.lerp(style.horizonColor, Colors.black, .24)!
              .withValues(alpha: .86),
      );
    }

    if (style.showDateProgress) {
      final progress = state.monthProgress.clamp(0.0, 1.0);
      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - 13, width, 4),
        const Radius.circular(99),
      );
      canvas.drawRRect(
        progressRect,
        Paint()..color = style.starColor.withValues(alpha: .18),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - 13, width * progress, 4),
          const Radius.circular(99),
        ),
        Paint()..color = style.sunColor.withValues(alpha: .82),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CelestialSkyPainter oldDelegate) {
    return oldDelegate.state.date != state.date ||
        oldDelegate.state.visualProgress != state.visualProgress ||
        oldDelegate.state.monthProgress != state.monthProgress ||
        oldDelegate.state.transitionProgress != state.transitionProgress ||
        oldDelegate.style != style ||
        oldDelegate.motion != motion ||
        oldDelegate.theme != theme;
  }
}

List<Color> _skyColors(CelestialDatePickerStyle style) {
  return switch (style.skyStyle) {
    CelestialSkyStyle.dawn => const [
        Color(0xFF332A63),
        Color(0xFFE77978),
        Color(0xFFFFCB8E),
      ],
    CelestialSkyStyle.day => [
        Color.lerp(style.daySkyColor, Colors.white, .14)!,
        style.daySkyColor,
        Color.lerp(style.daySkyColor, const Color(0xFFDCF6FF), .58)!,
      ],
    CelestialSkyStyle.dusk => const [
        Color(0xFF221B52),
        Color(0xFF87508A),
        Color(0xFFFF936B),
      ],
    CelestialSkyStyle.midnight => [
        style.nightSkyColor,
        Color.lerp(style.nightSkyColor, const Color(0xFF314D86), .42)!,
      ],
    CelestialSkyStyle.aurora => const [
        Color(0xFF0A1235),
        Color(0xFF443A91),
        Color(0xFF1C8C88),
      ],
    CelestialSkyStyle.monochrome => const [
        Color(0xFF16181D),
        Color(0xFF4B515C),
        Color(0xFF9AA1AA),
      ],
  };
}

String _phaseLabel(double phase) {
  if (phase < .03 || phase >= .97) return 'New moon visual';
  if (phase < .22) return 'Waxing crescent visual';
  if (phase < .28) return 'First quarter visual';
  if (phase < .47) return 'Waxing moon visual';
  if (phase < .53) return 'Full moon visual';
  if (phase < .72) return 'Waning moon visual';
  if (phase < .78) return 'Last quarter visual';
  return 'Waning crescent visual';
}
