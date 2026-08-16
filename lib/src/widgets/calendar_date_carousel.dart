import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configuration/calendar_configuration.dart';
import '../configuration/calendar_motion.dart';
import '../domain/calendar_date_math.dart';
import '../domain/calendar_event_layout.dart';
import '../domain/calendar_selection_logic.dart';
import '../models/calendar_day_state.dart';
import '../models/calendar_event.dart';
import '../models/calendar_selection.dart';
import '../models/calendar_visible_interval.dart';
import '../theme/calendar_theme_resolver.dart';
import '../theme/horizontal_calendar_theme.dart';
import 'calendar_components.dart';
import 'calendar_motion_primitives.dart';
import 'horizontal_calendar.dart';

/// Built-in content arrangements for [CalendarDateCarousel].
enum CalendarCarouselLayout {
  /// Balanced date cards suitable for most application surfaces.
  classic,

  /// Dense cards for narrow screens and information-heavy interfaces.
  compact,

  /// Centered, elevated cards with visible neighboring context.
  spotlight,

  /// Strong typography and restrained editorial geometry.
  editorial,
}

/// Additive visual configuration for carousel cards and viewport behavior.
@immutable
class CalendarCarouselVisualStyle {
  /// Creates carousel presentation tokens.
  const CalendarCarouselVisualStyle({
    this.layout = CalendarCarouselLayout.classic,
    this.selectedScale = 1.04,
    this.inactiveScale = .96,
    this.inactiveOpacity = .78,
    this.spacing,
    this.elevation = 8,
    this.borderWidth = 1,
    this.borderRadius,
    this.alignment = AlignmentDirectional.centerStart,
    this.showMonth = true,
    this.showEventCount = true,
    this.useGradient = true,
  })  : assert(selectedScale >= 1 && selectedScale <= 1.2),
        assert(inactiveScale >= .75 && inactiveScale <= 1),
        assert(inactiveOpacity >= .3 && inactiveOpacity <= 1),
        assert(spacing == null || (spacing >= 0 && spacing <= 1000)),
        assert(elevation >= 0 && elevation <= 1000),
        assert(borderWidth >= 0 && borderWidth <= 100),
        assert(borderRadius == null ||
            (borderRadius >= 0 && borderRadius <= 1000));

  /// Overall information hierarchy and geometry.
  final CalendarCarouselLayout layout;

  /// Scale of the selected or revealed card.
  final double selectedScale;

  /// Scale of neighboring cards.
  final double inactiveScale;

  /// Opacity of neighboring cards.
  final double inactiveOpacity;

  /// Gap after each card, or `null` to use theme spacing.
  final double? spacing;

  /// Elevation of the selected card.
  final double elevation;

  /// Card outline width.
  final double borderWidth;

  /// Card corner radius, or `null` for a layout-appropriate radius.
  ///
  /// Carousel cards deliberately do not inherit unbounded pill radii because
  /// a date card should retain readable rectangular geometry.
  final double? borderRadius;

  /// Alignment of a card inside its scroll slot.
  final AlignmentGeometry alignment;

  /// Whether built-in cards include the short month label.
  final bool showMonth;

  /// Whether built-in cards include a compact event count.
  final bool showEventCount;

  /// Whether selected built-in cards may use a subtle gradient.
  final bool useGradient;
}

/// Typed application metadata associated with one carousel date.
@immutable
class CalendarCarouselItem<T> {
  /// Creates metadata for [date].
  const CalendarCarouselItem({
    required this.date,
    this.data,
    this.title,
    this.subtitle,
    this.badge,
  });

  /// Civil date represented by this item.
  final DateTime date;

  /// Original application payload.
  final T? data;

  /// Optional prominent card label.
  final String? title;

  /// Optional supporting card label.
  final String? subtitle;

  /// Optional compact status badge.
  final String? badge;
}

/// Complete immutable state supplied to a custom carousel card.
@immutable
class CalendarCarouselCardState<T> {
  /// Creates carousel card state.
  const CalendarCarouselCardState({
    required this.date,
    required this.item,
    required this.events,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.semanticLabel,
    this.selection,
    this.rangePosition = CalendarRangePosition.none,
    this.isFocused = false,
  });

  /// Normalized civil date.
  final DateTime date;

  /// Optional typed metadata for [date].
  final CalendarCarouselItem<T>? item;

  /// Unique events intersecting [date].
  final List<CalendarEvent<T>> events;

  /// Whether [date] is selected.
  final bool isSelected;

  /// Whether [date] is today.
  final bool isToday;

  /// Whether card interaction is disabled.
  final bool isDisabled;

  /// Complete localized accessibility label.
  final String semanticLabel;

  /// Complete controlled selection, when supplied by the carousel.
  final CalendarSelection? selection;

  /// Position of [date] inside a selected range.
  final CalendarRangePosition rangePosition;

  /// Whether [date] is the carousel's revealed focus.
  final bool isFocused;
}

/// Builds complete content for one [CalendarDateCarousel] card.
typedef CalendarCarouselCardBuilder<T> = Widget Function(
  BuildContext context,
  CalendarCarouselCardState<T> state,
);

/// Imperative date-reveal controller for [CalendarDateCarousel].
class CalendarDateCarouselController extends ChangeNotifier {
  /// Creates a controller that can be attached to one date carousel at a time.
  CalendarDateCarouselController();

  Future<void> Function(DateTime date, bool animate)? _reveal;
  DateTime? _visibleDate;
  bool _disposed = false;

  /// Most recently requested visible date.
  DateTime? get visibleDate => _visibleDate;

  /// Reveals [date] without changing the controlled selection.
  Future<void> revealDate(DateTime date, {bool animate = true}) async {
    if (_disposed) return;
    final normalized = CalendarDateMath.dateOnly(date);
    _visibleDate = normalized;
    notifyListeners();
    await _reveal?.call(normalized, animate);
  }

  void _attach(Future<void> Function(DateTime date, bool animate) reveal) {
    _reveal = reveal;
  }

  void _detach(Future<void> Function(DateTime date, bool animate) reveal) {
    if (_reveal == reveal) _reveal = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _reveal = null;
    super.dispose();
  }
}

/// Horizontal date cards for travel, booking, content, and planning flows.
class CalendarDateCarousel<T> extends StatefulWidget {
  /// Creates a controlled single-date carousel.
  const CalendarDateCarousel({
    super.key,
    required this.startDate,
    required this.dayCount,
    required DateTime this.selectedDate,
    required this.onDateSelected,
    this.controller,
    this.onItemSelected,
    this.items = const [],
    this.events = const [],
    this.bounds,
    this.selectableDayPredicate,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.scrolling = CalendarScrollBehavior.free,
    this.cardExtent = 152,
    this.cardHeight = 148,
    this.cardBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    this.visualStyle = const CalendarCarouselVisualStyle(),
  })  : selection = null,
        onSelectionChanged = null,
        selectionBehavior = const CalendarSelectionBehavior(),
        assert(dayCount >= 1 && dayCount <= 366),
        assert(cardExtent >= 80),
        assert(cardHeight >= 96);

  /// Creates a carousel with controlled single, multiple, or range selection.
  const CalendarDateCarousel.controlled({
    super.key,
    required this.startDate,
    required this.dayCount,
    required this.selection,
    required this.onSelectionChanged,
    this.selectionBehavior = const CalendarSelectionBehavior(),
    this.controller,
    this.onItemSelected,
    this.items = const [],
    this.events = const [],
    this.bounds,
    this.selectableDayPredicate,
    this.appearance = const CalendarAppearance(showHeader: false),
    this.scrolling = CalendarScrollBehavior.free,
    this.cardExtent = 152,
    this.cardHeight = 148,
    this.cardBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    this.visualStyle = const CalendarCarouselVisualStyle(),
  })  : selectedDate = null,
        onDateSelected = null,
        assert(dayCount >= 1 && dayCount <= 366),
        assert(cardExtent >= 80),
        assert(cardHeight >= 96);

  /// First visible civil date.
  final DateTime startDate;

  /// Number of contiguous cards, from 1 through 366.
  final int dayCount;

  /// Controlled selected civil date for the single-date constructor.
  final DateTime? selectedDate;

  /// Reports an enabled card selection in the single-date constructor.
  final ValueChanged<DateTime>? onDateSelected;

  /// Controlled advanced selection.
  final CalendarSelection? selection;

  /// Reports an advanced selection proposal.
  final CalendarSelectionChanged? onSelectionChanged;

  /// Advanced single, multiple, and range transition rules.
  final CalendarSelectionBehavior selectionBehavior;

  /// Optional imperative reveal controller.
  final CalendarDateCarouselController? controller;

  /// Reports the typed metadata associated with an accepted card tap.
  final ValueChanged<CalendarCarouselItem<T>?>? onItemSelected;

  /// Optional typed metadata associated with visible dates.
  final List<CalendarCarouselItem<T>> items;

  /// Events bucketed into their intersected visible dates.
  final List<CalendarEvent<T>> events;

  /// Optional inclusive interaction bounds.
  final CalendarDateRange? bounds;

  /// Optional application-specific availability predicate.
  final bool Function(DateTime date)? selectableDayPredicate;

  /// Shared style, density, theme, and motion configuration.
  final CalendarAppearance appearance;

  /// Free card scrolling or one-card snapping navigation.
  final CalendarScrollBehavior scrolling;

  /// Preferred width of each card.
  final double cardExtent;

  /// Minimum height of the carousel viewport.
  final double cardHeight;

  /// Optional complete card replacement.
  final CalendarCarouselCardBuilder<T>? cardBuilder;

  /// Outer horizontal carousel padding.
  final EdgeInsetsGeometry padding;

  /// Layout, scaling, spacing, and built-in card treatment.
  final CalendarCarouselVisualStyle visualStyle;

  CalendarSelection get _effectiveSelection =>
      selection ?? CalendarSelection.single(selectedDate);

  @override
  State<CalendarDateCarousel<T>> createState() =>
      _CalendarDateCarouselState<T>();
}

class _CalendarDateCarouselState<T> extends State<CalendarDateCarousel<T>> {
  final ScrollController _scrollController = ScrollController();
  double _itemStride = 160;
  double _snapAlignmentOffset = 0;
  int? _lastRevealKey;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_revealDate);
  }

  @override
  void didUpdateWidget(covariant CalendarDateCarousel<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(_revealDate);
      widget.controller?._attach(_revealDate);
    }
    final previous = _selectionFocus(oldWidget._effectiveSelection);
    final next = _selectionFocus(widget._effectiveSelection);
    if (previous == null ||
        next == null ||
        !CalendarDateMath.isSameDay(previous, next)) {
      _lastRevealKey = null;
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(_revealDate);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CalendarThemeResolver.resolve(context, widget.appearance);
    final start = CalendarDateMath.dateOnly(widget.startDate);
    final dates = CalendarDateMath.days(start, widget.dayCount);
    final end = CalendarDateMath.addDays(start, widget.dayCount);
    final interval = CalendarVisibleInterval(start, end);
    final itemByDate = <int, CalendarCarouselItem<T>>{
      for (final item in widget.items) _civilKey(item.date): item,
    };
    final eventsByDate = <int, List<CalendarEvent<T>>>{};
    for (final segment
        in CalendarEventLayout.segment(widget.events, interval)) {
      eventsByDate
          .putIfAbsent(_civilKey(segment.date), () => [])
          .add(segment.event);
    }
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final selection = widget._effectiveSelection;
    final focus = _selectionFocus(selection) ?? start;
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final baseHeight = switch (widget.visualStyle.layout) {
      CalendarCarouselLayout.compact => math.min(widget.cardHeight, 118),
      CalendarCarouselLayout.spotlight => math.max(widget.cardHeight, 154),
      CalendarCarouselLayout.classic ||
      CalendarCarouselLayout.editorial =>
        widget.cardHeight,
    };
    final effectiveHeight = baseHeight + (textScale - 1) * 128;

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.cardExtent;
        final preferredExtent = switch (widget.visualStyle.layout) {
          CalendarCarouselLayout.compact => math.min(widget.cardExtent, 120.0),
          CalendarCarouselLayout.spotlight =>
            math.max(widget.cardExtent, 168.0),
          CalendarCarouselLayout.classic ||
          CalendarCarouselLayout.editorial =>
            widget.cardExtent,
        };
        final extent = math.min(preferredExtent, viewportWidth).toDouble();
        _itemStride = extent +
            (widget.visualStyle.spacing ?? theme.daySpacing).clamp(0, 1000);
        final resolvedPadding =
            widget.padding.resolve(Directionality.of(context));
        final centerOffset =
            widget.visualStyle.layout == CalendarCarouselLayout.spotlight
                ? (viewportWidth - extent) / 2
                : 0.0;
        _snapAlignmentOffset = centerOffset - resolvedPadding.left;
        _scheduleReveal(focus);
        return SizedBox(
          height: effectiveHeight,
          child: ListView.builder(
            controller: _scrollController,
            padding: widget.padding,
            scrollDirection: Axis.horizontal,
            itemExtent: _itemStride,
            clipBehavior: Clip.none,
            physics: widget.scrolling == CalendarScrollBehavior.page
                ? CalendarSnapScrollPhysics(
                    itemExtent: _itemStride,
                    alignmentOffset: _snapAlignmentOffset,
                    settleSpring: widget.appearance.motion?.settleSpring,
                  )
                : const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final card = Align(
                alignment: widget.visualStyle.alignment,
                child: SizedBox(
                  width: extent,
                  child: _buildCard(
                    context,
                    date,
                    selection,
                    focus,
                    itemByDate[_civilKey(date)],
                    List<CalendarEvent<T>>.unmodifiable(
                      eventsByDate[_civilKey(date)] ?? const [],
                    ),
                    theme,
                    locale,
                  ),
                ),
              );
              // A spotlight carousel reads its emphasis from scroll position,
              // so cards ease toward the viewport centre as they travel
              // instead of stepping between two discrete sizes.
              return RepaintBoundary(
                child: widget.visualStyle.layout ==
                        CalendarCarouselLayout.spotlight
                    ? _CarouselViewportEffect(
                        controller: _scrollController,
                        index: index,
                        stride: _itemStride,
                        extent: extent,
                        leadingPadding: resolvedPadding.left,
                        viewportWidth: viewportWidth,
                        child: card,
                      )
                    : card,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildCard(
    BuildContext context,
    DateTime date,
    CalendarSelection selection,
    DateTime focus,
    CalendarCarouselItem<T>? item,
    List<CalendarEvent<T>> events,
    HorizontalCalendarThemeData theme,
    String? locale,
  ) {
    final disabled = _isDisabled(date);
    final selected = selection.contains(date);
    final stateWords = <String>[
      if (selected) 'selected',
      if (CalendarDateMath.isSameDay(date, DateTime.now())) 'today',
      if (disabled) 'disabled',
      if (events.isNotEmpty)
        '${events.length} ${events.length == 1 ? 'event' : 'events'}',
      if (item?.badge != null) item!.badge!,
    ];
    final fullDate = DateFormat.yMMMMEEEEd(locale).format(date);
    final state = CalendarCarouselCardState<T>(
      date: date,
      item: item,
      events: events,
      isSelected: selected,
      isToday: CalendarDateMath.isSameDay(date, DateTime.now()),
      isDisabled: disabled,
      semanticLabel:
          stateWords.isEmpty ? fullDate : '$fullDate, ${stateWords.join(', ')}',
      selection: selection,
      rangePosition: CalendarSelectionLogic.rangePosition(selection, date),
      isFocused: CalendarDateMath.isSameDay(date, focus),
    );
    final identifier = _identifier('calendar-carousel-day', date);
    return Semantics(
      identifier: identifier,
      label: state.semanticLabel,
      selected: state.isSelected,
      enabled: !disabled,
      button: true,
      child: SizedBox.expand(
        key: ValueKey(identifier),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            _resolvedCarouselRadius(widget.visualStyle, theme),
          ),
          onTap: disabled ? null : () => _select(date, item),
          child: widget.cardBuilder?.call(context, state) ??
              _DefaultCarouselCard<T>(
                state: state,
                theme: theme,
                motion: widget.appearance.motion,
                locale: locale,
                visualStyle: widget.visualStyle,
              ),
        ),
      ),
    );
  }

  void _select(DateTime date, CalendarCarouselItem<T>? item) {
    final previous = widget._effectiveSelection;
    final next = CalendarSelectionLogic.select(
      previous,
      date,
      behavior: widget.selectionBehavior,
    );
    if (next == previous) return;
    widget.onItemSelected?.call(item);
    if (widget.selection == null) {
      widget.onDateSelected!(next.selectedDate!);
    } else {
      widget.onSelectionChanged!(previous, next);
    }
  }

  bool _isDisabled(DateTime date) {
    final range = widget.bounds;
    if (range != null && !range.contains(date)) return true;
    return !(widget.selectableDayPredicate?.call(date) ?? true);
  }

  void _scheduleReveal(DateTime date) {
    final key = _civilKey(date);
    if (_lastRevealKey == key) return;
    _lastRevealKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _revealDate(date, false);
    });
  }

  Future<void> _revealDate(DateTime date, bool animate) async {
    if (!_scrollController.hasClients) return;
    final start = CalendarDateMath.dateOnly(widget.startDate);
    final index = CalendarDateMath.civilDayDifference(start, date);
    if (index < 0 || index >= widget.dayCount) return;
    final position = _scrollController.position;
    final target = (index * _itemStride - _snapAlignmentOffset).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (animate && !MediaQuery.disableAnimationsOf(context)) {
      final duration = widget.appearance.motion?.effectiveDuration(context) ??
          const Duration(milliseconds: 260);
      await _scrollController.animateTo(
        target,
        duration: duration,
        curve: widget.appearance.motion?.curve ?? Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }
}

/// Eases a card toward its full presence as it approaches the viewport centre.
class _CarouselViewportEffect extends StatelessWidget {
  const _CarouselViewportEffect({
    required this.controller,
    required this.index,
    required this.stride,
    required this.extent,
    required this.leadingPadding,
    required this.viewportWidth,
    required this.child,
  });

  final ScrollController controller;
  final int index;
  final double stride;
  final double extent;
  final double leadingPadding;
  final double viewportWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        if (!controller.hasClients) return child!;
        final cardCentre = leadingPadding + index * stride + extent / 2;
        final viewportCentre = controller.offset + viewportWidth / 2;
        final distance = ((cardCentre - viewportCentre) / math.max(stride, 1))
            .clamp(-2.0, 2.0);
        final proximity = (1 - distance.abs()).clamp(0.0, 1.0);
        return Transform.scale(
          scale: .94 + .06 * proximity,
          child: Opacity(opacity: .62 + .38 * proximity, child: child),
        );
      },
    );
  }
}

class _DefaultCarouselCard<T> extends StatelessWidget {
  const _DefaultCarouselCard({
    required this.state,
    required this.theme,
    required this.motion,
    required this.locale,
    required this.visualStyle,
  });

  final CalendarCarouselCardState<T> state;
  final HorizontalCalendarThemeData theme;
  final CalendarMotion? motion;
  final String? locale;
  final CalendarCarouselVisualStyle visualStyle;

  @override
  Widget build(BuildContext context) {
    final foreground = state.isSelected ? theme.onAccentColor : theme.textColor;
    final duration = motion?.effectiveDuration(context) ??
        (MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220));
    final emphasized = state.isSelected;
    final radius = _resolvedCarouselRadius(visualStyle, theme);
    final scale =
        emphasized ? visualStyle.selectedScale : visualStyle.inactiveScale;
    final opacity = emphasized
        ? 1.0
        : state.isFocused
            ? math.max(.9, visualStyle.inactiveOpacity)
            : visualStyle.inactiveOpacity;
    return CalendarPressable(
      enabled: !state.isDisabled,
      motion: motion,
      child: AnimatedOpacity(
        duration: duration,
        curve: motion?.curve ?? Curves.easeOutCubic,
        opacity: opacity,
        child: AnimatedScale(
          duration: duration,
          curve: motion?.curve ?? Curves.easeOutCubic,
          scale: scale,
          // The card's shadow rides along inside the animated decoration, so
          // elevation, fill, and outline all interpolate on one driver instead
          // of a separate compositing layer per card.
          child: _card(context, foreground, duration, radius),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    Color foreground,
    Duration duration,
    double radius,
  ) {
    final selectedGradient = state.isSelected && visualStyle.useGradient
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.accentColor,
              Color.lerp(theme.accentColor, theme.todayColor, .48)!,
            ],
          )
        : null;
    final content = switch (visualStyle.layout) {
      CalendarCarouselLayout.compact => _compactContent(foreground),
      CalendarCarouselLayout.editorial => _editorialContent(foreground),
      CalendarCarouselLayout.classic ||
      CalendarCarouselLayout.spotlight =>
        _classicContent(foreground),
    };
    final elevation = state.isSelected ? visualStyle.elevation : 0.0;
    return AnimatedContainer(
      duration: duration,
      curve: motion?.curve ?? Curves.easeOutCubic,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selectedGradient == null
            ? (state.isSelected ? theme.accentColor : theme.surfaceColor)
            : null,
        gradient: selectedGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: elevation == 0
            ? null
            : [
                BoxShadow(
                  color: theme.textColor.withValues(alpha: .22),
                  blurRadius: elevation * 1.6,
                  offset: Offset(0, elevation * .55),
                ),
              ],
        border: Border.all(
          color: state.isSelected
              ? theme.accentColor
              : state.isFocused
                  ? theme.focusColor
                  : state.isToday
                      ? theme.todayColor
                      : theme.borderColor,
          width: state.isSelected || state.isFocused || state.isToday
              ? math.max(2, visualStyle.borderWidth)
              : visualStyle.borderWidth,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(width: constraints.maxWidth, child: content),
        ),
      ),
    );
  }

  Widget _compactContent(Color foreground) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.E(locale).format(state.date).toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: theme.weekdayTextStyle.copyWith(color: foreground),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            '${state.date.day}',
            style: theme.headerTextStyle.copyWith(
              color: foreground,
              fontSize: 34,
              height: 1,
            ),
          ),
        ),
        if (visualStyle.showMonth)
          Text(
            '${DateFormat.MMM(locale).format(state.date)} · '
            '${state.isToday ? 'TODAY' : DateFormat.y(locale).format(state.date)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.eventTextStyle.copyWith(
              color: foreground.withValues(alpha: .78),
            ),
          ),
        if (visualStyle.showEventCount && state.events.isNotEmpty)
          _eventSummary(foreground),
      ],
    );
  }

  Widget _classicContent(Color foreground) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.E(locale).format(state.date),
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: theme.weekdayTextStyle.copyWith(color: foreground),
              ),
            ),
            if (state.item?.badge case final badge?)
              Flexible(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    child: Text(
                      badge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.eventTextStyle.copyWith(color: foreground),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${state.date.day}',
          maxLines: 1,
          style: theme.headerTextStyle.copyWith(
            color: foreground,
            fontSize: 28,
          ),
        ),
        if (visualStyle.showMonth)
          Text(
            '${DateFormat.MMM(locale).format(state.date)} · '
            '${state.isToday ? 'TODAY' : DateFormat.y(locale).format(state.date)}',
            maxLines: 1,
            style: theme.eventTextStyle.copyWith(
              color: foreground.withValues(alpha: .72),
              letterSpacing: .8,
            ),
          ),
        const SizedBox(height: 8),
        if (state.item?.title case final title?)
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.eventTextStyle.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (state.item?.subtitle case final subtitle?)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.eventTextStyle.copyWith(
              color: foreground.withValues(alpha: .78),
              fontSize: 10,
            ),
          ),
        if (visualStyle.showEventCount && state.events.isNotEmpty)
          _eventSummary(foreground),
      ],
    );
  }

  Widget _editorialContent(Color foreground) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.EEEE(locale).format(state.date).toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.weekdayTextStyle.copyWith(
            color: foreground,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            '${state.date.day}',
            style: theme.headerTextStyle.copyWith(
              color: foreground,
              fontSize: 42,
              height: .95,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        if (visualStyle.showMonth)
          Text(
            DateFormat.yMMM(locale).format(state.date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.eventTextStyle.copyWith(color: foreground),
          ),
        const SizedBox(height: 8),
        if (state.item?.title case final title?)
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.eventTextStyle.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (visualStyle.showEventCount && state.events.isNotEmpty)
          _eventSummary(foreground),
      ],
    );
  }

  Widget _eventSummary(Color foreground) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CalendarEventMarker(
            count: state.events.length,
            style: EventIndicatorStyle.stack,
            color: foreground,
            size: theme.eventMarkerSize,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '${state.events.length} ${state.events.length == 1 ? 'event' : 'events'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.eventTextStyle.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

double _resolvedCarouselRadius(
  CalendarCarouselVisualStyle visualStyle,
  HorizontalCalendarThemeData theme,
) {
  final override = visualStyle.borderRadius;
  if (override != null) return override;
  return switch (visualStyle.layout) {
    CalendarCarouselLayout.compact => math.min(theme.dayBorderRadius, 16),
    CalendarCarouselLayout.spotlight => math.min(theme.dayBorderRadius, 28),
    CalendarCarouselLayout.editorial => math.min(theme.dayBorderRadius, 10),
    CalendarCarouselLayout.classic => math.min(theme.dayBorderRadius, 22),
  };
}

DateTime? _selectionFocus(CalendarSelection selection) {
  return switch (selection.mode) {
    CalendarSelectionMode.single => selection.selectedDate,
    CalendarSelectionMode.multiple => selection.selectedDates.isEmpty
        ? null
        : (selection.selectedDates.toList()
              ..sort((first, second) =>
                  CalendarDateMath.civilDayDifference(second, first)))
            .first,
    CalendarSelectionMode.range => selection.selectedRange?.start,
  };
}

int _civilKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

String _identifier(String prefix, DateTime date) {
  return '$prefix-${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
