import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../configuration/calendar_motion.dart';

/// Builds content for a continuous state transition.
///
/// [progress] moves smoothly from `0` (inactive) to `1` (active) and can be
/// interrupted at any point without restarting.
typedef CalendarStateTransitionBuilder = Widget Function(
  BuildContext context,
  double progress,
  Widget? child,
);

/// Drives an interruptible `0..1` progress whenever [active] changes.
///
/// Unlike a restart-from-zero animation, an interrupted transition continues
/// from its current position at a constant perceived speed, so rapid taps read
/// as one continuous movement instead of a series of snaps.
class CalendarStateTransition extends StatefulWidget {
  /// Creates a continuous state transition.
  const CalendarStateTransition({
    super.key,
    required this.active,
    required this.motion,
    required this.builder,
    this.index = 0,
    this.child,
  });

  /// Whether the transition is settled at its active end.
  final bool active;

  /// Motion tokens, or `null` for an immediate change.
  final CalendarMotion? motion;

  /// Builds content for the current progress.
  final CalendarStateTransitionBuilder builder;

  /// Stable index used to offset staggered transitions.
  final int index;

  /// Optional subtree that does not depend on progress.
  final Widget? child;

  @override
  State<CalendarStateTransition> createState() =>
      _CalendarStateTransitionState();
}

class _CalendarStateTransitionState extends State<CalendarStateTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.active ? 1 : 0,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void didUpdateWidget(covariant CalendarStateTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.motion != widget.motion) {
      _drive();
    }
  }

  void _drive() {
    final target = widget.active ? 1.0 : 0.0;
    final distance = (target - _controller.value).abs();
    if (distance == 0) return;

    final motion = widget.motion;
    final base = motion?.effectiveDuration(context, reverse: !widget.active) ??
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false
            ? Duration.zero
            : const Duration(milliseconds: 220));
    if (base == Duration.zero) {
      _controller.value = target;
      return;
    }

    // Scale the remaining duration by the remaining distance so an interrupted
    // transition keeps a constant perceived speed instead of slowing down.
    final delay = (motion?.stagger ?? Duration.zero) * widget.index;
    final travel = base * distance;
    final total = travel + delay;
    final delayFraction = total.inMicroseconds == 0
        ? 0.0
        : (delay.inMicroseconds / total.inMicroseconds).clamp(0.0, .9);
    final curve = widget.active
        ? motion?.curve ?? Curves.easeOutCubic
        : motion?.reverseCurve ?? Curves.easeInCubic;

    _controller.animateTo(
      target,
      duration: total,
      curve:
          delayFraction == 0 ? curve : Interval(delayFraction, 1, curve: curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => widget.builder(
        context,
        _controller.value.clamp(0.0, 1.0),
        child,
      ),
    );
  }
}

/// Adds hover and press feedback without taking part in the gesture arena.
///
/// The wrapper only observes pointers, so an ancestor or descendant tap,
/// drag, or ink response keeps working exactly as before.
class CalendarPressable extends StatefulWidget {
  /// Creates a pointer-feedback wrapper.
  const CalendarPressable({
    super.key,
    required this.enabled,
    required this.motion,
    required this.child,
  });

  /// Whether the wrapped surface currently reacts to pointers.
  final bool enabled;

  /// Motion tokens supplying hover scale, press scale, and settle timing.
  final CalendarMotion? motion;

  /// Wrapped content.
  final Widget child;

  @override
  State<CalendarPressable> createState() => _CalendarPressableState();
}

class _CalendarPressableState extends State<CalendarPressable>
    with TickerProviderStateMixin {
  late final AnimationController _hover;
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    // Created eagerly: a wrapper that never animates still has to dispose
    // real controllers rather than build them during unmount.
    _hover = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
  }

  bool get _animated {
    final motion = widget.motion;
    if (motion == null) return false;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return false;
    return motion.hoverScale != 1 || motion.pressScale != 1;
  }

  void _setHover(bool value) {
    if (!mounted) return;
    if (value) {
      _hover.animateTo(1, curve: Curves.easeOut);
    } else {
      _hover.animateBack(0, curve: Curves.easeOut);
    }
  }

  void _setPressed(bool value) {
    if (!mounted) return;
    if (value) {
      _press.animateTo(1, curve: Curves.easeOut);
      return;
    }
    final motion = widget.motion;
    if (motion == null) {
      _press.animateBack(0, curve: Curves.easeOut);
      return;
    }
    // Release with a spring so the surface settles instead of stopping dead.
    _press.animateWith(
      SpringSimulation(motion.settleSpring, _press.value, 0, 0),
    );
  }

  @override
  void dispose() {
    _hover.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = widget.motion;
    if (!widget.enabled || motion == null || !_animated) return widget.child;
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: AnimatedBuilder(
          animation: Listenable.merge([_hover, _press]),
          child: widget.child,
          builder: (context, child) {
            final hover = 1 + (motion.hoverScale - 1) * _hover.value;
            final press =
                1 + (motion.pressScale - 1) * _press.value.clamp(0, 1);
            return Transform.scale(scale: hover * press, child: child);
          },
        ),
      ),
    );
  }
}

/// Reports a committed page step from a following drag.
enum CalendarPageStep {
  /// The drag settled toward an earlier chronological page.
  previous,

  /// The drag settled toward a later chronological page.
  next,
}

/// Moves calendar pages under the pointer and settles them with a spring.
///
/// The wrapped surface follows a horizontal drag continuously, applies
/// rubber-band resistance past the point of no return, and commits a page step
/// from combined distance and velocity instead of a bare distance threshold.
class CalendarDragPager extends StatefulWidget {
  /// Creates a drag-following pager.
  const CalendarDragPager({
    super.key,
    required this.enabled,
    required this.motion,
    required this.onStep,
    required this.child,
    this.canStepBackward = true,
    this.canStepForward = true,
    this.commitDistance = 56,
    this.commitFraction = .18,
    this.commitVelocity = 420,
  });

  /// Whether drags are tracked at all.
  final bool enabled;

  /// Motion tokens supplying settle spring and follow travel.
  final CalendarMotion? motion;

  /// Called once when a drag commits a chronological page step.
  final ValueChanged<CalendarPageStep> onStep;

  /// Wrapped calendar page.
  final Widget child;

  /// Whether an earlier page is reachable.
  final bool canStepBackward;

  /// Whether a later page is reachable.
  final bool canStepForward;

  /// Absolute drag distance that always commits a step.
  final double commitDistance;

  /// Fraction of the surface width that commits a step.
  final double commitFraction;

  /// Fling velocity, in pixels per second, that commits a step.
  final double commitVelocity;

  @override
  State<CalendarDragPager> createState() => _CalendarDragPagerState();
}

class _CalendarDragPagerState extends State<CalendarDragPager>
    with SingleTickerProviderStateMixin {
  late final AnimationController _follow;
  final VelocityTracker _velocity = VelocityTracker.withKind(
    PointerDeviceKind.touch,
  );

  @override
  void initState() {
    super.initState();
    _follow = AnimationController.unbounded(vsync: this, value: 0);
  }

  double _distance = 0;
  double _width = 1;
  bool _tracking = false;

  bool get _follows => widget.motion?.followGestures ?? false;

  void _down(PointerDownEvent event) {
    _tracking = true;
    _distance = 0;
    _velocity.addPosition(event.timeStamp, event.position);
    _follow.stop();
  }

  void _move(PointerMoveEvent event) {
    if (!_tracking) return;
    _velocity.addPosition(event.timeStamp, event.position);
    _distance += event.delta.dx;
    if (_follows) _follow.value = _resistance(_distance);
  }

  void _up(PointerUpEvent event) {
    if (!_tracking) return;
    _tracking = false;
    final velocity = _velocity.getVelocity().pixelsPerSecond.dx;
    final distance = _distance;
    _distance = 0;

    final step = _resolveStep(distance, velocity);
    if (step == null) {
      _settle(velocity);
      return;
    }
    // Hand the remaining travel to the page transition, which continues in the
    // same direction from where the finger left off.
    _follow.value = 0;
    widget.onStep(step);
  }

  void _cancel() {
    if (!_tracking) return;
    _tracking = false;
    _distance = 0;
    _settle(0);
  }

  CalendarPageStep? _resolveStep(double distance, double velocity) {
    final direction = Directionality.of(context);
    final magnitude = distance.abs();
    final committed = magnitude >= widget.commitDistance ||
        magnitude >= _width * widget.commitFraction ||
        velocity.abs() >= widget.commitVelocity;
    if (!committed || magnitude < 8) return null;

    final visualForward =
        velocity.abs() >= widget.commitVelocity ? velocity < 0 : distance < 0;
    final chronologicalNext =
        direction == TextDirection.rtl ? !visualForward : visualForward;
    if (chronologicalNext && !widget.canStepForward) return null;
    if (!chronologicalNext && !widget.canStepBackward) return null;
    return chronologicalNext
        ? CalendarPageStep.next
        : CalendarPageStep.previous;
  }

  void _settle(double velocity) {
    if (_follow.value == 0) return;
    final motion = widget.motion;
    if (motion == null || !motion.isEnabled(context)) {
      _follow.value = 0;
      return;
    }
    _follow.animateWith(
      SpringSimulation(motion.settleSpring, _follow.value, 0, velocity / 1000),
    );
  }

  /// Rubber-bands raw drag distance into a bounded follow offset.
  double _resistance(double distance) {
    final motion = widget.motion;
    final travel = _width * (motion?.pageOffset ?? .18).clamp(.05, .5);
    if (travel <= 0) return 0;
    final normalized = distance / travel;
    final eased = normalized / (1 + normalized.abs() * .85);
    final blocked =
        eased > 0 ? !widget.canStepBackward : !widget.canStepForward;
    return eased * travel * (blocked ? .28 : 1);
  }

  @override
  void dispose() {
    _follow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return LayoutBuilder(builder: (context, constraints) {
      _width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
          ? constraints.maxWidth
          : 1;
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _down,
        onPointerMove: _move,
        onPointerUp: _up,
        onPointerCancel: (_) => _cancel(),
        child: _follows
            ? AnimatedBuilder(
                animation: _follow,
                child: widget.child,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_follow.value, 0),
                  child: child,
                ),
              )
            : widget.child,
      );
    });
  }
}

/// Continuously interpolates height and opacity between two fold surfaces.
///
/// The collapsed and expanded surfaces are both laid out, so the fold follows a
/// drag at any intermediate position without a measurement pass or a mid-fold
/// content swap.
class CalendarFoldLayout extends MultiChildRenderObjectWidget {
  /// Creates a fold layout.
  CalendarFoldLayout({
    super.key,
    required this.progress,
    required this.crossFade,
    required Widget collapsed,
    required Widget expanded,
  })  : assert(progress >= 0 && progress <= 1),
        super(children: [collapsed, expanded]);

  /// Fold position, from `0` (collapsed) through `1` (expanded).
  final double progress;

  /// Whether the two surfaces cross-fade while the height interpolates.
  final bool crossFade;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCalendarFold(progress: progress, crossFade: crossFade);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderCalendarFold renderObject,
  ) {
    renderObject
      ..progress = progress
      ..crossFade = crossFade;
  }
}

/// Parent data used by [RenderCalendarFold].
class CalendarFoldParentData extends ContainerBoxParentData<RenderBox> {}

/// Lays out both fold surfaces and interpolates between their heights.
class RenderCalendarFold extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CalendarFoldParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CalendarFoldParentData> {
  /// Creates a fold render box.
  RenderCalendarFold({required double progress, required bool crossFade})
      : _progress = progress,
        _crossFade = crossFade;

  double _progress;
  bool _crossFade;

  /// Fold position, from `0` (collapsed) through `1` (expanded).
  double get progress => _progress;

  set progress(double value) {
    if (_progress == value) return;
    _progress = value;
    markNeedsLayout();
  }

  /// Whether the two surfaces cross-fade while the height interpolates.
  bool get crossFade => _crossFade;

  set crossFade(bool value) {
    if (_crossFade == value) return;
    _crossFade = value;
    markNeedsPaint();
  }

  /// Height a full fold travels, or `null` before the first layout.
  ///
  /// A drag divides its distance by this value so the surface tracks the
  /// pointer at exactly the rate the fold actually moves.
  double? get foldTravel {
    final collapsed = _collapsed;
    final expanded = _expanded;
    if (collapsed == null || expanded == null) return null;
    if (!collapsed.hasSize || !expanded.hasSize) return null;
    return expanded.size.height - collapsed.size.height;
  }

  RenderBox? get _collapsed => firstChild;

  RenderBox? get _expanded {
    final collapsed = _collapsed;
    return collapsed == null ? null : childAfter(collapsed);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! CalendarFoldParentData) {
      child.parentData = CalendarFoldParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => math.max(
      _collapsed?.getMinIntrinsicWidth(height) ?? 0,
      _expanded?.getMinIntrinsicWidth(height) ?? 0);

  @override
  double computeMaxIntrinsicWidth(double height) => math.max(
      _collapsed?.getMaxIntrinsicWidth(height) ?? 0,
      _expanded?.getMaxIntrinsicWidth(height) ?? 0);

  @override
  double computeMinIntrinsicHeight(double width) => _lerpHeights(
        _collapsed?.getMinIntrinsicHeight(width) ?? 0,
        _expanded?.getMinIntrinsicHeight(width) ?? 0,
      );

  @override
  double computeMaxIntrinsicHeight(double width) => _lerpHeights(
        _collapsed?.getMaxIntrinsicHeight(width) ?? 0,
        _expanded?.getMaxIntrinsicHeight(width) ?? 0,
      );

  double _lerpHeights(double collapsed, double expanded) =>
      collapsed + (expanded - collapsed) * _progress;

  @override
  void performLayout() {
    final collapsed = _collapsed;
    final expanded = _expanded;
    if (collapsed == null || expanded == null) {
      size = constraints.smallest;
      return;
    }
    final childConstraints = BoxConstraints(
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
    );
    collapsed.layout(childConstraints, parentUsesSize: true);
    expanded.layout(childConstraints, parentUsesSize: true);
    size = constraints.constrain(
      Size(
        math.max(collapsed.size.width, expanded.size.width),
        _lerpHeights(collapsed.size.height, expanded.size.height),
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final collapsed = _collapsed;
    final expanded = _expanded;
    if (collapsed == null || expanded == null) return;

    void paintChildren(PaintingContext context, Offset offset) {
      final collapsedAlpha = _crossFade ? 1 - _progress : 1.0;
      final expandedAlpha = _crossFade ? _progress : 1.0;
      // Paint the receding surface first so the incoming one reads as on top.
      if (_progress < 1 && collapsedAlpha > 0) {
        _paintChild(context, offset, collapsed, collapsedAlpha);
      }
      if (_progress > 0 && expandedAlpha > 0) {
        _paintChild(context, offset, expanded, expandedAlpha);
      }
    }

    if (_progress > 0 && _progress < 1) {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        paintChildren,
      );
    } else {
      paintChildren(context, offset);
    }
  }

  void _paintChild(
    PaintingContext context,
    Offset offset,
    RenderBox child,
    double alpha,
  ) {
    if (alpha >= 1) {
      context.paintChild(child, offset);
      return;
    }
    context.pushOpacity(
      offset,
      (alpha.clamp(0.0, 1.0) * 255).round(),
      (context, offset) => context.paintChild(child, offset),
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Only the dominant surface is interactive, so a half-folded calendar never
    // routes a tap to a date the user cannot see.
    final child = _progress >= .5 ? _expanded : _collapsed;
    if (child == null) return false;
    return result.addWithPaintOffset(
      offset: Offset.zero,
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }
}

/// Snaps a horizontally scrolling calendar to whole item strides.
///
/// The simulation keeps the natural fling distance and only rounds the final
/// resting offset, so a fast flick still travels several cards.
class CalendarSnapScrollPhysics extends ScrollPhysics {
  /// Creates snapping physics for a fixed-extent horizontal list.
  const CalendarSnapScrollPhysics({
    required this.itemExtent,
    required this.alignmentOffset,
    this.settleSpring,
    super.parent,
  }) : assert(itemExtent > 0);

  /// Distance between the leading edges of two consecutive items.
  final double itemExtent;

  /// Offset applied so an item can rest centered instead of leading-aligned.
  final double alignmentOffset;

  /// Optional spring used to settle on the resolved item.
  final SpringDescription? settleSpring;

  @override
  CalendarSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CalendarSnapScrollPhysics(
      itemExtent: itemExtent,
      alignmentOffset: alignmentOffset,
      settleSpring: settleSpring,
      parent: buildParent(ancestor),
    );
  }

  @override
  SpringDescription get spring => settleSpring ?? super.spring;

  double _target(ScrollMetrics position, double velocity, Tolerance tolerance) {
    // Project the fling with the ambient friction, then round the projected
    // resting offset instead of the current one. A hard flick therefore skips
    // several items the way a native pager does.
    final projected = position.pixels +
        velocity * .28 * (velocity.abs() / (velocity.abs() + 900));
    var item = (projected + alignmentOffset) / itemExtent;
    if (velocity < -tolerance.velocity) {
      item = item.floorToDouble();
    } else if (velocity > tolerance.velocity) {
      item = item.ceilToDouble();
    } else {
      item = item.roundToDouble();
    }
    return (item * itemExtent - alignmentOffset).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final tolerance = toleranceFor(position);
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final target = _target(position, velocity, tolerance);
    if ((target - position.pixels).abs() < tolerance.distance) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}
