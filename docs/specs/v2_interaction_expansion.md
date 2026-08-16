# Horizontal Weekly Calendar 2.0 — Interaction Expansion

**Author:** Ahmed Zaeem  
**Date:** 2026-08-10  
**Status:** Approved  
**Reviewer:** Ahmed Zaeem  
**Related specs:** `v2_product_definition.md`, `v2_completeness_addendum.md`  
**Approval source:** Direct implementation request, 2026-08-10

## Context

The first 2.0 implementation established a reliable civil-date engine, a
horizontal-first calendar, shared month and foldable surfaces, event views,
adaptive themes, and source-compatible 1.x migration. Hands-on review exposed
two interaction gaps: the date carousel's page mode treats every card as a
full-width page and does not follow an externally changed selection, while a
controlled gallery example discards selection proposals and therefore appears
unselectable. Both undermine the package's easy-to-use promise.

Current Flutter calendar packages repeatedly expose selection modes, range
rules, bounds, disabled dates, controllers, custom indicators, locale support,
and native pickers. Cupertino date controls additionally rely on familiar
wheel presentation, explicit confirmation actions, and modal placement. More
experimental date interfaces use celestial motion, but often bind calendar
units directly to orbital bodies or leave gestures incomplete. This expansion
will use those observations as product requirements without copying a visual
mapping or implementation.

The work is additive. Existing v2 constructors retain their defaults, the
complete 1.3 entrypoint remains available and deprecated, and all new
components use the same normalized civil-date, selection, bounds, appearance,
motion, localization, and accessibility contracts.

## Functional Requirements

### Carousel reliability

- FR-1: `CalendarDateCarousel` MUST show cards at their configured extent in
  both free and snapping modes instead of expanding each card to a full
  viewport.
- FR-2: Snapping mode MUST expose adjacent-card context when the viewport is
  wider than one card and MUST snap one card at a time.
- FR-3: The carousel MUST reveal the controlled selected date after initial
  layout and after the selected date changes when that date is visible.
- FR-4: The carousel MUST provide an optional imperative controller for
  revealing a date without changing selection.
- FR-5: The existing carousel constructor MUST remain a controlled
  single-date API with the same required parameters.
- FR-6: A controlled carousel constructor MUST accept `CalendarSelection` and
  `CalendarSelectionChanged` for single, multiple, and range modes.
- FR-7: A selected carousel card MUST report its typed item through an optional
  item callback while preserving the existing date callback.
- FR-8: Default carousel cards MUST remain overflow-free with a badge, title,
  subtitle, three event markers, 280 logical pixels, and text scale 2.0.

### Predictable selection

- FR-9: `CalendarSelectionBehavior` MUST configure same-date single selection,
  empty multiple selection, a maximum multiple-selection count, completed
  range taps, and an optional maximum range length.
- FR-10: Horizontal, month, foldable, carousel, and date-picker surfaces MUST
  use the same `CalendarSelectionLogic` transition for equivalent input.
- FR-11: Existing selection behavior MUST remain the default when no selection
  behavior is supplied.
- FR-12: Every accepted interaction MUST emit exactly one normalized selection
  proposal; disabled or rejected interactions MUST emit none.
- FR-13: `MonthCalendar.single` and `FoldableCalendar.single` MUST provide
  simple single-date callbacks without requiring callers to construct a
  `CalendarSelection`.
- FR-14: Gallery examples MUST persist every selection proposal they expose
  and MUST label single, multiple, and range behavior explicitly.

### Calendar transitions

- FR-15: `CalendarPageTransition` MUST add shared-axis, zoom, and flip options
  while retaining all existing values.
- FR-16: `CalendarMotion` MUST expose page distance, page scale, perspective,
  and content-stagger customization with validated finite ranges.
- FR-17: Horizontal week navigation MUST animate in the chronological direction
  for touch, keyboard, header, and controller navigation in LTR and RTL.
- FR-18: Month changes MUST animate using the configured page transition and
  chronological direction.
- FR-19: Foldable transitions MUST preserve selected/focused dates and MUST
  avoid rendering both interactive calendar surfaces to semantics at once.
- FR-20: All added motion MUST become immediate when reduced motion is enabled.

### Style expansion

- FR-21: `CalendarStyle` MUST add aurora, sunset, midnight, paper, terminal,
  luxury, materialYou, and cupertinoTinted families.
- FR-22: Every added style MUST provide light, dark, and high-contrast token
  resolution through `HorizontalCalendarThemeData`.
- FR-23: Added Material styles MUST retain 48 logical-pixel targets and added
  Cupertino styles MUST retain 44 logical-pixel targets.
- FR-24: Every style MUST meet 4.5:1 text contrast for the primary foreground
  on the background, surface, and accent colors used by default components.

### Cupertino pickers

- FR-25: `CalendarCupertinoDatePicker` MUST wrap Flutter's native Cupertino
  date wheels for date, time, date-time, and month-year modes.
- FR-26: The Cupertino picker MUST support bounds, minute intervals, 12/24-hour
  presentation, weekday labels, wheel extent, background, selection overlay,
  and change-reporting behavior.
- FR-27: `showCalendarCupertinoDatePicker` MUST present the picker in an
  accessible Cupertino modal with cancel, today, and confirm actions.
- FR-28: Modal changes MUST remain provisional until confirmation; cancellation
  MUST return `null` and confirmation MUST return the normalized selected value.
- FR-29: The existing adaptive picker MUST preserve its default presentation
  and MUST offer the wheel picker as an explicit Cupertino presentation option.

### Original celestial date picker

- FR-30: `CelestialDatePicker` MUST select one contiguous civil date through a
  horizontal horizon scrubber with sun, moon, sky, and phase feedback.
- FR-31: Celestial visuals MUST be derived from the selected date for expressive
  feedback and MUST NOT claim location-aware astronomical accuracy.
- FR-32: The celestial picker MUST support bounds, disabled-day predicates,
  previous/next controls, horizontal drag, keyboard navigation, direct month
  navigation, custom labels, custom painters/builders, and shared appearance.
- FR-33: Dragging across rejected dates MUST resolve to the nearest selectable
  date within bounds and MUST never emit a missing or duplicate civil date.
- FR-34: Celestial motion MUST use `CalendarMotion` and honor reduced motion.

### Additional date surfaces

- FR-35: `CalendarDateRail<T>` MUST render a vertical, scrollable date axis with
  selection, typed metadata, events, bounds, and custom item builders.
- FR-36: `CalendarScheduleRibbon<T>` MUST render a horizontally scrollable
  time-of-day ruler with typed intervals, overlap lanes, configurable start/end
  times, current-time state, and custom interval builders.
- FR-37: `CalendarMilestoneTimeline<T>` MUST render ordered dated milestones in
  horizontal or vertical orientation with completed, current, and upcoming
  states plus custom builders.
- FR-38: `CalendarAvailabilityStrip<T>` MUST render selectable time slots with
  available, limited, selected, and unavailable states and typed payloads.
- FR-39: Every added date surface MUST be independently usable without a
  calendar ancestor or controller.
- FR-40: All new widgets MUST expose complete immutable builder state instead
  of requiring callers to reconstruct selection, event, or availability state.

### Compatibility and documentation

- FR-41: `weekly_calendar.dart` MUST retain every 1.3 public symbol and existing
  legacy behavior, with deprecated annotations and direct replacement guidance.
- FR-42: All new public APIs MUST be exported from
  `horizontal_weekly_calendar.dart` and MUST have dartdoc comments.
- FR-43: The example MUST include interactive and capture-ready sections for
  carousel modes, selection modes, celestial picking, Cupertino wheels,
  transitions, styles, date rail, schedule ribbon, milestones, and availability.
- FR-44: README, migration documentation, and the 2.0 changelog MUST document
  all added APIs and selection semantics.

## Non-Functional Requirements

- NFR-1: `flutter analyze` MUST complete with zero issues for the package and
  example.
- NFR-2: All package and example tests MUST pass, including the complete legacy
  suite.
- NFR-3: New widgets MUST render without overflow at 280 logical pixels and
  text scale 2.0 in LTR and RTL.
- NFR-4: All interactive elements MUST expose labels, enabled/selected state,
  and a minimum target matching their resolved design system.
- NFR-5: Public API documentation coverage MUST remain 100 percent with zero
  dartdoc warnings.
- NFR-6: The package MUST retain a pana score of 160/160 and six-platform plus
  WebAssembly compatibility.
- NFR-7: A release web build of the example MUST succeed.
- NFR-8: Selection and date generation tests MUST cover 1900 through 2100, DST
  transitions, UTC/local inputs, leap dates, month/year boundaries, and all
  week starts.
- NFR-9: A 366-item carousel, rail, and availability source MUST build lazily;
  no widget MAY eagerly create all offscreen item elements.
- NFR-10: No new runtime dependency MAY be added for astronomy, scrolling, or
  state management.

## Acceptance Criteria

### AC-1: Carousel snapping geometry (FR-1, FR-2)
Given a 430-pixel viewport and a 152-pixel card extent
When a snapping carousel containing ten dates is rendered and dragged
Then at least two cards are partially or fully visible
And the settled position advances by exactly one date.

### AC-2: Carousel follows controlled selection (FR-3, FR-4)
Given a carousel whose selected date is initially August 3
When the parent changes selection to August 20 or its controller reveals August 20
Then the August 20 card becomes visible without emitting a selection callback.

### AC-3: Carousel remains compatible and resilient (FR-5, FR-7, FR-8, NFR-3)
Given the existing carousel constructor with full metadata and events at 280 pixels and text scale 2.0
When the widget renders and an enabled item is tapped
Then no overflow exception occurs
And the date and typed item callbacks each emit exactly once.

### AC-4: Unified selection rules (FR-6, FR-9, FR-10, FR-11, FR-12)
Given equivalent horizontal, month, foldable, and carousel widgets with each selection mode
When the same sequence of enabled dates is activated
Then every widget proposes equal normalized selection values
And the default sequence remains equal to the original 2.0 behavior.

### AC-5: Easy single selection (FR-13, FR-14)
Given a single-date month or foldable convenience constructor in the gallery
When a selectable date is tapped
Then its date callback fires once
And the gallery immediately displays that date as selected.

### AC-6: Directional week and month motion (FR-15, FR-16, FR-17, FR-18)
Given each page transition in LTR and RTL
When the calendar navigates chronologically forward and backward
Then the incoming transform begins from the correct visual side
And no opacity, perspective, or layout assertion is thrown.

### AC-7: Reduced calendar motion (FR-19, FR-20)
Given reduced motion is enabled
When week, month, or fold state changes
Then the final surface renders after one pump
And only the active surface exposes selectable semantics.

### AC-8: Expanded styles (FR-21, FR-22, FR-23, FR-24)
Given every style in light, dark, and high contrast
When theme tokens are resolved
Then minimum target and contrast checks pass for every family.

### AC-9: Inline Cupertino modes (FR-25, FR-26)
Given each supported Cupertino picker mode with valid configuration
When its wheel value changes
Then exactly one valid value callback is emitted
And custom wheel geometry and selection overlay are applied.

### AC-10: Cupertino modal confirmation (FR-27, FR-28, FR-29)
Given a provisional wheel selection
When cancel is tapped
Then the modal returns null
And when reopened, changed, and confirmed it returns the confirmed value only.

### AC-11: Celestial selection (FR-30, FR-31, FR-32, FR-33, FR-34)
Given a bounded celestial picker containing disabled dates
When the user drags, presses an arrow key, or taps previous/next
Then exactly one nearest selectable civil date is proposed per completed action
And the sun, moon, label, and phase state correspond to that date.

### AC-12: Additional date surfaces (FR-35, FR-36, FR-37, FR-38, FR-39, FR-40)
Given each new surface in a standalone MaterialApp and CupertinoApp
When an enabled item is tapped and the viewport is scrolled
Then its typed callback emits the original payload once
And no missing Material ancestor, overflow, or duplicate-key exception occurs.

### AC-13: Legacy and release gates (FR-41, FR-42, FR-43, FR-44, NFR-1, NFR-2, NFR-5, NFR-6, NFR-7)
Given the completed expansion
When all release gates run
Then legacy and v2 tests pass, analysis and dartdoc are clean, pana reports 160/160, and the example web build succeeds.

### AC-14: Date reliability and lazy construction (NFR-8, NFR-9, NFR-10)
Given maximum supported item counts and civil dates from 1900 through 2100
When date surfaces build and scroll across boundaries
Then dates remain contiguous and unique
And the number of built item elements remains bounded by the viewport cache.

## Edge Cases and Error Scenarios

- EC-1: Selected carousel date is outside its interval → render normally at the
  existing position and do not attempt an invalid scroll.
- EC-2: Carousel extent exceeds viewport width → clamp snapping fraction to one
  while preserving configured card width within the viewport.
- EC-3: Duplicate metadata dates → the last supplied item wins deterministically.
- EC-4: Multiple selection reaches its configured maximum → reject additional
  dates but allow selected dates to be removed.
- EC-5: A range exceeds its maximum length → clamp the proposed end to the last
  allowed contiguous date.
- EC-6: All dates near a requested celestial date are disabled → keep the
  current selection and emit no callback.
- EC-7: Cupertino initial value is outside bounds → clamp it before constructing
  the native picker.
- EC-8: Cupertino minute interval does not divide 60 → fail with a constructor
  assertion before rendering.
- EC-9: A schedule interval crosses midnight → split visual segments at the
  configured day boundary while retaining one typed source interval.
- EC-10: Milestones share a civil date → preserve source ordering and unique
  semantic identifiers.
- EC-11: An availability slot has an end before its start → reject construction
  with `ArgumentError`.
- EC-12: An overshooting animation curve yields values outside zero through one
  → opacity and perspective inputs remain clamped to valid ranges.
- EC-13: Reduced motion is enabled during an active transition → settle on the
  current controlled value without emitting another callback.
- EC-14: A new widget is hosted in a CupertinoApp without Material → interaction
  remains available without an ancestor assertion.

## API Contracts

```typescript
interface CalendarSelectionBehavior {
  singleTap: "replace" | "toggle";
  allowEmptyMultiple: boolean;
  maximumMultipleDates?: number;        // >= 1
  completedRangeTap: "restart" | "extend" | "nearestBoundary";
  maximumRangeDays?: number;            // >= 1
}

interface CalendarCarouselController {
  visibleDate: DateTime;
  revealDate(date: DateTime, animate?: boolean): Future<void>;
}

interface CalendarCupertinoPickerConfiguration {
  mode: "date" | "time" | "dateTime" | "monthYear";
  minuteInterval: number;                // positive divisor of 60
  use24HourFormat: boolean;
  showDayOfWeek: boolean;
  itemExtent: number;                    // > 0
  modalHeight: number;                   // >= 216
  reporting: "whileScrolling" | "onScrollEnd";
}

interface CelestialPickerState {
  date: DateTime;
  dayProgress: number;                   // 0...1 expressive visual value
  moonPhase: number;                     // 0...1 approximate visual value
  isSelectable: boolean;
  semanticLabel: string;
}

interface CalendarScheduleInterval<T> {
  id: string;
  start: DateTime;
  end: DateTime;                         // exclusive, after start
  title?: string;
  data?: T;
}

interface CalendarMilestone<T> {
  id: string;
  date: DateTime;
  title: string;
  subtitle?: string;
  data?: T;
}

interface CalendarAvailability<T> {
  id: string;
  start: DateTime;
  end: DateTime;                         // exclusive, after start
  state: "available" | "limited" | "unavailable";
  data?: T;
}
```

All widgets use Flutter constructors rather than network endpoints. Invalid
constructor invariants fail synchronously through assertions for developer
configuration or `ArgumentError` for invalid domain values. User interactions
never throw for a disabled date; they produce no proposal.

## Data Models

### Selection behavior

| Field | Type | Constraints |
| --- | --- | --- |
| singleTap | enum | replace or toggle; default replace |
| allowEmptyMultiple | bool | default true for compatibility |
| maximumMultipleDates | int? | null or at least 1 |
| completedRangeTap | enum | default restart for compatibility |
| maximumRangeDays | int? | null or at least 1 |

### Carousel card state

| Field | Type | Constraints |
| --- | --- | --- |
| date | DateTime | normalized civil date |
| item | CalendarCarouselItem<T>? | last matching civil date |
| events | List<CalendarEvent<T>> | immutable, unique source events |
| selection | CalendarSelection | immutable controlled value |
| rangePosition | CalendarRangePosition | derived from shared logic |
| isFocused | bool | true for revealed/controlled focus |
| isToday | bool | civil identity |
| isDisabled | bool | bounds or predicate rejection |
| semanticLabel | String | localized, non-empty |

### Celestial visual state

| Field | Type | Constraints |
| --- | --- | --- |
| date | DateTime | normalized and bounded |
| dayProgress | double | finite, zero through one |
| moonPhase | double | finite, zero through one, approximate |
| monthProgress | double | finite, zero through one |
| isSelectable | bool | derived from bounds and predicate |
| semanticLabel | String | localized date and visual state |

### Timeline entities

| Entity | Required fields | Constraints |
| --- | --- | --- |
| CalendarScheduleInterval<T> | id, start, end | stable ID; exclusive end after start |
| CalendarMilestone<T> | id, date, title | stable ID; normalized ordering by date then input order |
| CalendarAvailability<T> | id, start, end, state | stable ID; exclusive end after start |

## Out of Scope

- OS-1: Location-aware sunrise, sunset, moonrise, or ephemeris calculations —
  this UI kit will not request location or imply astronomy accuracy.
- OS-2: Mapping year, month, and day directly to sun, planet, and moon orbits —
  deliberately excluded to keep the celestial interaction original.
- OS-3: Alternate calendar-system conversion such as Hijri, Jalali, Hebrew, or
  lunar dates — requires dedicated correctness and localization specifications.
- OS-4: Event drag-and-drop editing, persistence, reminders, and notifications —
  these require application state and platform integrations outside a UI kit.
- OS-5: Removing or behaviorally rewriting any 1.x symbol — legacy migration
  remains source compatible throughout 2.x.
- OS-6: Adding third-party scrolling, astronomy, or state-management packages —
  Flutter SDK and the existing `intl` dependency are sufficient.
