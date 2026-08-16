import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../domain/calendar_date_math.dart';

/// Calendar content optimized for a glanceable phone home-screen surface.
enum CalendarHomeWidgetContent {
  /// Today summary with the next event.
  today,

  /// Seven-day date strip and event summary.
  week,

  /// Chronological upcoming event list.
  agenda,

  /// Time remaining until a target date.
  countdown,

  /// Completed-to-total progress summary.
  progress,

  /// The next event with start and duration information.
  nextEvent,
}

/// Cross-platform home-widget size families.
enum CalendarHomeWidgetFamily {
  /// Narrow Android launcher or in-app compact surface.
  compact,

  /// iOS system-small or equivalent Android square.
  small,

  /// iOS system-medium or equivalent Android wide surface.
  medium,

  /// iOS system-large or equivalent Android tall surface.
  large,

  /// iPad, desktop, or wide foldable surface.
  extraLarge,

  /// Lock-screen or complication-sized surface.
  accessory,
}

/// Useful deterministic preview geometry for each home-widget family.
extension CalendarHomeWidgetFamilyGeometry on CalendarHomeWidgetFamily {
  /// Representative logical size for galleries and golden tests.
  Size get previewSize => switch (this) {
        CalendarHomeWidgetFamily.compact => const Size(160, 110),
        CalendarHomeWidgetFamily.small => const Size(170, 170),
        CalendarHomeWidgetFamily.medium => const Size(360, 170),
        CalendarHomeWidgetFamily.large => const Size(360, 360),
        CalendarHomeWidgetFamily.extraLarge => const Size(520, 360),
        CalendarHomeWidgetFamily.accessory => const Size(72, 72),
      };
}

/// Density of information in a [CalendarHomeWidget].
enum CalendarHomeWidgetDensity {
  /// Chooses density from the resolved family.
  adaptive,

  /// Shows only essential information.
  compact,

  /// Balances labels and supporting information.
  comfortable,

  /// Shows the most supporting content that fits.
  spacious,
}

/// Surface treatment used by Flutter previews and portable native hosts.
enum CalendarHomeWidgetSurfaceStyle {
  /// A single opaque background color.
  solid,

  /// A two-color diagonal gradient.
  gradient,

  /// A bordered surface using the configured background color.
  outlined,

  /// A translucent layered surface for in-app previews.
  glass,

  /// No painted surface behind the content.
  transparent,
}

/// Visual treatment for event rows.
enum CalendarHomeWidgetEventStyle {
  /// A vertical color bar followed by event content.
  bar,

  /// A compact circular color marker.
  dot,

  /// A softly filled event card.
  card,

  /// Text-only event content.
  minimal,
}

/// Shape applied to the selected day in week content.
enum CalendarHomeWidgetDateShape {
  /// A circular selected day.
  circle,

  /// A softly rounded selected day.
  rounded,

  /// A compact square selected day.
  square,

  /// No filled selected-day surface.
  none,
}

/// Progress visualization used by progress content.
enum CalendarHomeWidgetProgressStyle {
  /// A horizontal progress track.
  linear,

  /// A circular progress ring.
  circular,

  /// A row of discrete progress segments.
  segmented,

  /// No visual progress indicator.
  hidden,
}

/// Header arrangement used by non-accessory content.
enum CalendarHomeWidgetHeaderStyle {
  /// Payload title with an accent status marker.
  title,

  /// Localized month and year.
  month,

  /// Short month label with the selected date.
  compact,

  /// No header.
  hidden,
}

/// Weekday label length used by week content.
enum CalendarHomeWidgetWeekdayFormat {
  /// A single localized grapheme where possible.
  narrow,

  /// A localized abbreviated weekday.
  short,

  /// A localized full weekday.
  full,

  /// No weekday label.
  hidden,
}

/// Deep-link action encoded into native home-widget payloads.
@immutable
class CalendarHomeWidgetAction {
  /// Creates an action that opens [uri].
  const CalendarHomeWidgetAction({required this.uri, this.label});

  /// Application URL opened by the native widget.
  final String uri;

  /// Optional accessible action label.
  final String? label;

  /// Encodes this action for a platform host.
  Map<String, Object?> toJson() => {'uri': uri, 'label': label};

  /// Decodes an action from a platform payload.
  factory CalendarHomeWidgetAction.fromJson(Map<String, Object?> json) =>
      CalendarHomeWidgetAction(
        uri: json['uri']! as String,
        label: json['label'] as String?,
      );
}

/// Serializable event used by native and Flutter home-widget renderers.
@immutable
class CalendarHomeWidgetEvent {
  /// Creates a home-widget event.
  CalendarHomeWidgetEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.subtitle,
    this.location,
    this.colorValue,
    this.isAllDay = false,
    this.action,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'Must not be empty.');
    if (title.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Must not be empty.');
    }
    if (end.isBefore(start)) throw ArgumentError('end must not precede start.');
  }

  /// Stable event identity.
  final String id;

  /// Primary event label.
  final String title;

  /// Optional supporting label.
  final String? subtitle;

  /// Optional event location.
  final String? location;

  /// Inclusive event start instant.
  final DateTime start;

  /// Exclusive event end instant, or the same instant for a milestone.
  final DateTime end;

  /// Optional ARGB color integer understood by native hosts.
  final int? colorValue;

  /// Whether time labels should be hidden.
  final bool isAllDay;

  /// Optional event-specific deep link.
  final CalendarHomeWidgetAction? action;

  /// Encodes this event for storage or a platform host.
  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'location': location,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'colorValue': colorValue,
        'isAllDay': isAllDay,
        'action': action?.toJson(),
      };

  /// Decodes an event from storage or a platform host.
  factory CalendarHomeWidgetEvent.fromJson(Map<String, Object?> json) =>
      CalendarHomeWidgetEvent(
        id: json['id']! as String,
        title: json['title']! as String,
        subtitle: json['subtitle'] as String?,
        location: json['location'] as String?,
        start: DateTime.parse(json['start']! as String),
        end: DateTime.parse(json['end']! as String),
        colorValue: json['colorValue'] as int?,
        isAllDay: json['isAllDay'] as bool? ?? false,
        action: switch (json['action']) {
          final Map<Object?, Object?> value =>
            CalendarHomeWidgetAction.fromJson(value.cast<String, Object?>()),
          _ => null,
        },
      );
}

/// Versioned payload shared by Flutter, Android App Widgets, and WidgetKit.
@immutable
class CalendarHomeWidgetData {
  /// Creates a complete home-widget payload.
  CalendarHomeWidgetData({
    required this.generatedAt,
    required DateTime selectedDate,
    this.title,
    this.subtitle,
    List<CalendarHomeWidgetEvent> events = const [],
    this.targetDate,
    this.completedCount = 0,
    this.totalCount = 0,
    this.action,
    this.locale,
    this.use24HourTime,
  })  : selectedDate = CalendarDateMath.dateOnly(selectedDate),
        events = List.unmodifiable(events),
        assert(completedCount >= 0),
        assert(totalCount >= 0);

  /// Current payload schema version.
  static const int schemaVersion = 1;

  /// Instant at which the host produced this payload.
  final DateTime generatedAt;

  /// Civil date emphasized by the widget.
  final DateTime selectedDate;

  /// Optional widget headline.
  final String? title;

  /// Optional supporting copy.
  final String? subtitle;

  /// Upcoming event content.
  final List<CalendarHomeWidgetEvent> events;

  /// Optional countdown target.
  final DateTime? targetDate;

  /// Completed items for progress content.
  final int completedCount;

  /// Total items for progress content.
  final int totalCount;

  /// Default surface deep link.
  final CalendarHomeWidgetAction? action;

  /// Optional BCP-47 or Dart locale identifier.
  final String? locale;

  /// Optional clock-format override.
  final bool? use24HourTime;

  /// Encodes the stable platform payload.
  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'generatedAt': generatedAt.toIso8601String(),
        'selectedDate': selectedDate.toIso8601String(),
        'title': title,
        'subtitle': subtitle,
        'events': events.map((event) => event.toJson()).toList(growable: false),
        'targetDate': targetDate?.toIso8601String(),
        'completedCount': completedCount,
        'totalCount': totalCount,
        'action': action?.toJson(),
        'locale': locale,
        'use24HourTime': use24HourTime,
      };

  /// Encodes this payload as a JSON string for app-group storage.
  String encode() => jsonEncode(toJson());

  /// Decodes a stable platform payload.
  factory CalendarHomeWidgetData.fromJson(Map<String, Object?> json) {
    final version = json['schemaVersion'] as int? ?? 1;
    if (version != schemaVersion) {
      throw FormatException('Unsupported calendar widget schema: $version');
    }
    final rawEvents = json['events'] as List<Object?>? ?? const [];
    return CalendarHomeWidgetData(
      generatedAt: DateTime.parse(json['generatedAt']! as String),
      selectedDate: DateTime.parse(json['selectedDate']! as String),
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      events: rawEvents
          .map((value) => CalendarHomeWidgetEvent.fromJson(
                (value! as Map<Object?, Object?>).cast<String, Object?>(),
              ))
          .toList(growable: false),
      targetDate: switch (json['targetDate']) {
        final String value => DateTime.parse(value),
        _ => null,
      },
      completedCount: json['completedCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      action: switch (json['action']) {
        final Map<Object?, Object?> value =>
          CalendarHomeWidgetAction.fromJson(value.cast<String, Object?>()),
        _ => null,
      },
      locale: json['locale'] as String?,
      use24HourTime: json['use24HourTime'] as bool?,
    );
  }

  /// Decodes a JSON string read from shared platform storage.
  factory CalendarHomeWidgetData.decode(String source) =>
      CalendarHomeWidgetData.fromJson(
        (jsonDecode(source) as Map<Object?, Object?>).cast<String, Object?>(),
      );
}

/// Visual tokens shared by all Flutter home-widget families.
@immutable
class CalendarHomeWidgetTheme {
  /// Creates home-widget presentation tokens.
  const CalendarHomeWidgetTheme({
    this.backgroundColor = const Color(0xff11131a),
    this.foregroundColor = Colors.white,
    this.secondaryColor = const Color(0xffaeb4c5),
    this.accentColor = const Color(0xff9f8cff),
    this.dividerColor = const Color(0x33ffffff),
    this.surfaceStyle = CalendarHomeWidgetSurfaceStyle.solid,
    this.gradientColors = const [],
    this.borderColor,
    this.borderWidth = 1,
    this.elevation = 0,
    this.cornerRadius = 24,
    this.typographyScale = 1,
    this.density = CalendarHomeWidgetDensity.adaptive,
    this.firstDayOfWeek = DateTime.monday,
    this.headerStyle = CalendarHomeWidgetHeaderStyle.title,
    this.eventStyle = CalendarHomeWidgetEventStyle.bar,
    this.dateShape = CalendarHomeWidgetDateShape.circle,
    this.progressStyle = CalendarHomeWidgetProgressStyle.linear,
    this.weekdayFormat = CalendarHomeWidgetWeekdayFormat.narrow,
    this.contentPadding,
    this.itemSpacing = 6,
    this.eventIndicatorWidth = 4,
    this.maximumEvents = 5,
    this.showWeekday = true,
    this.showEventTime = true,
    this.showProgress = true,
    this.showSubtitle = true,
    this.showLocation = true,
    this.useEventColors = true,
    this.animateChanges = true,
  })  : assert(borderWidth >= 0 && borderWidth <= 8),
        assert(elevation >= 0 && elevation <= 24),
        assert(cornerRadius >= 0),
        assert(typographyScale >= .75 && typographyScale <= 2),
        assert(itemSpacing >= 0 && itemSpacing <= 32),
        assert(eventIndicatorWidth >= 1 && eventIndicatorWidth <= 16),
        assert(maximumEvents >= 0 && maximumEvents <= 12),
        assert(firstDayOfWeek >= DateTime.monday &&
            firstDayOfWeek <= DateTime.sunday);

  /// Surface background.
  final Color backgroundColor;

  /// Primary content color.
  final Color foregroundColor;

  /// Supporting content color.
  final Color secondaryColor;

  /// Selection and event accent.
  final Color accentColor;

  /// Separator color.
  final Color dividerColor;

  /// Surface treatment.
  final CalendarHomeWidgetSurfaceStyle surfaceStyle;

  /// Optional two-color gradient. Empty uses derived background shades.
  final List<Color> gradientColors;

  /// Optional border color. Outlined surfaces fall back to [accentColor].
  final Color? borderColor;

  /// Border width for outlined or explicitly bordered surfaces.
  final double borderWidth;

  /// In-app preview shadow elevation.
  final double elevation;

  /// Outer surface corner radius.
  final double cornerRadius;

  /// Typography multiplier.
  final double typographyScale;

  /// Information density.
  final CalendarHomeWidgetDensity density;

  /// First weekday used by week content.
  final int firstDayOfWeek;

  /// Header arrangement.
  final CalendarHomeWidgetHeaderStyle headerStyle;

  /// Event row treatment.
  final CalendarHomeWidgetEventStyle eventStyle;

  /// Selected-day shape.
  final CalendarHomeWidgetDateShape dateShape;

  /// Progress indicator treatment.
  final CalendarHomeWidgetProgressStyle progressStyle;

  /// Localized weekday label length.
  final CalendarHomeWidgetWeekdayFormat weekdayFormat;

  /// Optional content padding used unless the widget overrides it.
  final EdgeInsets? contentPadding;

  /// Vertical spacing between repeated content.
  final double itemSpacing;

  /// Width of bar and dot event indicators.
  final double eventIndicatorWidth;

  /// Maximum event rows displayed by agenda and expanded week content.
  final int maximumEvents;

  /// Whether weekday labels are shown where space permits.
  final bool showWeekday;

  /// Whether timed events show a clock label.
  final bool showEventTime;

  /// Whether a progress indicator is shown where applicable.
  final bool showProgress;

  /// Whether supporting payload and event subtitles are shown.
  final bool showSubtitle;

  /// Whether event locations are included in detail labels.
  final bool showLocation;

  /// Whether event-specific colors override [accentColor].
  final bool useEventColors;

  /// Whether changes animate in Flutter previews.
  final bool animateChanges;

  /// Returns a theme with the supplied values replaced.
  CalendarHomeWidgetTheme copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? dividerColor,
    CalendarHomeWidgetSurfaceStyle? surfaceStyle,
    List<Color>? gradientColors,
    Color? borderColor,
    double? borderWidth,
    double? elevation,
    double? cornerRadius,
    double? typographyScale,
    CalendarHomeWidgetDensity? density,
    int? firstDayOfWeek,
    CalendarHomeWidgetHeaderStyle? headerStyle,
    CalendarHomeWidgetEventStyle? eventStyle,
    CalendarHomeWidgetDateShape? dateShape,
    CalendarHomeWidgetProgressStyle? progressStyle,
    CalendarHomeWidgetWeekdayFormat? weekdayFormat,
    EdgeInsets? contentPadding,
    double? itemSpacing,
    double? eventIndicatorWidth,
    int? maximumEvents,
    bool? showWeekday,
    bool? showEventTime,
    bool? showProgress,
    bool? showSubtitle,
    bool? showLocation,
    bool? useEventColors,
    bool? animateChanges,
  }) =>
      CalendarHomeWidgetTheme(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        accentColor: accentColor ?? this.accentColor,
        dividerColor: dividerColor ?? this.dividerColor,
        surfaceStyle: surfaceStyle ?? this.surfaceStyle,
        gradientColors: gradientColors ?? this.gradientColors,
        borderColor: borderColor ?? this.borderColor,
        borderWidth: borderWidth ?? this.borderWidth,
        elevation: elevation ?? this.elevation,
        cornerRadius: cornerRadius ?? this.cornerRadius,
        typographyScale: typographyScale ?? this.typographyScale,
        density: density ?? this.density,
        firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
        headerStyle: headerStyle ?? this.headerStyle,
        eventStyle: eventStyle ?? this.eventStyle,
        dateShape: dateShape ?? this.dateShape,
        progressStyle: progressStyle ?? this.progressStyle,
        weekdayFormat: weekdayFormat ?? this.weekdayFormat,
        contentPadding: contentPadding ?? this.contentPadding,
        itemSpacing: itemSpacing ?? this.itemSpacing,
        eventIndicatorWidth: eventIndicatorWidth ?? this.eventIndicatorWidth,
        maximumEvents: maximumEvents ?? this.maximumEvents,
        showWeekday: showWeekday ?? this.showWeekday,
        showEventTime: showEventTime ?? this.showEventTime,
        showProgress: showProgress ?? this.showProgress,
        showSubtitle: showSubtitle ?? this.showSubtitle,
        showLocation: showLocation ?? this.showLocation,
        useEventColors: useEventColors ?? this.useEventColors,
        animateChanges: animateChanges ?? this.animateChanges,
      );

  /// Encodes portable theme tokens for Flutter and native hosts.
  Map<String, Object?> toJson() => {
        'backgroundColor': backgroundColor.toARGB32(),
        'foregroundColor': foregroundColor.toARGB32(),
        'secondaryColor': secondaryColor.toARGB32(),
        'accentColor': accentColor.toARGB32(),
        'dividerColor': dividerColor.toARGB32(),
        'surfaceStyle': surfaceStyle.name,
        'gradientColors': gradientColors
            .map((color) => color.toARGB32())
            .toList(growable: false),
        'borderColor': borderColor?.toARGB32(),
        'borderWidth': borderWidth,
        'elevation': elevation,
        'cornerRadius': cornerRadius,
        'typographyScale': typographyScale,
        'density': density.name,
        'firstDayOfWeek': firstDayOfWeek,
        'headerStyle': headerStyle.name,
        'eventStyle': eventStyle.name,
        'dateShape': dateShape.name,
        'progressStyle': progressStyle.name,
        'weekdayFormat': weekdayFormat.name,
        'contentPadding': switch (contentPadding) {
          final EdgeInsets padding => {
              'left': padding.left,
              'top': padding.top,
              'right': padding.right,
              'bottom': padding.bottom,
            },
          _ => null,
        },
        'itemSpacing': itemSpacing,
        'eventIndicatorWidth': eventIndicatorWidth,
        'maximumEvents': maximumEvents,
        'showWeekday': showWeekday,
        'showEventTime': showEventTime,
        'showProgress': showProgress,
        'showSubtitle': showSubtitle,
        'showLocation': showLocation,
        'useEventColors': useEventColors,
        'animateChanges': animateChanges,
      };

  /// Decodes theme tokens, preserving defaults for fields from older payloads.
  factory CalendarHomeWidgetTheme.fromJson(Map<String, Object?> json) {
    const defaults = CalendarHomeWidgetTheme();
    final rawGradient = json['gradientColors'] as List<Object?>? ?? const [];
    final rawPadding = json['contentPadding'];
    return CalendarHomeWidgetTheme(
      backgroundColor:
          _decodeColor(json['backgroundColor']) ?? defaults.backgroundColor,
      foregroundColor:
          _decodeColor(json['foregroundColor']) ?? defaults.foregroundColor,
      secondaryColor:
          _decodeColor(json['secondaryColor']) ?? defaults.secondaryColor,
      accentColor: _decodeColor(json['accentColor']) ?? defaults.accentColor,
      dividerColor: _decodeColor(json['dividerColor']) ?? defaults.dividerColor,
      surfaceStyle: _decodeEnum(
        CalendarHomeWidgetSurfaceStyle.values,
        json['surfaceStyle'],
        defaults.surfaceStyle,
      ),
      gradientColors: rawGradient
          .map(_decodeColor)
          .whereType<Color>()
          .take(2)
          .toList(growable: false),
      borderColor: _decodeColor(json['borderColor']),
      borderWidth: _decodeDouble(json['borderWidth'], defaults.borderWidth),
      elevation: _decodeDouble(json['elevation'], defaults.elevation),
      cornerRadius: _decodeDouble(json['cornerRadius'], defaults.cornerRadius),
      typographyScale:
          _decodeDouble(json['typographyScale'], defaults.typographyScale),
      density: _decodeEnum(
        CalendarHomeWidgetDensity.values,
        json['density'],
        defaults.density,
      ),
      firstDayOfWeek: json['firstDayOfWeek'] as int? ?? defaults.firstDayOfWeek,
      headerStyle: _decodeEnum(
        CalendarHomeWidgetHeaderStyle.values,
        json['headerStyle'],
        defaults.headerStyle,
      ),
      eventStyle: _decodeEnum(
        CalendarHomeWidgetEventStyle.values,
        json['eventStyle'],
        defaults.eventStyle,
      ),
      dateShape: _decodeEnum(
        CalendarHomeWidgetDateShape.values,
        json['dateShape'],
        defaults.dateShape,
      ),
      progressStyle: _decodeEnum(
        CalendarHomeWidgetProgressStyle.values,
        json['progressStyle'],
        defaults.progressStyle,
      ),
      weekdayFormat: _decodeEnum(
        CalendarHomeWidgetWeekdayFormat.values,
        json['weekdayFormat'],
        defaults.weekdayFormat,
      ),
      contentPadding: switch (rawPadding) {
        final Map<Object?, Object?> value => EdgeInsets.fromLTRB(
            _decodeDouble(value['left'], 0),
            _decodeDouble(value['top'], 0),
            _decodeDouble(value['right'], 0),
            _decodeDouble(value['bottom'], 0),
          ),
        _ => null,
      },
      itemSpacing: _decodeDouble(json['itemSpacing'], defaults.itemSpacing),
      eventIndicatorWidth: _decodeDouble(
        json['eventIndicatorWidth'],
        defaults.eventIndicatorWidth,
      ),
      maximumEvents: json['maximumEvents'] as int? ?? defaults.maximumEvents,
      showWeekday: json['showWeekday'] as bool? ?? defaults.showWeekday,
      showEventTime: json['showEventTime'] as bool? ?? defaults.showEventTime,
      showProgress: json['showProgress'] as bool? ?? defaults.showProgress,
      showSubtitle: json['showSubtitle'] as bool? ?? defaults.showSubtitle,
      showLocation: json['showLocation'] as bool? ?? defaults.showLocation,
      useEventColors:
          json['useEventColors'] as bool? ?? defaults.useEventColors,
      animateChanges:
          json['animateChanges'] as bool? ?? defaults.animateChanges,
    );
  }
}

/// Serializable home-widget layout and presentation configuration.
@immutable
class CalendarHomeWidgetConfiguration {
  /// Creates a portable configuration for Flutter and native widget hosts.
  const CalendarHomeWidgetConfiguration({
    this.family,
    this.content = CalendarHomeWidgetContent.week,
    this.theme = const CalendarHomeWidgetTheme(),
  });

  /// Current configuration schema version.
  static const int schemaVersion = 1;

  /// Preferred family, or `null` to let the host use its actual family.
  final CalendarHomeWidgetFamily? family;

  /// Preferred content arrangement.
  final CalendarHomeWidgetContent content;

  /// Portable visual and information-density tokens.
  final CalendarHomeWidgetTheme theme;

  /// Encodes the configuration for storage or a platform host.
  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'family': family?.name,
        'content': content.name,
        'theme': theme.toJson(),
      };

  /// Decodes a configuration, accepting missing fields from schema version 1.
  factory CalendarHomeWidgetConfiguration.fromJson(
    Map<String, Object?> json,
  ) {
    final version = json['schemaVersion'] as int? ?? schemaVersion;
    if (version != schemaVersion) {
      throw FormatException(
        'Unsupported calendar widget configuration schema: $version',
      );
    }
    final rawTheme = json['theme'];
    return CalendarHomeWidgetConfiguration(
      family: _decodeNullableEnum(
        CalendarHomeWidgetFamily.values,
        json['family'],
      ),
      content: _decodeEnum(
        CalendarHomeWidgetContent.values,
        json['content'],
        CalendarHomeWidgetContent.week,
      ),
      theme: switch (rawTheme) {
        final Map<Object?, Object?> value =>
          CalendarHomeWidgetTheme.fromJson(value.cast<String, Object?>()),
        _ => const CalendarHomeWidgetTheme(),
      },
    );
  }
}

T _decodeEnum<T extends Enum>(List<T> values, Object? value, T fallback) {
  for (final candidate in values) {
    if (candidate.name == value) return candidate;
  }
  return fallback;
}

T? _decodeNullableEnum<T extends Enum>(List<T> values, Object? value) {
  for (final candidate in values) {
    if (candidate.name == value) return candidate;
  }
  return null;
}

Color? _decodeColor(Object? value) => switch (value) {
      final int argb => Color(argb),
      _ => null,
    };

double _decodeDouble(Object? value, double fallback) => switch (value) {
      final num number => number.toDouble(),
      _ => fallback,
    };

/// Responsive Flutter renderer for calendar home-widget content.
class CalendarHomeWidget extends StatelessWidget {
  /// Creates a home-widget surface.
  const CalendarHomeWidget({
    super.key,
    required this.data,
    this.family,
    this.content = CalendarHomeWidgetContent.today,
    this.theme = const CalendarHomeWidgetTheme(),
    this.onAction,
    this.padding,
  });

  /// Serializable widget content.
  final CalendarHomeWidgetData data;

  /// Explicit family, or `null` to derive it from constraints.
  final CalendarHomeWidgetFamily? family;

  /// Content arrangement.
  final CalendarHomeWidgetContent content;

  /// Widget-specific presentation tokens.
  final CalendarHomeWidgetTheme theme;

  /// Reports the activated surface or event action.
  final ValueChanged<CalendarHomeWidgetAction>? onAction;

  /// Optional content padding override.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final resolvedFamily = family ?? _familyFor(constraints);
          final compact = resolvedFamily == CalendarHomeWidgetFamily.compact ||
              resolvedFamily == CalendarHomeWidgetFamily.accessory;
          final resolvedPadding = padding ??
              theme.contentPadding ??
              EdgeInsets.all(
                resolvedFamily == CalendarHomeWidgetFamily.accessory
                    ? 6
                    : compact
                        ? 10
                        : 16,
              );
          final reduceMotion =
              MediaQuery.maybeOf(context)?.disableAnimations ?? false;
          final decoration = _surfaceDecoration(theme);
          final surface = AnimatedContainer(
            key: const ValueKey('calendar-home-widget-surface'),
            duration: theme.animateChanges && !reduceMotion
                ? const Duration(milliseconds: 280)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            decoration: decoration,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.cornerRadius),
              child: Padding(
                padding: resolvedPadding,
                child: _HomeWidgetContent(
                  data: data,
                  family: resolvedFamily,
                  content: content,
                  theme: theme,
                  onAction: onAction,
                ),
              ),
            ),
          );
          // A system widget is always handed a fixed box. Inside a scroll view
          // or an intrinsic-height parent there is no bounded height, so adopt
          // the family's natural aspect instead of failing layout.
          final sized = constraints.hasBoundedHeight
              ? surface
              : SizedBox(
                  height: _unboundedHeightFor(resolvedFamily, constraints),
                  child: surface,
                );
          return Semantics(
            label: data.title ?? 'Calendar widget',
            button: onAction != null && data.action != null,
            child: data.action == null || onAction == null
                ? sized
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onAction!(data.action!),
                    child: sized,
                  ),
          );
        },
      );

  /// Height used when the parent supplies no bounded height.
  ///
  /// Mirrors the aspect each family occupies on a home screen, clamped so a
  /// very wide or very narrow parent still produces a usable surface.
  static double _unboundedHeightFor(
    CalendarHomeWidgetFamily family,
    BoxConstraints constraints,
  ) {
    final width = constraints.hasBoundedWidth && constraints.maxWidth > 0
        ? constraints.maxWidth
        : 320.0;
    final aspect = switch (family) {
      CalendarHomeWidgetFamily.accessory => 6.0,
      CalendarHomeWidgetFamily.compact => 2.6,
      CalendarHomeWidgetFamily.small => 1.0,
      CalendarHomeWidgetFamily.medium => 2.13,
      CalendarHomeWidgetFamily.large => 1.05,
      CalendarHomeWidgetFamily.extraLarge => 2.1,
    };
    return (width / aspect).clamp(48.0, 900.0);
  }

  static BoxDecoration _surfaceDecoration(CalendarHomeWidgetTheme theme) {
    final colors = theme.gradientColors.length == 2
        ? theme.gradientColors
        : [
            theme.backgroundColor,
            Color.alphaBlend(
              theme.accentColor.withValues(alpha: .16),
              theme.backgroundColor,
            ),
          ];
    final gradient = switch (theme.surfaceStyle) {
      CalendarHomeWidgetSurfaceStyle.gradient => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      CalendarHomeWidgetSurfaceStyle.glass => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors
              .map((color) => color.withValues(alpha: .72))
              .toList(growable: false),
        ),
      _ => null,
    };
    final color = switch (theme.surfaceStyle) {
      CalendarHomeWidgetSurfaceStyle.transparent => Colors.transparent,
      CalendarHomeWidgetSurfaceStyle.gradient ||
      CalendarHomeWidgetSurfaceStyle.glass =>
        null,
      _ => theme.backgroundColor,
    };
    final showBorder =
        theme.surfaceStyle == CalendarHomeWidgetSurfaceStyle.outlined ||
            theme.borderColor != null;
    return BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: BorderRadius.circular(theme.cornerRadius),
      border: showBorder
          ? Border.all(
              color: theme.borderColor ?? theme.accentColor,
              width: theme.borderWidth,
            )
          : null,
      boxShadow: theme.elevation <= 0
          ? const []
          : [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: (.08 + theme.elevation / 120).clamp(.08, .28),
                ),
                blurRadius: theme.elevation * 2,
                offset: Offset(0, theme.elevation / 2),
              ),
            ],
    );
  }

  static CalendarHomeWidgetFamily _familyFor(BoxConstraints constraints) {
    final width = constraints.hasBoundedWidth ? constraints.maxWidth : 360.0;
    final height = constraints.hasBoundedHeight ? constraints.maxHeight : 170.0;
    if (width <= 88 && height <= 88) return CalendarHomeWidgetFamily.accessory;
    if (width < 180 && height < 140) return CalendarHomeWidgetFamily.compact;
    if (width < 250 && height < 250) return CalendarHomeWidgetFamily.small;
    if (width >= 480) return CalendarHomeWidgetFamily.extraLarge;
    if (height >= 280) return CalendarHomeWidgetFamily.large;
    return CalendarHomeWidgetFamily.medium;
  }
}

class _HomeWidgetContent extends StatelessWidget {
  const _HomeWidgetContent({
    required this.data,
    required this.family,
    required this.content,
    required this.theme,
    required this.onAction,
  });

  final CalendarHomeWidgetData data;
  final CalendarHomeWidgetFamily family;
  final CalendarHomeWidgetContent content;
  final CalendarHomeWidgetTheme theme;
  final ValueChanged<CalendarHomeWidgetAction>? onAction;

  bool get _accessory => family == CalendarHomeWidgetFamily.accessory;
  bool get _compact => family == CalendarHomeWidgetFamily.compact;
  bool get _wide =>
      family == CalendarHomeWidgetFamily.medium ||
      family == CalendarHomeWidgetFamily.extraLarge;
  bool get _large =>
      family == CalendarHomeWidgetFamily.large ||
      family == CalendarHomeWidgetFamily.extraLarge;

  @override
  Widget build(BuildContext context) {
    if (_accessory) return _accessoryContent();
    final body = switch (content) {
      CalendarHomeWidgetContent.today => _today(context),
      CalendarHomeWidgetContent.week => _week(context),
      CalendarHomeWidgetContent.agenda => _agenda(context),
      CalendarHomeWidgetContent.countdown => _countdown(context),
      CalendarHomeWidgetContent.progress => _progress(context),
      CalendarHomeWidgetContent.nextEvent => _nextEvent(context),
    };
    return DefaultTextStyle(
      style: TextStyle(
        color: theme.foregroundColor,
        fontSize: 13 * theme.typographyScale,
        height: 1.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: body,
    );
  }

  Widget _accessoryContent() => FittedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${data.selectedDate.day}',
              style: TextStyle(
                color: theme.foregroundColor,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: .9,
              ),
            ),
            Text(
              DateFormat.MMM(data.locale).format(data.selectedDate),
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _header() {
    if (theme.headerStyle == CalendarHomeWidgetHeaderStyle.hidden) {
      return const SizedBox.shrink();
    }
    final label = switch (theme.headerStyle) {
      CalendarHomeWidgetHeaderStyle.title =>
        data.title ?? DateFormat.yMMMM(data.locale).format(data.selectedDate),
      CalendarHomeWidgetHeaderStyle.month =>
        DateFormat.yMMMM(data.locale).format(data.selectedDate),
      CalendarHomeWidgetHeaderStyle.compact =>
        DateFormat.MMMd(data.locale).format(data.selectedDate),
      CalendarHomeWidgetHeaderStyle.hidden => '',
    };
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize:
                  (theme.headerStyle == CalendarHomeWidgetHeaderStyle.compact
                          ? 13
                          : 15) *
                      theme.typographyScale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: theme.accentColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _today(BuildContext context) {
    final next = data.events.isEmpty ? null : data.events.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${data.selectedDate.day}',
              style: TextStyle(
                fontSize: (_wide ? 58 : 44) * theme.typographyScale,
                fontWeight: FontWeight.w800,
                height: .85,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  DateFormat('EEEE\nMMM', data.locale)
                      .format(data.selectedDate),
                  maxLines: 2,
                  style: TextStyle(color: theme.secondaryColor),
                ),
              ),
            ),
            if (next != null && _wide) Expanded(child: _eventTile(next)),
          ],
        ),
        if (next != null && !_wide && !_compact) ...[
          const SizedBox(height: 8),
          _eventTile(next),
        ],
      ],
    );
  }

  Widget _week(BuildContext context) {
    final selected = data.selectedDate;
    final start = CalendarDateMath.startOfWeek(selected, theme.firstDayOfWeek);
    final days = CalendarDateMath.days(start, 7);
    return Column(
      children: [
        _header(),
        const Spacer(),
        Row(
          children: [
            for (final day in days)
              Expanded(
                child: _WeekDay(
                  date: day,
                  selected: CalendarDateMath.isSameDay(day, selected),
                  theme: theme,
                  locale: data.locale,
                ),
              ),
          ],
        ),
        if (_large && data.events.isNotEmpty && theme.maximumEvents > 0) ...[
          const Spacer(),
          for (final event in data.events.take(
            theme.maximumEvents.clamp(0, 3),
          )) ...[
            _eventTile(event),
            SizedBox(height: theme.itemSpacing),
          ],
        ],
      ],
    );
  }

  Widget _agenda(BuildContext context) {
    final familyCount = _large
        ? 5
        : _wide
            ? 3
            : _compact
                ? 1
                : 2;
    final densityAdjustment = switch (theme.density) {
      CalendarHomeWidgetDensity.compact => -1,
      CalendarHomeWidgetDensity.spacious => 1,
      _ => 0,
    };
    final count = theme.maximumEvents == 0
        ? 0
        : (familyCount + densityAdjustment)
            .clamp(1, theme.maximumEvents)
            .toInt();
    final visibleEvents = data.events.take(count).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        SizedBox(height: theme.itemSpacing),
        if (visibleEvents.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                theme.showSubtitle && data.subtitle != null
                    ? data.subtitle!
                    : 'Nothing scheduled',
                style: TextStyle(color: theme.secondaryColor),
              ),
            ),
          )
        else
          for (final event in visibleEvents) ...[
            Expanded(child: _eventTile(event)),
            if (event != visibleEvents.last)
              Divider(height: theme.itemSpacing, color: theme.dividerColor),
          ],
      ],
    );
  }

  Widget _countdown(BuildContext context) {
    final target =
        CalendarDateMath.dateOnly(data.targetDate ?? data.selectedDate);
    final today = CalendarDateMath.dateOnly(data.generatedAt.toLocal());
    final days = CalendarDateMath.civilDayDifference(today, target).abs();
    if (_compact) {
      return Row(
        children: [
          FittedBox(
            child: Text(
              '$days',
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 54 * theme.typographyScale,
                fontWeight: FontWeight.w800,
                height: .9,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title ?? 'Countdown',
                  maxLines: 2,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  days == 1 ? 'day remaining' : 'days remaining',
                  style: TextStyle(color: theme.secondaryColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const Spacer(),
        FittedBox(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            '$days',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 62 * theme.typographyScale,
              fontWeight: FontWeight.w800,
              height: .9,
            ),
          ),
        ),
        Text(days == 1 ? 'day remaining' : 'days remaining'),
        if (theme.showSubtitle && data.subtitle != null)
          Text(data.subtitle!, style: TextStyle(color: theme.secondaryColor)),
      ],
    );
  }

  Widget _progress(BuildContext context) {
    final progress = data.totalCount <= 0
        ? 0.0
        : (data.completedCount / data.totalCount).clamp(0, 1).toDouble();
    if (_compact) {
      return Row(
        children: [
          SizedBox.square(
            dimension: 62,
            child: _compactProgressIndicator(progress),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title ?? 'Progress',
                  maxLines: 2,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${data.completedCount} of ${data.totalCount}',
                  style: TextStyle(color: theme.secondaryColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const Spacer(),
        Text(
          '${(progress * 100).round()}%',
          style: TextStyle(
            color: theme.accentColor,
            fontSize: 42 * theme.typographyScale,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text('${data.completedCount} of ${data.totalCount} complete'),
        if (theme.showProgress &&
            theme.progressStyle != CalendarHomeWidgetProgressStyle.hidden) ...[
          const SizedBox(height: 8),
          _progressIndicator(progress),
        ],
      ],
    );
  }

  Widget _compactProgressIndicator(double progress) {
    final percent = Text(
      '${(progress * 100).round()}%',
      style: const TextStyle(fontWeight: FontWeight.w800),
    );
    if (!theme.showProgress ||
        theme.progressStyle == CalendarHomeWidgetProgressStyle.hidden) {
      return Center(child: percent);
    }
    if (theme.progressStyle == CalendarHomeWidgetProgressStyle.circular) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 7,
            color: theme.accentColor,
            backgroundColor: theme.dividerColor,
          ),
          percent,
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        percent,
        const SizedBox(height: 6),
        _progressIndicator(progress),
      ],
    );
  }

  Widget _progressIndicator(double progress) => switch (theme.progressStyle) {
        CalendarHomeWidgetProgressStyle.circular => SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              color: theme.accentColor,
              backgroundColor: theme.dividerColor,
            ),
          ),
        CalendarHomeWidgetProgressStyle.segmented => Row(
            key: const ValueKey('calendar-home-widget-progress-segmented'),
            children: [
              for (var index = 0; index < 5; index++) ...[
                Expanded(
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: progress * 5 > index
                          ? theme.accentColor
                          : theme.dividerColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                if (index < 4) const SizedBox(width: 3),
              ],
            ],
          ),
        CalendarHomeWidgetProgressStyle.linear => ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              color: theme.accentColor,
              backgroundColor: theme.dividerColor,
            ),
          ),
        CalendarHomeWidgetProgressStyle.hidden => const SizedBox.shrink(),
      };

  Widget _nextEvent(BuildContext context) {
    final next = data.events.isEmpty ? null : data.events.first;
    if (_compact) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            next?.title ?? data.subtitle ?? 'Your calendar is clear',
            maxLines: 2,
            style: TextStyle(
              color: theme.foregroundColor,
              fontSize: 17 * theme.typographyScale,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (next != null)
            Text(
              _eventDetails(next),
              maxLines: 1,
              style: TextStyle(color: theme.secondaryColor, fontSize: 11),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const Spacer(),
        if (next == null)
          Text(
            data.subtitle ?? 'Your calendar is clear',
            style: TextStyle(color: theme.secondaryColor),
          )
        else ...[
          Text(
            next.title,
            maxLines: _large ? 3 : 2,
            style: TextStyle(
              fontSize: 22 * theme.typographyScale,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(_eventDetails(next),
              style: TextStyle(color: theme.secondaryColor)),
        ],
      ],
    );
  }

  Widget _eventTile(CalendarHomeWidgetEvent event) {
    final action = event.action;
    final eventColor = theme.useEventColors && event.colorValue != null
        ? Color(event.colorValue!)
        : theme.accentColor;
    final marker = switch (theme.eventStyle) {
      CalendarHomeWidgetEventStyle.bar => Container(
          key: const ValueKey('calendar-home-widget-event-bar'),
          width: theme.eventIndicatorWidth,
          height: 30,
          decoration: BoxDecoration(
            color: eventColor,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      CalendarHomeWidgetEventStyle.dot ||
      CalendarHomeWidgetEventStyle.card =>
        Container(
          key: theme.eventStyle == CalendarHomeWidgetEventStyle.dot
              ? const ValueKey('calendar-home-widget-event-dot')
              : const ValueKey('calendar-home-widget-event-card-dot'),
          width: theme.eventIndicatorWidth * 2,
          height: theme.eventIndicatorWidth * 2,
          decoration: BoxDecoration(color: eventColor, shape: BoxShape.circle),
        ),
      CalendarHomeWidgetEventStyle.minimal => null,
    };
    final tile = LayoutBuilder(
      builder: (context, constraints) {
        final showDetails = !constraints.hasBoundedHeight ||
            constraints.maxHeight >= 42 * theme.typographyScale;
        return Row(
          children: [
            if (marker != null) ...[
              marker,
              SizedBox(width: theme.itemSpacing + 2),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDetails)
                    Text(event.title, maxLines: 1)
                  else
                    Flexible(
                      child: FittedBox(
                        alignment: AlignmentDirectional.centerStart,
                        fit: BoxFit.scaleDown,
                        child: Text(event.title, maxLines: 1),
                      ),
                    ),
                  if (showDetails)
                    Text(
                      _eventDetails(event),
                      maxLines: 1,
                      style:
                          TextStyle(color: theme.secondaryColor, fontSize: 11),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
    final styledTile = theme.eventStyle == CalendarHomeWidgetEventStyle.card
        ? DecoratedBox(
            key: const ValueKey('calendar-home-widget-event-card'),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                eventColor.withValues(alpha: .12),
                theme.backgroundColor,
              ),
              borderRadius: BorderRadius.circular(
                theme.cornerRadius.clamp(6, 14).toDouble(),
              ),
              border: Border.all(color: eventColor.withValues(alpha: .2)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.itemSpacing + 4,
                vertical: theme.itemSpacing.clamp(3, 8).toDouble(),
              ),
              child: tile,
            ),
          )
        : tile;
    return action == null || onAction == null
        ? styledTile
        : GestureDetector(onTap: () => onAction!(action), child: styledTile);
  }

  String _eventDetails(CalendarHomeWidgetEvent event) {
    final location = theme.showLocation ? event.location : null;
    final subtitle = theme.showSubtitle ? event.subtitle : null;
    if (event.isAllDay || !theme.showEventTime) {
      return [if (subtitle != null) subtitle, if (location != null) location]
          .join(' · ')
          .ifEmpty('All day');
    }
    final use24 = data.use24HourTime ?? false;
    final format = DateFormat(use24 ? 'HH:mm' : 'jm', data.locale);
    final time = '${format.format(event.start)}–${format.format(event.end)}';
    return [
      time,
      if (subtitle != null) subtitle,
      if (location != null) location
    ].join(' · ');
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    required this.date,
    required this.selected,
    required this.theme,
    required this.locale,
  });

  final DateTime date;
  final bool selected;
  final CalendarHomeWidgetTheme theme;
  final String? locale;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (theme.showWeekday &&
                theme.weekdayFormat != CalendarHomeWidgetWeekdayFormat.hidden)
              FittedBox(
                child: Text(
                  switch (theme.weekdayFormat) {
                    CalendarHomeWidgetWeekdayFormat.narrow =>
                      DateFormat.E(locale).format(date).characters.first,
                    CalendarHomeWidgetWeekdayFormat.short =>
                      DateFormat.E(locale).format(date),
                    CalendarHomeWidgetWeekdayFormat.full =>
                      DateFormat.EEEE(locale).format(date),
                    CalendarHomeWidgetWeekdayFormat.hidden => '',
                  },
                  style: TextStyle(color: theme.secondaryColor, fontSize: 10),
                ),
              ),
            const SizedBox(height: 4),
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selected &&
                          theme.dateShape != CalendarHomeWidgetDateShape.none
                      ? theme.accentColor
                      : Colors.transparent,
                  shape: theme.dateShape == CalendarHomeWidgetDateShape.circle
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: theme.dateShape ==
                          CalendarHomeWidgetDateShape.circle
                      ? null
                      : BorderRadius.circular(
                          theme.dateShape == CalendarHomeWidgetDateShape.rounded
                              ? 10
                              : theme.dateShape ==
                                      CalendarHomeWidgetDateShape.square
                                  ? 2
                                  : 0,
                        ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: selected &&
                                theme.dateShape !=
                                    CalendarHomeWidgetDateShape.none
                            ? theme.backgroundColor
                            : theme.foregroundColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

/// Dependency-free platform bridge for native calendar home widgets.
class CalendarHomeWidgetBridge {
  /// Creates a bridge using the package channel by default.
  const CalendarHomeWidgetBridge({
    MethodChannel channel = const MethodChannel(
      'dev.ahmedzaeem.horizontal_weekly_calendar/home_widgets',
    ),
  }) : _channel = channel;

  final MethodChannel _channel;

  /// Saves [data] and asks every native calendar widget to refresh.
  ///
  /// When supplied, [configuration] is nested into the schema-v1 data map so
  /// older hosts can ignore it while current hosts apply portable theme tokens.
  ///
  /// Returns `false` when the current platform has no registered host.
  Future<bool> update(
    CalendarHomeWidgetData data, {
    CalendarHomeWidgetConfiguration? configuration,
  }) async {
    try {
      final payload = data.toJson();
      if (configuration != null) {
        payload['configuration'] = configuration.toJson();
      }
      return await _channel.invokeMethod<bool>('update', payload) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Requests refresh from the payload already stored by the native host.
  Future<bool> refresh() async {
    try {
      return await _channel.invokeMethod<bool>('refresh') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
