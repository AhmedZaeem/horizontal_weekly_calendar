# Horizontal Weekly Calendar 2.0 — Completeness Addendum

**Author:** Ahmed Zaeem  
**Date:** 2026-08-10  
**Status:** Approved  
**Reviewer:** Ahmed Zaeem  
**Related spec:** `v2_product_definition.md`  
**Approval source:** Direct implementation request, 2026-08-10

## Context

The approved 2.0 product definition established a reliable horizontal-first
calendar, shared month/foldable/agenda/timeline surfaces, typed events, adaptive
themes, and source-compatible 1.x migration. The remaining gap is breadth at
the presentation layer: applications still need richer motion choices,
additional recognizable visual personalities, native date-selection surfaces,
and compact horizontal data visualizations without replacing the calendar
engine with custom code.

This addendum completes the UI-kit layer without changing the existing 2.0
constructors or the deprecated 1.x library. The work is additive: new
configuration defaults preserve current behavior, every visual surface shares
the existing civil-date and selection rules, and the example becomes a
capture-oriented catalogue of the complete public API.

## Functional Requirements

### Motion system

- FR-1: `CalendarMotion` MUST provide named `none`, `subtle`, `fluid`,
  `spring`, and `playful` presets.
- FR-2: Motion configuration MUST independently control selection, page,
  event, hover, and fold transitions through typed enums and duration/curve
  values.
- FR-3: Existing constructors MUST preserve their current motion when no
  `CalendarMotion` is supplied.
- FR-4: All calendar motion MUST become immediate when
  `MediaQuery.disableAnimations` is true.
- FR-5: Selection motion MUST not change layout dimensions or cause date cells
  to lose semantics, focus, or hit targets.

### Design systems and native adaptation

- FR-6: `CalendarStyle` MUST add Material Expressive, Cupertino glass,
  minimal, pill, soft, neon, and monochrome style families.
- FR-7: Every added style MUST resolve through the same
  `HorizontalCalendarThemeData` token contract in light and dark brightness.
- FR-8: Explicit Material and Cupertino families MUST retain 48 and 44 logical
  pixel minimum interactive dimensions respectively.
- FR-9: `AdaptiveCalendarNavigationBar` MUST render Material controls on
  Android/Fuchsia and Cupertino controls on iOS/macOS while keeping
  chronological previous/next callbacks.
- FR-10: `showAdaptiveCalendarPicker` MUST present a Material modal bottom
  sheet or Cupertino modal popup according to the resolved platform and return
  a normalized selected civil date or `null`.
- FR-11: The adaptive picker MUST support inclusive bounds, disabled-day
  predicates, custom appearance, locale-aware month labels, and today/cancel
  actions.

### Horizontal application components

- FR-12: `CalendarDateCarousel<T>` MUST display horizontally scrollable date
  cards with typed metadata, selection, events, configurable card extent,
  snapping, and a complete custom card builder.
- FR-13: Carousel cards MUST use contiguous unique civil dates and the shared
  bounds, event bucketing, semantics, and appearance contracts.
- FR-14: `CalendarHeatmapStrip` MUST visualize normalized per-date intensity in
  a horizontal strip with configurable levels, colors, labels, and callbacks.
- FR-15: Heatmap intensity values MUST clamp safely to the range 0 through 1
  and missing values MUST render as zero.
- FR-16: `CalendarStreakStrip` MUST visualize completed, missed, future, today,
  and selected dates with configurable labels and callbacks.
- FR-17: Heatmap and streak strips MUST remain usable at 280 logical pixels,
  text scale 2.0, and both text directions without overflow.
- FR-18: All new components MUST be independently usable without a calendar
  ancestor or controller.

### Compatibility, gallery, and release material

- FR-19: `weekly_calendar.dart` MUST retain every 1.3 public symbol and
  constructor unchanged, with replacement-specific deprecation messages.
- FR-20: New 2.0 APIs MUST be exported only from
  `horizontal_weekly_calendar.dart`.
- FR-21: The example MUST provide filterable categories for horizontal,
  native, motion, events, planning, data-visualization, and custom scenarios.
- FR-22: The example MUST expose live style, motion, brightness, density, RTL,
  high-contrast, and text-scale controls.
- FR-23: The example MUST provide individual distraction-free capture routes
  for hero, styles, motion, foldable, native, planning, and data scenarios.
- FR-24: README MUST document quick start, motion, style families, native
  picker/navigation, carousel, heatmap, streak, events, foldable, agenda,
  timelines, legacy migration, and gallery capture routes with runnable code.
- FR-25: CHANGELOG MUST contain a complete dated 2.0.0 entry covering the
  original 2.0 work and this addendum.

## Non-Functional Requirements

- NFR-1: All existing tests MUST continue to pass without changing legacy
  behavior assertions.
- NFR-2: New widgets MUST render without framework exceptions at widths 280,
  320, 375, 430, 768, and 1440 and text scales 1.0 and 2.0.
- NFR-3: Public APIs MUST have dartdoc coverage and must not add a runtime
  dependency beyond Flutter and `intl`.
- NFR-4: A 31-card carousel and a 366-day heatmap MUST build in under 100 ms on
  the documented development machine after warm-up.
- NFR-5: Every interactive date MUST expose a stable semantic identifier and a
  localized readable label.
- NFR-6: Formatting, Flutter analysis, all tests, example analysis/tests,
  release web build, WASM dry run, publish dry run, and `pana` MUST complete
  with no code-quality defect and the maximum attainable pub score.
- NFR-7: New public APIs MUST NOT remove, rename, or make required an existing
  parameter from either the 1.x compatibility library or the current 2.0 API.

## Acceptance Criteria

### AC-1: Motion presets (FR-1, FR-2, FR-3, FR-4, FR-5)

Given each named motion preset and a selected date, when selection or focus
changes, then the configured transition is used without changing the cell's
size, semantics, or hit target; when animations are disabled, it settles in one
pump.

### AC-2: Expanded styles (FR-6, FR-7, FR-8)

Given every added style in light and dark brightness, when its tokens resolve,
then all tokens are complete, readable, and use the documented native minimum
target dimension.

### AC-3: Native navigation (FR-9)

Given Android and iOS target platforms, when the adaptive navigation bar is
built, then the platform-specific control family renders and previous/next
remain chronological in LTR and RTL.

### AC-4: Native picker (FR-10, FR-11)

Given a bounded picker with one disabled date, when a user opens it and taps an
enabled date, then the normalized date is returned; cancel returns `null` and
the disabled date cannot complete the picker.

### AC-5: Date carousel (FR-12, FR-13, NFR-2, NFR-5)

Given a compact viewport with events and typed metadata, when the carousel
renders and a card is selected, then dates are unique and contiguous, callbacks
retain the typed item, semantics remain readable, and no overflow occurs.

### AC-6: Heatmap strip (FR-14, FR-15, FR-17, NFR-2)

Given missing, negative, fractional, and greater-than-one intensity values,
when the heatmap renders, then values resolve to 0, 0, the fraction, and 1,
respectively, callbacks return the correct date, and no overflow occurs.

### AC-7: Streak strip (FR-16, FR-17, NFR-2, NFR-5)

Given completed, missed, today, future, and selected dates, when the streak
renders in LTR and RTL at text scale 2.0, then each state has a distinct token,
stable semantics, correct callback, and no overflow.

### AC-8: Legacy and additive API (FR-18, FR-19, FR-20, NFR-1, NFR-7)

Given the legacy fixtures and existing 2.0 fixtures, when compiled against the
expanded package, then they pass unchanged and the new APIs compile only from
the 2.0 barrel.

### AC-9: Gallery and documentation (FR-21, FR-22, FR-23, FR-24, FR-25)

Given an evaluator running the example, when they select any category or
capture route, then every requested surface is visible, interactive, and built
from documented public APIs, and README/CHANGELOG describe the same behavior.

### AC-10: Release gate (NFR-3, NFR-4, NFR-6)

Given the completed package, when all release commands execute, then the full
suite passes, benchmarks remain below 100 ms, documentation has no warnings,
WASM is ready, and `pana` reports the maximum score.

## Edge Cases

- EC-1: Zero-duration motion, runtime motion-preset changes, rapid selection,
  widget disposal mid-transition, and disabled animations.
- EC-2: Platform override differs from the host OS, RTL reverses visual icons,
  and one navigation direction is unavailable at a bound.
- EC-3: Picker bounds contain one date, today is outside bounds, every date in
  the visible month is disabled, and the picker is dismissed externally.
- EC-4: Carousel count is 1 or 31, metadata is absent, events cross midnight,
  item extent exceeds viewport width, and selection is outside the page.
- EC-5: Heatmap has an empty map, sparse values, NaN/infinity, negative values,
  values above one, a one-color palette, and 366 dates.
- EC-6: Streak range crosses December/January and leap day, future dates are
  present, and no dates are complete.
- EC-7: Text scale changes during motion; high contrast, bold text, dark mode,
  and RTL change at runtime.
- EC-8: Legacy applications import only `weekly_calendar.dart`; modern
  applications import only `horizontal_weekly_calendar.dart`.

## API Contracts

This package has no network endpoint. `POST /not-applicable` records that its
contracts are in-process Dart APIs and that no HTTP request is performed.

```typescript
interface CalendarMotionContract {
  preset: "none" | "subtle" | "fluid" | "spring" | "playful";
  selection: "none" | "fade" | "scale" | "slide" | "bounce";
  page: "none" | "slide" | "fadeThrough" | "scale";
  events: "none" | "fade" | "scale";
  durationMilliseconds: number;
}

interface CalendarCarouselItem<T> {
  date: Date;
  data?: T;
  title?: string;
  subtitle?: string;
  badge?: string;
}

interface CalendarHeatmapValue {
  date: Date;
  intensity: number;
}
```

```dart
CalendarAppearance(
  style: CalendarStyle.cupertinoGlass,
  motion: CalendarMotion.spring(),
)

Future<DateTime?> showAdaptiveCalendarPicker({
  required BuildContext context,
  required DateTime initialDate,
  CalendarDateRange? bounds,
  bool Function(DateTime date)? selectableDayPredicate,
  CalendarAppearance appearance = const CalendarAppearance(),
});

CalendarDateCarousel<T>({
  required DateTime startDate,
  required int dayCount,
  required DateTime selectedDate,
  required ValueChanged<DateTime> onDateSelected,
  List<CalendarCarouselItem<T>> items = const [],
  List<CalendarEvent<T>> events = const [],
  CalendarAppearance appearance = const CalendarAppearance(),
});

CalendarHeatmapStrip({
  required DateTime startDate,
  required int dayCount,
  Map<DateTime, double> values = const {},
  ValueChanged<DateTime>? onDateTap,
});

CalendarStreakStrip({
  required DateTime startDate,
  required int dayCount,
  Set<DateTime> completedDates = const {},
  DateTime? selectedDate,
  ValueChanged<DateTime>? onDateTap,
});
```

## Data Models

### CalendarMotion

| Field | Type | Constraints |
|---|---|---|
| selection | enum | Required, defaults to scale |
| page | enum | Required, defaults to slide |
| events | enum | Required, defaults to fade |
| duration | Duration | Non-negative |
| curve | Curve | Required |
| stagger | Duration | Non-negative |
| hoverScale | double | At least 1.0 |

### CalendarCarouselItem<T>

| Field | Type | Constraints |
|---|---|---|
| date | DateTime | Normalized by civil identity |
| data | T? | Original typed payload |
| title | String? | Optional visible label |
| subtitle | String? | Optional visible label |
| badge | String? | Optional compact badge |

### CalendarHeatmap value

| Field | Type | Constraints |
|---|---|---|
| date key | DateTime | Compared by civil identity |
| intensity | double | Finite; clamped to 0 through 1 |

### CalendarStreak state

| Field | Type | Constraints |
|---|---|---|
| completedDates | Set<DateTime> | Compared by civil identity |
| selectedDate | DateTime? | Optional selected civil date |
| today | DateTime | Resolved at build time unless supplied for testing |

## Out of Scope

- OS-1: Persistence, synchronization, accounts, and remote calendar-provider
  integrations — these are application data concerns, not UI-kit behavior.
- OS-2: A recurring-event rule engine and timezone database — typed events can
  receive already-expanded occurrences without adding heavy runtime data.
- OS-3: Drag-to-reschedule and resource scheduling — these require a separate
  interaction and conflict-resolution specification.
- OS-4: Full-screen appointment creation forms — applications own their domain
  fields and validation.
- OS-5: Replacing the original 1.x rendering — compatibility code remains
  frozen except for correctness fixes required to keep it usable.
