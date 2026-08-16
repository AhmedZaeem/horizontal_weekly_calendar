# Horizontal Weekly Calendar 2.0 — Product Definition

**Author:** Ahmed Zaeem  
**Date:** 2026-08-04  
**Status:** Approved  
**Reviewer:** Ahmed Zaeem  
**Target:** `horizontal_weekly_calendar` 2.0.0

**Approval source:** Project conversation, 2026-08-04

## Context

`horizontal_weekly_calendar` became useful because it solved one focused job:
putting an approachable horizontal week selector into a Flutter app. Version
2.0 must strengthen that identity rather than imitate a generic enterprise
scheduler.

The current market separates into feature-rich month tables and large calendar
frameworks. `table_calendar` is strong at month/week tables and builders;
`calendar_view` and `kalender` are strong at event-heavy day, week, month, and
schedule views. Version 2.0 will compete through a better horizontal-first
experience: dramatically easier setup, premium built-in presentation,
correctness across civil-date boundaries, coherent supporting widgets, and a
gallery that demonstrates production-quality results immediately.

The library itself is the visual source of truth. Figma, external design files,
and generated mockups are not delivery dependencies. Every visual decision must
exist as a documented Flutter token, preset, component, example, and test.

### Product promise

> The easiest way to add a beautiful, reliable, fully customizable horizontal
> calendar to a Flutter app—and the UI kit to build the calendar experience
> around it.

### Product principles

1. **Horizontal first.** The flagship strip receives the strongest API, design,
   interaction, accessibility, performance, documentation, and testing work.
2. **Beautiful before customization.** Defaults must look launch-ready without
   requiring builders or copied theme code.
3. **Progressive disclosure.** A common single-date calendar takes three lines;
   advanced controlled selection, events, and builders remain available.
4. **Native adaptation.** Material and Cupertino presets differ in controls,
   target sizes, feedback, motion, shape, and typography—not only color.
5. **Composable, not fragmented.** Every calendar surface shares date identity,
   selection, events, controllers, tokens, callbacks, and semantics.
6. **Correct by construction.** Civil dates, ranges, pages, months, and events
   cannot skip or duplicate dates around years, leap days, or DST.
7. **Marketing-grade examples.** The gallery must be strong enough to record as
   the launch video without building a separate showcase application.
8. **Migration without fear.** Version 1.x remains importable and deprecated;
   existing apps continue to compile while migrating deliberately.

## Functional Requirements

### Flagship ease and API hierarchy

- FR-1: The default `HorizontalCalendar` constructor MUST require only a
  controlled `selectedDate` and `onDateSelected` callback.
- FR-2: The default constructor MUST infer focus from `selectedDate`, render
  seven dates, use the ambient locale, and resolve an adaptive platform preset.
- FR-3: `HorizontalCalendar.controlled` MUST expose focused date, single,
  multiple, or range selection, navigation callbacks, bounds, predicate,
  visible-day count, first weekday, events, controller, builders, and theme.
- FR-4: Common customization MUST use typed configuration objects rather
  than a constructor containing dozens of unrelated visual parameters.
- FR-5: Every public option MUST alter tested behavior; speculative or dead
  configuration MUST NOT be public.
- FR-6: All advanced widgets MUST remain independently usable without an
  ancestor calendar or inherited controller.

### Horizontal experience

- FR-7: The strip MUST render a contiguous, ordered, unique civil-date page.
- FR-8: It MUST support page swipe, tap selection, keyboard navigation,
  previous/next/today controls, programmatic focus, RTL, and bounds.
- FR-9: It MUST support 1 through 31 visible dates without `RenderFlex`
  overflow; compact viewports MUST scroll or reduce density deliberately.
- FR-10: Day state MUST include date, today, selected, range position,
  focused, disabled, outside interval, event count, and semantic label.
- FR-11: Event indicators MUST support dot, count, bar, stack, and custom
  builder presentations without changing event bucketing.
- FR-12: Consumers MUST be able to enable snap paging or free horizontal
  scrolling through typed behavior configuration.
- FR-13: Selection and page motion MUST remain interruptible, converge on the
  latest state, and honor `MediaQuery.disableAnimations`.

### Code-native visual system

- FR-14: The package MUST ship complete adaptive, Material 3, Cupertino,
  neutral, glass, editorial, and bold theme presets.
- FR-15: Presets MUST be expressed through `HorizontalCalendarThemeData`, a
  documented `ThemeExtension` with `copyWith` and `lerp`.
- FR-16: Themes MUST expose semantic color, typography, spacing, radius,
  target-size, elevation, marker, event-tile, and motion tokens.
- FR-17: Density MUST be independent from visual style and support compact,
  comfortable, and spacious modes.
- FR-18: Consumers MUST be able to override one token, provide a full custom
  theme, or replace focused components through builders.
- FR-19: Light, dark, and high-contrast values MUST be complete for every
  bundled preset.

### Calendar UI kit

- FR-20: `FoldableCalendar` MUST morph between the focused horizontal week
  and an exact-height month grid using tap, drag, and controller actions.
- FR-21: `MonthCalendar` MUST support natural four/five/six-row months,
  outside-month visibility, selection modes, events, bounds, and builders.
- FR-22: `CalendarAgenda` MUST group events by civil date and provide empty,
  loading, error, refresh, section-header, and event-tile builders.
- FR-23: `DayTimeline` and `WeekTimeline` MUST support configurable hour
  bounds, interval height, all-day events, current-time indicator, deterministic
  overlaps, and original typed-event callbacks.
- FR-24: The package MUST expose reusable `CalendarHeader`,
  `CalendarDayCell`, `CalendarEventMarker`, `CalendarEventTile`,
  `CalendarNowIndicator`, and `CalendarFoldHandle` components.
- FR-25: All UI-kit surfaces MUST share the same event, selection, theme,
  locale, semantics, and controller vocabulary.

### Events and data loading

- FR-26: `CalendarEvent<T>` MUST retain original typed payload, stable ID,
  title, start, exclusive end, all-day state, color, and optional semantics.
- FR-27: Cross-midnight and multi-day events MUST appear once on every
  intersected civil date; duplicate source IDs MUST appear once per date.
- FR-28: Timed-event overlap columns MUST be deterministic and connected
  overlap chains MUST share one collision group.
- FR-29: Synchronous lists and async `CalendarEventSource<T>` MUST use the
  same widgets and callback types.
- FR-30: Async sources MUST expose loading/error states, deduplicate unchanged
  interval requests, ignore stale out-of-order results, and tolerate disposal.

### Interaction and accessibility

- FR-31: Material targets MUST be at least 48 logical pixels and Cupertino
  targets at least 44 logical pixels, using scroll when seven columns cannot fit.
- FR-32: Interactive dates MUST expose localized full-date semantics plus
  selected, today, disabled, range, and event-count state.
- FR-33: Keyboard users MUST be able to move by day/week, activate, jump to
  today, page, and toggle fold state in chronological focus order.
- FR-34: Visual navigation and gestures MUST mirror in RTL while controller
  previous/next methods retain chronological meaning.
- FR-35: Text scale 2.0, bold text, high contrast, and reduced motion MUST
  produce no overflow, clipped essential information, or framework exception.
- FR-36: Platform-appropriate feedback MAY include haptics but MUST be
  configurable and MUST NOT be required for correct interaction.

### Compatibility, gallery, and documentation

- FR-37: `weekly_calendar.dart` MUST keep every 1.3 public symbol and
  constructor source-compatible with replacement-specific deprecation messages.
- FR-38: The v2 API MUST be exported only from
  `horizontal_weekly_calendar.dart` and MUST not import the legacy barrel.
- FR-39: The standalone example MUST present a polished gallery with:
  adaptive quick start, Material, Cupertino, glass, editorial, bold, foldable,
  event-rich strip, agenda, day timeline, week timeline, RTL, large text, dark,
  high contrast, and custom-builder scenarios.
- FR-40: Gallery scenarios MUST share realistic seeded event data and support
  live style, brightness, density, locale-direction, and text-scale controls.
- FR-41: The gallery MUST include a distraction-free showcase route sized for
  screen recording and launch-video capture.
- FR-42: README examples MUST be runnable, begin with the three-line setup,
  and cover presets, advanced control, events, foldable, agenda, and timelines.
- FR-43: A migration guide MUST map every 1.3 type and parameter to v2.

## Non-Functional Requirements

### NFR-1 Correctness: Exhaustive tests MUST cover every month from 1900-01
  through 2100-12, all first weekdays, leap years, cross-year pages, and available
  DST fixtures with no missing or duplicate civil dates.
### NFR-2 Layout: Widths 280, 320, 375, 430, 768, and 1440 at text scales 1.0,
  1.3, 1.6, and 2.0 MUST have zero overflow or framework exceptions.
### NFR-3 Stress: 500 deterministic randomized combinations of bounds, focus,
  selection, visible count, events, direction, width, and text scale MUST pass.
### NFR-4 Performance: A warmed seven-day page change SHOULD build within one
  16 ms frame at p95 on the documented reference environment.
### NFR-5 Event performance: Layout of 1,000 events in seven visible days MUST
  complete under 100 ms on the documented development machine.
### NFR-6 Accessibility: Default foreground pairs MUST meet WCAG 2.2 AA and
  automated semantics tests MUST cover every interactive flagship/foldable state.
### NFR-7 Dependencies: Runtime dependencies MUST remain limited to Flutter SDK
  and `intl` unless an additional dependency has a documented, measured benefit.
### NFR-8 Quality: Formatting, analysis, all tests, example analysis, publish
  dry-run, and the maximum attainable `pana` score MUST pass.
### NFR-9 Maintenance: Domain, controller, loading, theme, composables, and
  feature widgets MUST remain separate acyclic layers.
### NFR-10 Public API: Exported types MUST have documentation and runnable
  examples; internal implementation details MUST not leak unintentionally.

## Acceptance Criteria

### AC-1: Quick start (FR-1)

Requirements: FR-1, FR-2, FR-3, FR-4, FR-5, FR-6.

Given a new consumer, when they paste the documented
  quick start, then a selected, localized, adaptive seven-day calendar works with
  no theme or controller setup.
### AC-2: Horizontal correctness and resilience

Requirements: FR-7, FR-8, FR-9, FR-10, FR-11, FR-12, FR-13, NFR-1, NFR-2, NFR-3.

Given every tested date/layout combination,
  when the strip renders and navigates, then dates are contiguous and unique and
  no layout exception occurs.
### AC-3: Visual system

Requirements: FR-14, FR-15, FR-16, FR-17, FR-18, FR-19, NFR-6.

Given every preset and brightness/contrast mode,
  when tokens resolve, then all semantic tokens are non-null, platform targets
  are correct, and required contrast ratios pass.
### AC-4: UI-kit independence

Requirements: FR-20, FR-21, FR-22, FR-23, FR-24, FR-25.

Given any UI-kit widget without an ancestor calendar,
  when it renders and receives input, then it uses shared models/themes and works
  independently.
### AC-5: Latest fold state wins

Requirement: FR-20.

Given rapid or reversed fold commands, when motion settles,
  then the latest requested state wins, focus and selection remain visible, and
  the final height exactly matches the week or natural month.
### AC-6: Event identity, layout, and loading

Requirements: FR-26, FR-27, FR-28, FR-29, FR-30, NFR-5.

Given duplicate, overlapping, cross-midnight,
  multi-day, stale async, and 1,000-event fixtures, when loaded and laid out,
  then identity, date assignment, ordering, state, and performance are correct.
### AC-7: Accessible interaction

Requirements: FR-31, FR-32, FR-33, FR-34, FR-35, FR-36, NFR-2, NFR-6.

Given keyboard, RTL, text scale 2.0,
  high contrast, and reduced motion, when users operate every control, then
  semantics, chronological behavior, target sizes, and layouts remain correct.
### AC-8: Legacy compatibility

Requirements: FR-37, FR-38.

Given the 1.3 compatibility fixture, when compiled with
  v2, then it succeeds with only expected deprecation diagnostics.
### AC-9: Gallery and documentation

Requirements: FR-39, FR-40, FR-41, FR-42, FR-43.

Given a package evaluator, when they run the gallery and
  documentation, then every scenario is discoverable, interactive, visually
  polished, and reproducible from documented public APIs.
### AC-10: Release quality

Requirements: NFR-7, NFR-8, NFR-9, NFR-10.

Given the release candidate, when all quality gates
  run, then they exit successfully with the maximum attainable pub score.

## Edge Cases

- EC-1: Minimum and maximum are the same civil day; reversed bounds fail with
  an actionable assertion/error.
- EC-2: Visible count is 1 or 31 and the viewport is narrower than one or all
  preferred target widths.
- EC-3: Focus or selection lies outside bounds; controlled state does not
  trigger callback loops.
- EC-4: February 29, non-leap centuries, year 2000, December/January, local
  DST transitions, UTC, and non-whole-hour local offsets where available.
- EC-5: Empty, long, and multi-grapheme localized labels in LTR and RTL.
- EC-6: Rapid page/fold commands, controller replacement, disposal during
  motion/loading, and `disableAnimations` changing mid-motion.
- EC-7: No events, duplicate IDs, identical starts, nested/chained overlaps,
  all-day, midnight end, multi-day, thousands of events, and source errors.
- EC-8: Nested horizontal scrollables and fold vertical-drag arbitration.
- EC-9: Runtime changes among preset, custom theme, density, brightness,
  contrast, direction, text scale, and locale.
- EC-10: Consumer declines a controlled callback proposal; rendered state
  continues to reflect supplied values.

## API Contracts

This package has no HTTP API. `POST /not-applicable` records that the contract is
an in-process Dart widget API.

```typescript
interface CalendarContractMarker {
  transport: "in-process Dart API";
  networkEndpoint: false;
}
```

```dart
HorizontalCalendar(
  selectedDate: selectedDate,
  onDateSelected: (date) => setState(() => selectedDate = date),
)

HorizontalCalendar.controlled<T>({
  required DateTime focusedDate,
  required CalendarSelection selection,
  required ValueChanged<DateTime> onFocusedDateChanged,
  required CalendarSelectionChanged onSelectionChanged,
  HorizontalCalendarController? controller,
  CalendarDateRange? bounds,
  CalendarBehavior behavior = const CalendarBehavior(),
  CalendarAppearance appearance = const CalendarAppearance(),
  List<CalendarEvent<T>> events = const [],
  CalendarEventSource<T>? eventSource,
  CalendarBuilders<T> builders = const CalendarBuilders(),
})
```

```dart
enum CalendarStyle { adaptive, material, cupertino, neutral }
enum CalendarDensity { compact, comfortable, spacious }
enum CalendarFoldState { collapsed, expanded }
enum OutsideMonthVisibility { hidden, visible, visibleDisabled }
enum EventIndicatorStyle { dot, count, bar, stack }
enum CalendarScrollBehavior { page, free }

@immutable
class CalendarBehavior {
  final int visibleDayCount;
  final int firstDayOfWeek;
  final CalendarScrollBehavior scrolling;
  final bool enableHaptics;
  final bool enableKeyboard;
  final bool enableGestures;
}

@immutable
class CalendarAppearance {
  final CalendarStyle style;
  final CalendarDensity density;
  final EventIndicatorStyle eventIndicatorStyle;
  final HorizontalCalendarThemeData? theme;
}
```

The exact Dart generics and constructor forwarding MAY be refined during API
tests, but the three-line default and grouped advanced configuration MUST remain.

## Data Models

| Model | Required invariants |
| --- | --- |
| Civil date | Year/month/day identity; normalized; civil constructor arithmetic |
| `CalendarDateRange` | Inclusive ordered normalized endpoints |
| `CalendarSelection` | One explicit mode; immutable; normalized; unique multiple dates |
| `CalendarVisibleInterval` | Start inclusive, end exclusive, non-empty |
| `CalendarEvent<T>` | Stable ID; `end > start`; original payload preserved |
| Event segment | One source ID per intersected date; clipped half-open times |
| Controller | Normalized focus, selection, fold state, latest accepted command |
| Theme | Complete semantic values; immutable; interpolatable |

## Architecture

```text
public easy API / advanced API / legacy facade
                  |
feature widgets --+-- public composables
                  |
controller + async event coordinator + resolved theme
                  |
selection / civil-date / event-layout domain
```

Dependencies flow downward only. The legacy facade does not enter the v2 graph.

## Delivery Order

1. Freeze the easy/advanced API and grouped configurations with compile tests.
2. Refactor shared public composables and complete premium theme presets.
3. Finish horizontal paging, gestures, keyboard, RTL, semantics, and stress tests.
4. Finish foldable drag/motion and independent month calendar.
5. Build async event coordinator, agenda, day timeline, and week timeline.
6. Replace the example with the interactive launch gallery/showcase route.
7. Complete migration/docs/goldens/benchmarks/CI/pub quality gates.

## Out of Scope

- OS-1: ICS parsing, recurrence expansion, account sync, persistence,
  reminders, notifications, authentication, and network APIs.
- OS-2: Resource/room scheduling, drag-to-create, drag-to-resize, or calendar
  database behavior in 2.0.0.
- OS-3: A non-Gregorian chronology engine; localized Gregorian presentation
  remains supported.
- OS-4: Figma or any external design file as a blocker or source of truth.
- OS-5: A separate marketing website or video production in this phase; the
  gallery and showcase route prepare assets for that later work.
- OS-6: Push, tag, release, publish, or remote repository mutation without
  separate explicit owner authorization.

## Definition of Done

Version 2.0 is ready for owner review when AC-1 through AC-10 pass, the gallery
is suitable for direct screen recording, every retained 1.3 example compiles,
the quality gates meet NFR-8, and no content has been pushed, tagged, published,
or released.
