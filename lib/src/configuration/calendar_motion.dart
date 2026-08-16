import 'package:flutter/widgets.dart';

/// Visual treatment used when a date changes selection state.
enum CalendarSelectionTransition {
  /// Changes state without an animated transform.
  none,

  /// Cross-fades between selected and unselected emphasis.
  fade,

  /// Scales the selected state into place.
  scale,

  /// Moves the selected state upward into place.
  slide,

  /// Uses an elastic scale curve for a pronounced selection response.
  bounce,
}

/// Visual treatment used when the visible date page changes.
enum CalendarPageTransition {
  /// Replaces the page immediately.
  none,

  /// Slides the new page along the horizontal axis.
  slide,

  /// Fades the old page out while the new page fades through it.
  fadeThrough,

  /// Combines a short fade with a subtle scale transition.
  scale,

  /// Moves and scales content along a shared horizontal axis.
  sharedAxis,

  /// Zooms the new page forward from the calendar surface.
  zoom,

  /// Rotates pages around the vertical axis with subtle perspective.
  flip,

  /// Lets the outgoing page trail the incoming page to preserve direction.
  parallax,

  /// Rotates and scales pages through a shallow spatial carousel.
  coverFlow,

  /// Reveals the new page vertically while retaining horizontal continuity.
  verticalReveal,

  /// Softens and scales pages as they cross through the calendar surface.
  blurThrough,
}

/// Visual treatment used when event indicators change.
enum CalendarEventTransition {
  /// Replaces event indicators immediately.
  none,

  /// Cross-fades event indicators.
  fade,

  /// Fades and scales event indicators.
  scale,
}

/// Visual treatment used by foldable calendar state changes.
enum CalendarFoldTransition {
  /// Changes fold state immediately.
  none,

  /// Animates the calendar's height only.
  resize,

  /// Animates height and cross-fades week/month content.
  fade,

  /// Animates height, opacity, and a subtle content scale.
  scale,
}

/// Complete, reusable motion choreography for calendar surfaces.
@immutable
class CalendarMotion {
  /// Creates a custom motion configuration.
  CalendarMotion({
    this.selectionTransition = CalendarSelectionTransition.scale,
    this.pageTransition = CalendarPageTransition.slide,
    this.eventTransition = CalendarEventTransition.fade,
    this.foldTransition = CalendarFoldTransition.resize,
    this.duration = const Duration(milliseconds: 220),
    this.reverseDuration = const Duration(milliseconds: 180),
    this.stagger = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    this.hoverScale = 1.02,
    this.pressScale = .97,
    this.pageOffset = .18,
    this.pageScale = .96,
    this.pagePerspective = .0012,
    this.pageRotation = .14,
    this.pageBlur = 8,
    this.outgoingPageScale = .94,
    this.followGestures = true,
    this.spring,
  })  : assert(duration.inMicroseconds >= 0),
        assert(reverseDuration.inMicroseconds >= 0),
        assert(stagger.inMicroseconds >= 0),
        assert(hoverScale >= 1),
        assert(pressScale > 0 && pressScale <= 1),
        assert(pageOffset >= 0 && pageOffset <= 1),
        assert(pageScale > 0 && pageScale <= 1),
        assert(pagePerspective.isFinite &&
            pagePerspective >= 0 &&
            pagePerspective <= .01),
        assert(
            pageRotation.isFinite && pageRotation >= 0 && pageRotation <= .5),
        assert(pageBlur.isFinite && pageBlur >= 0 && pageBlur <= 20),
        assert(outgoingPageScale.isFinite &&
            outgoingPageScale >= .5 &&
            outgoingPageScale <= 1.1);

  /// Immediate motion preset for reduced or deliberately static interfaces.
  factory CalendarMotion.none() => CalendarMotion(
        selectionTransition: CalendarSelectionTransition.none,
        pageTransition: CalendarPageTransition.none,
        eventTransition: CalendarEventTransition.none,
        foldTransition: CalendarFoldTransition.none,
        duration: Duration.zero,
        reverseDuration: Duration.zero,
        hoverScale: 1,
        pressScale: 1,
        pageOffset: 0,
        pageScale: 1,
        pagePerspective: 0,
        pageRotation: 0,
        pageBlur: 0,
        outgoingPageScale: 1,
        followGestures: false,
      );

  /// Restrained motion suitable for dense productivity interfaces.
  factory CalendarMotion.subtle() => CalendarMotion(
        selectionTransition: CalendarSelectionTransition.fade,
        pageTransition: CalendarPageTransition.fadeThrough,
        eventTransition: CalendarEventTransition.fade,
        foldTransition: CalendarFoldTransition.resize,
        duration: Duration(milliseconds: 160),
        reverseDuration: Duration(milliseconds: 120),
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
        hoverScale: 1.01,
      );

  /// Smooth motion preset with balanced spatial continuity.
  factory CalendarMotion.fluid() => CalendarMotion(
        selectionTransition: CalendarSelectionTransition.slide,
        pageTransition: CalendarPageTransition.slide,
        eventTransition: CalendarEventTransition.scale,
        foldTransition: CalendarFoldTransition.fade,
        duration: Duration(milliseconds: 280),
        reverseDuration: Duration(milliseconds: 220),
        stagger: Duration(milliseconds: 18),
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
        hoverScale: 1.025,
      );

  /// Responsive spring-like motion suited to native mobile interactions.
  factory CalendarMotion.spring() => CalendarMotion(
        selectionTransition: CalendarSelectionTransition.bounce,
        pageTransition: CalendarPageTransition.scale,
        eventTransition: CalendarEventTransition.scale,
        foldTransition: CalendarFoldTransition.scale,
        duration: Duration(milliseconds: 360),
        reverseDuration: Duration(milliseconds: 260),
        stagger: Duration(milliseconds: 22),
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
        hoverScale: 1.035,
      );

  /// Expressive motion preset for consumer, wellness, and social products.
  factory CalendarMotion.playful() => CalendarMotion(
        selectionTransition: CalendarSelectionTransition.bounce,
        pageTransition: CalendarPageTransition.slide,
        eventTransition: CalendarEventTransition.scale,
        foldTransition: CalendarFoldTransition.scale,
        duration: Duration(milliseconds: 440),
        reverseDuration: Duration(milliseconds: 280),
        stagger: Duration(milliseconds: 32),
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInBack,
        hoverScale: 1.05,
      );

  /// Fast, crisp motion for dense tools and high-frequency navigation.
  factory CalendarMotion.snappy() => CalendarMotion(
        selectionTransition: CalendarSelectionTransition.scale,
        pageTransition: CalendarPageTransition.sharedAxis,
        eventTransition: CalendarEventTransition.fade,
        foldTransition: CalendarFoldTransition.resize,
        duration: const Duration(milliseconds: 180),
        reverseDuration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        pageOffset: .12,
        pageScale: .975,
        outgoingPageScale: .97,
      );

  /// Unhurried motion for wellness, journaling, and reading experiences.
  factory CalendarMotion.gentle() => CalendarMotion(
        selectionTransition: CalendarSelectionTransition.fade,
        pageTransition: CalendarPageTransition.verticalReveal,
        eventTransition: CalendarEventTransition.fade,
        foldTransition: CalendarFoldTransition.fade,
        duration: const Duration(milliseconds: 340),
        reverseDuration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubicEmphasized,
        reverseCurve: Curves.easeInOutCubic,
        pageOffset: .1,
        pageScale: .98,
        outgoingPageScale: .985,
      );

  /// Layered directional motion intended for hero calendar surfaces.
  factory CalendarMotion.cinematic() => CalendarMotion(
        selectionTransition: CalendarSelectionTransition.slide,
        pageTransition: CalendarPageTransition.parallax,
        eventTransition: CalendarEventTransition.scale,
        foldTransition: CalendarFoldTransition.scale,
        duration: const Duration(milliseconds: 520),
        reverseDuration: const Duration(milliseconds: 400),
        stagger: const Duration(milliseconds: 28),
        curve: Curves.easeInOutCubicEmphasized,
        reverseCurve: Curves.easeInOutCubic,
        pageOffset: .28,
        pageScale: .96,
        outgoingPageScale: .91,
      );

  /// Refined depth motion for polished consumer and premium interfaces.
  factory CalendarMotion.premium() => CalendarMotion(
        selectionTransition: CalendarSelectionTransition.scale,
        pageTransition: CalendarPageTransition.coverFlow,
        eventTransition: CalendarEventTransition.scale,
        foldTransition: CalendarFoldTransition.scale,
        duration: const Duration(milliseconds: 430),
        reverseDuration: const Duration(milliseconds: 340),
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInOutCubic,
        hoverScale: 1.025,
        pageOffset: .2,
        pageScale: .94,
        pagePerspective: .0015,
        pageRotation: .18,
        pageBlur: 5,
        outgoingPageScale: .9,
      );

  /// Selection-state transition.
  final CalendarSelectionTransition selectionTransition;

  /// Visible-page transition.
  final CalendarPageTransition pageTransition;

  /// Event-indicator transition.
  final CalendarEventTransition eventTransition;

  /// Foldable week/month transition.
  final CalendarFoldTransition foldTransition;

  /// Forward transition duration.
  final Duration duration;

  /// Reverse or deselection transition duration.
  final Duration reverseDuration;

  /// Optional delay increment used by indexed content.
  final Duration stagger;

  /// Forward transition curve.
  final Curve curve;

  /// Reverse or deselection transition curve.
  final Curve reverseCurve;

  /// Pointer-hover scale applied to enabled interactive dates.
  final double hoverScale;

  /// Scale applied while an enabled interactive date is held down.
  ///
  /// Values below `1` give the surface tactile press feedback that settles
  /// back with [spring] as soon as the pointer is released.
  final double pressScale;

  /// Fractional horizontal offset used by spatial page transitions.
  final double pageOffset;

  /// Initial incoming scale used by scale, zoom, and shared-axis transitions.
  final double pageScale;

  /// Perspective entry used by flip transitions.
  final double pagePerspective;

  /// Maximum page rotation, in radians, for depth-based transitions.
  final double pageRotation;

  /// Maximum Gaussian blur radius used by blur-through transitions.
  final double pageBlur;

  /// Scale applied to an outgoing page in layered transitions.
  final double outgoingPageScale;

  /// Whether horizontal and vertical drags move the surface under the pointer.
  ///
  /// When enabled, pages and folds track the gesture continuously and settle
  /// with [settleSpring] on release instead of snapping after a threshold.
  final bool followGestures;

  /// Optional spring used when a gesture-driven surface settles.
  ///
  /// A `null` spring derives a critically damped description from [duration],
  /// which keeps settle timing consistent with the rest of the choreography.
  final SpringDescription? spring;

  /// Spring used to settle gesture-driven surfaces.
  SpringDescription get settleSpring {
    final custom = spring;
    if (custom != null) return custom;
    final seconds = duration.inMicroseconds <= 0
        ? .24
        : duration.inMicroseconds / Duration.microsecondsPerSecond;
    // Slightly under-damped so a released drag settles quickly without the
    // dead-feeling tail of a fully critically damped spring.
    return SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: 2.6 / (seconds * seconds) * 100,
      ratio: .9,
    );
  }

  /// Whether the ambient media allows animated transitions at all.
  bool isEnabled(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return false;
    return duration > Duration.zero || reverseDuration > Duration.zero;
  }

  /// Returns [Duration.zero] when the current media disables animation.
  Duration effectiveDuration(BuildContext context, {bool reverse = false}) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return Duration.zero;
    }
    return reverse ? reverseDuration : duration;
  }

  /// Returns a copy with supplied values replaced.
  CalendarMotion copyWith({
    CalendarSelectionTransition? selectionTransition,
    CalendarPageTransition? pageTransition,
    CalendarEventTransition? eventTransition,
    CalendarFoldTransition? foldTransition,
    Duration? duration,
    Duration? reverseDuration,
    Duration? stagger,
    Curve? curve,
    Curve? reverseCurve,
    double? hoverScale,
    double? pressScale,
    double? pageOffset,
    double? pageScale,
    double? pagePerspective,
    double? pageRotation,
    double? pageBlur,
    double? outgoingPageScale,
    bool? followGestures,
    SpringDescription? spring,
  }) {
    return CalendarMotion(
      selectionTransition: selectionTransition ?? this.selectionTransition,
      pageTransition: pageTransition ?? this.pageTransition,
      eventTransition: eventTransition ?? this.eventTransition,
      foldTransition: foldTransition ?? this.foldTransition,
      duration: duration ?? this.duration,
      reverseDuration: reverseDuration ?? this.reverseDuration,
      stagger: stagger ?? this.stagger,
      curve: curve ?? this.curve,
      reverseCurve: reverseCurve ?? this.reverseCurve,
      hoverScale: hoverScale ?? this.hoverScale,
      pressScale: pressScale ?? this.pressScale,
      pageOffset: pageOffset ?? this.pageOffset,
      pageScale: pageScale ?? this.pageScale,
      pagePerspective: pagePerspective ?? this.pagePerspective,
      pageRotation: pageRotation ?? this.pageRotation,
      pageBlur: pageBlur ?? this.pageBlur,
      outgoingPageScale: outgoingPageScale ?? this.outgoingPageScale,
      followGestures: followGestures ?? this.followGestures,
      spring: spring ?? this.spring,
    );
  }
}
