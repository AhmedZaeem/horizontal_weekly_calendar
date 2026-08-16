import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../configuration/calendar_motion.dart';
import '../controller/horizontal_calendar_controller.dart';

/// Applies the shared calendar page choreography to a keyed surface.
class CalendarPageMotionView extends StatelessWidget {
  /// Creates a transition between chronological calendar pages.
  const CalendarPageMotionView({
    super.key,
    required this.pageKey,
    required this.motion,
    required this.navigationDirection,
    required this.textDirection,
    required this.child,
  });

  /// Stable chronological key for the visible page.
  final int pageKey;

  /// Motion tokens, or `null` for an immediate replacement.
  final CalendarMotion? motion;

  /// Direction of the most recent navigation action.
  final CalendarNavigationDirection? navigationDirection;

  /// Current interface direction used to mirror spatial motion.
  final TextDirection textDirection;

  /// Current calendar page.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = this.motion;
    if (motion == null ||
        motion.pageTransition == CalendarPageTransition.none) {
      return child;
    }
    final chronologicalSign =
        navigationDirection == CalendarNavigationDirection.backward
            ? -1.0
            : 1.0;
    final visualSign = textDirection == TextDirection.rtl
        ? -chronologicalSign
        : chronologicalSign;
    return AnimatedSwitcher(
      duration: motion.effectiveDuration(context),
      reverseDuration: motion.effectiveDuration(context, reverse: true),
      switchInCurve: Curves.linear,
      switchOutCurve: Curves.linear,
      transitionBuilder: (child, animation) {
        final curved = animation.drive(CurveTween(curve: motion.curve));
        final incoming = child.key == ValueKey(pageKey);
        final transitionSign = incoming ? visualSign : -visualSign;
        final transition = switch (motion.pageTransition) {
          CalendarPageTransition.none => child,
          CalendarPageTransition.slide => SlideTransition(
              position: Tween<Offset>(
                begin: Offset(transitionSign * motion.pageOffset, 0),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(opacity: animation, child: child),
            ),
          CalendarPageTransition.fadeThrough => FadeTransition(
              opacity: animation,
              child: child,
            ),
          CalendarPageTransition.scale => ScaleTransition(
              scale: Tween<double>(begin: motion.pageScale, end: 1)
                  .animate(curved),
              child: FadeTransition(opacity: animation, child: child),
            ),
          CalendarPageTransition.sharedAxis => SlideTransition(
              position: Tween<Offset>(
                begin: Offset(transitionSign * motion.pageOffset * .65, 0),
                end: Offset.zero,
              ).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(begin: motion.pageScale, end: 1)
                    .animate(curved),
                child: FadeTransition(opacity: animation, child: child),
              ),
            ),
          CalendarPageTransition.zoom => ScaleTransition(
              scale: Tween<double>(
                begin: incoming ? motion.pageScale : 1 / motion.pageScale,
                end: 1,
              ).animate(curved),
              child: FadeTransition(opacity: animation, child: child),
            ),
          CalendarPageTransition.flip => _CalendarFlipTransition(
              animation: animation,
              curvedAnimation: curved,
              direction: transitionSign,
              perspective: motion.pagePerspective,
              child: child,
            ),
          CalendarPageTransition.parallax => _CalendarSpatialTransition(
              animation: animation,
              curvedAnimation: curved,
              incoming: incoming,
              direction: transitionSign,
              beginOffset:
                  incoming ? motion.pageOffset : motion.pageOffset * .42,
              beginScale:
                  incoming ? motion.pageScale : motion.outgoingPageScale,
              child: child,
            ),
          CalendarPageTransition.coverFlow => _CalendarCoverFlowTransition(
              animation: animation,
              curvedAnimation: curved,
              incoming: incoming,
              direction: transitionSign,
              perspective: motion.pagePerspective,
              rotation: motion.pageRotation,
              beginScale:
                  incoming ? motion.pageScale : motion.outgoingPageScale,
              child: child,
            ),
          CalendarPageTransition.verticalReveal =>
            _CalendarVerticalRevealTransition(
              animation: animation,
              curvedAnimation: curved,
              incoming: incoming,
              direction: transitionSign,
              horizontalOffset: motion.pageOffset,
              beginScale:
                  incoming ? motion.pageScale : motion.outgoingPageScale,
              child: child,
            ),
          CalendarPageTransition.blurThrough => _CalendarBlurThroughTransition(
              animation: animation,
              curvedAnimation: curved,
              incoming: incoming,
              blur: motion.pageBlur,
              beginScale:
                  incoming ? motion.pageScale : motion.outgoingPageScale,
              child: child,
            ),
        };
        // Layered transitions composite blur, perspective, and opacity, so the
        // page gets its own layer instead of repainting the whole surface.
        final isolated = switch (motion.pageTransition) {
          CalendarPageTransition.blurThrough ||
          CalendarPageTransition.coverFlow ||
          CalendarPageTransition.flip ||
          CalendarPageTransition.parallax =>
            RepaintBoundary(child: transition),
          _ => transition,
        };
        return ExcludeSemantics(
          excluding: !incoming,
          child: IgnorePointer(
            ignoring: !incoming,
            child: isolated,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(pageKey), child: child),
    );
  }
}

class _CalendarSpatialTransition extends StatelessWidget {
  const _CalendarSpatialTransition({
    required this.animation,
    required this.curvedAnimation,
    required this.incoming,
    required this.direction,
    required this.beginOffset,
    required this.beginScale,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> curvedAnimation;
  final bool incoming;
  final double direction;
  final double beginOffset;
  final double beginScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: curvedAnimation,
        child: child,
        builder: (context, child) {
          final value = curvedAnimation.value.clamp(0.0, 1.0);
          final offset = direction * beginOffset * (1 - value);
          final scale = beginScale + ((1 - beginScale) * value);
          // Translate by a fraction of the page, not the window: an embedded
          // calendar travels the distance its own surface implies.
          return FractionalTranslation(
            translation: Offset(offset, 0),
            child: Transform.scale(
              scale: scale,
              alignment: incoming ? Alignment.center : Alignment(-direction, 0),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _CalendarCoverFlowTransition extends StatelessWidget {
  const _CalendarCoverFlowTransition({
    required this.animation,
    required this.curvedAnimation,
    required this.incoming,
    required this.direction,
    required this.perspective,
    required this.rotation,
    required this.beginScale,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> curvedAnimation;
  final bool incoming;
  final double direction;
  final double perspective;
  final double rotation;
  final double beginScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: curvedAnimation,
        child: child,
        builder: (context, child) {
          final value = curvedAnimation.value.clamp(0.0, 1.0);
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, perspective)
            ..rotateY(direction * rotation * (1 - value))
            ..scaleByDouble(
              beginScale + ((1 - beginScale) * value),
              beginScale + ((1 - beginScale) * value),
              1,
              1,
            );
          return Transform(
            alignment:
                incoming ? Alignment(-direction, 0) : Alignment(direction, 0),
            transform: matrix,
            child: child,
          );
        },
      ),
    );
  }
}

class _CalendarVerticalRevealTransition extends StatelessWidget {
  const _CalendarVerticalRevealTransition({
    required this.animation,
    required this.curvedAnimation,
    required this.incoming,
    required this.direction,
    required this.horizontalOffset,
    required this.beginScale,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> curvedAnimation;
  final bool incoming;
  final double direction;
  final double horizontalOffset;
  final double beginScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: curvedAnimation,
        child: child,
        builder: (context, child) {
          final value = curvedAnimation.value.clamp(0.0, 1.0);
          final distance = 1 - value;
          final offset = Offset(
            direction * horizontalOffset * .12 * distance,
            (incoming ? .12 : -.08) * distance,
          );
          final scale = beginScale + ((1 - beginScale) * value);
          return FractionalTranslation(
            translation: offset,
            child: Transform.scale(scale: scale, child: child),
          );
        },
      ),
    );
  }
}

class _CalendarBlurThroughTransition extends StatelessWidget {
  const _CalendarBlurThroughTransition({
    required this.animation,
    required this.curvedAnimation,
    required this.incoming,
    required this.blur,
    required this.beginScale,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> curvedAnimation;
  final bool incoming;
  final double blur;
  final double beginScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: curvedAnimation,
        child: child,
        builder: (context, child) {
          final value = curvedAnimation.value.clamp(0.0, 1.0);
          final sigma = blur * (1 - value);
          final scale = beginScale + ((1 - beginScale) * value);
          return ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: Transform.scale(
              scale: scale,
              alignment: incoming ? Alignment.center : Alignment.topCenter,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Infers direction from a monotonically increasing calendar page key.
class ChronologicalCalendarPageMotion extends StatefulWidget {
  /// Creates a transition whose direction follows [pageKey].
  const ChronologicalCalendarPageMotion({
    super.key,
    required this.pageKey,
    required this.motion,
    required this.child,
  });

  /// Stable chronological key for the visible page.
  final int pageKey;

  /// Motion tokens, or `null` for an immediate replacement.
  final CalendarMotion? motion;

  /// Current calendar page.
  final Widget child;

  @override
  State<ChronologicalCalendarPageMotion> createState() =>
      _ChronologicalCalendarPageMotionState();
}

class _ChronologicalCalendarPageMotionState
    extends State<ChronologicalCalendarPageMotion> {
  CalendarNavigationDirection? _direction;

  @override
  void didUpdateWidget(covariant ChronologicalCalendarPageMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageKey == widget.pageKey) return;
    _direction = widget.pageKey > oldWidget.pageKey
        ? CalendarNavigationDirection.forward
        : CalendarNavigationDirection.backward;
  }

  @override
  Widget build(BuildContext context) {
    return CalendarPageMotionView(
      pageKey: widget.pageKey,
      motion: widget.motion,
      navigationDirection: _direction,
      textDirection: Directionality.of(context),
      child: widget.child,
    );
  }
}

class _CalendarFlipTransition extends StatelessWidget {
  const _CalendarFlipTransition({
    required this.animation,
    required this.curvedAnimation,
    required this.direction,
    required this.perspective,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> curvedAnimation;
  final double direction;
  final double perspective;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: curvedAnimation,
        child: child,
        builder: (context, child) {
          final value = curvedAnimation.value.clamp(0.0, 1.0);
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, perspective)
            ..rotateY(direction * (1 - value) * .42);
          return Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: child,
          );
        },
      ),
    );
  }
}
