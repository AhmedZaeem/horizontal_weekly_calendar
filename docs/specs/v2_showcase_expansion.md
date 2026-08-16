# Horizontal Weekly Calendar 2.0 — Showcase Expansion

**Author:** Ahmed Zaeem  
**Date:** 2026-08-10  
**Status:** Approved  
**Reviewer:** Ahmed Zaeem  
**Related specs:** `v2_product_definition.md`, `v2_completeness_addendum.md`, `v2_interaction_expansion.md`  
**Approval source:** Direct implementation request, 2026-08-10

## Context

The working 2.0 gallery demonstrates the new calendar UI kit, but simulator
review exposed several showcase blockers. Cupertino Tinted is not classified as
a Cupertino style by the adaptive picker, so an explicitly requested wheel can
fall through to the month-grid picker. The wheel modal also needs a fully
opaque, safe-area-aware bottom surface. Horizontal page changes can appear
instant, the default date carousel lacks a strong visual hierarchy, and the
celestial horizon swaps painted positions without enough spatial continuity.

The gallery also omits the retained 1.x widgets, reducing confidence in source
compatibility. Heatmaps and fold controls have only one default presentation,
and duration-oriented planning surfaces need stronger compact-screen behavior.
The package should provide capture-ready examples that look intentional on a
phone, tablet, desktop, dark theme, large text, and RTL while remaining easy to
use and free of external UI, animation, or responsiveness dependencies.

This expansion is additive. Existing legacy and v2 constructors retain their
defaults. New visual modes, motion options, and components are opt-in, and all
calendar surfaces continue to use the shared civil-date engine, selection
model, appearance tokens, reduced-motion policy, and typed payload contracts.

## Functional Requirements

### Legacy and gallery presentation

- FR-1: The example MUST include working `HorizontalWeeklyCalendar`,
  `TableWeeklyCalendar`, and `EventCalendar` legacy examples with a visible
  deprecated/legacy label and no suppression of runtime interaction.
- FR-2: The example MUST provide a dedicated legacy capture route and dedicated
  capture routes for carousel, horizon, heatmaps, motion, and responsive date
  widgets.
- FR-3: Capture routes MUST use a coherent branded shell, controlled values,
  uncluttered framing, and phone-safe spacing suitable for still images or
  vertical video.
- FR-4: The example MUST preserve every existing showcase and route while
  adding the new families.

### Cupertino picker correctness

- FR-5: `CalendarStyleResolver` MUST classify Cupertino, Cupertino Glass, and
  Cupertino Tinted as Cupertino-oriented styles through one public helper.
- FR-6: An adaptive picker with a Cupertino-oriented style and explicit wheel
  presentation MUST display `CupertinoDatePicker`, not `MonthCalendar`.
- FR-7: The Cupertino modal MUST paint an opaque full-width surface through the
  bottom safe area and MUST clip its top corners without transparent gaps.
- FR-8: The Cupertino modal MUST retain provisional cancel/today/confirm
  behavior, bounds, enabled-day filtering, custom wheel geometry, and reduced
  motion.

### Calendar motion

- FR-9: `CalendarPageTransition` MUST add parallax, cover-flow, vertical-reveal,
  and blur-through modes without removing or changing existing enum values.
- FR-10: `CalendarMotion` MUST add snappy, gentle, cinematic, and premium
  presets and MUST expose page rotation, page blur, and outgoing-page scale.
- FR-11: Header-button, gesture, keyboard, controller, and month navigation
  MUST preserve chronological transition direction in LTR and RTL.
- FR-12: A non-`none` page transition MUST retain incoming and outgoing pages
  for at least one intermediate frame when its duration is non-zero.
- FR-13: Only the incoming page MUST accept input or expose semantics during a
  page transition.
- FR-14: All added motion MUST settle immediately under reduced motion and MUST
  clamp overshooting curve values before opacity, blur, or transform use.

### Date carousel refinement

- FR-15: `CalendarDateCarousel` MUST support classic, compact, spotlight, and
  editorial layouts through additive visual configuration.
- FR-16: The default carousel MUST use clear weekday/date/month hierarchy,
  selected elevation, focus emphasis, bounded badge treatment, and compact
  event summaries without empty-looking cards.
- FR-17: Spotlight layout MUST center the selected/revealed card when possible,
  scale it above neighboring cards, and keep adjacent context visible.
- FR-18: Carousel visual configuration MUST expose selected scale, inactive
  scale, inactive opacity, card spacing, elevation, border width, alignment,
  date/month visibility, event-count visibility, and gradient use.
- FR-19: Carousel cards MUST remain lazy, uniquely keyed, typed, selectable,
  bounds-aware, and overflow-free at 280 logical pixels with text scale 2.0.

### Celestial horizon expansion

- FR-20: `CelestialDatePicker` MUST animate the sun and moon continuously along
  distinct curved paths between old and new date states instead of replacing
  the complete painting through a fade.
- FR-21: Celestial transitions MUST expose drift, arc height, parallax,
  rotation, trail, star-twinkle, and transition-duration customization.
- FR-22: Celestial presentation MUST add dawn, day, dusk, midnight, aurora, and
  monochrome sky styles while retaining fully custom sky builders.
- FR-23: The horizon MUST support optional clouds, constellations, phase orbit,
  horizon glow, date progress, and a compact presentation.
- FR-24: Rapid controlled date changes MUST retarget from the current animated
  position without jumping, duplicating callbacks, or starting from zero.
- FR-25: Celestial controls MUST remain bounds-aware, disabled-date-aware,
  keyboard accessible, RTL-correct, and immediate under reduced motion.

### Heatmaps, fold controls, and responsiveness

- FR-26: Heatmap cells MUST support block, circle, pill, ring, bar, and diamond
  designs while retaining the custom cell builder.
- FR-27: Heatmap style MUST expose empty color, border, label position,
  animation, selection, and palette interpolation customization.
- FR-28: A new calendar contribution heatmap MUST arrange contiguous dates as
  weekday rows and chronological week columns with lazy horizontal scrolling,
  typed date callbacks, locale labels, and custom cells.
- FR-29: `FoldableCalendar` MUST support handle, button, both, and hidden fold
  controls, with custom labels/icons/builders and identical support across all
  `CalendarStyle` values.
- FR-30: Code-driven fold changes MUST remain controlled and preserve focus,
  selection, events, and semantics.
- FR-31: Date rail, schedule ribbon, milestones, availability, countdown, and
  duration-oriented widgets MUST select compact geometry from actual
  constraints and text scale without external responsive packages.
- FR-32: Fixed-width or fixed-height content that cannot fit MUST scale down or
  scroll on its intended axis and MUST NOT produce a `RenderFlex` overflow.

### Additional calendar widgets

- FR-33: `CalendarCountdownCard<T>` MUST display a typed target date with past,
  today, upcoming, and completed states, custom labels, and a custom builder.
- FR-34: `CalendarWeekProgress` MUST display seven contiguous day segments with
  completed, current, upcoming, selected, and disabled states plus callbacks.
- FR-35: `CalendarDateRangeSummary` MUST visualize a normalized inclusive range,
  duration, endpoints, progress, and an optional typed action without requiring
  a calendar ancestor.
- FR-36: Every added widget MUST use immutable builder state, shared appearance,
  minimum platform target sizes, localized semantics, RTL, and reduced motion.

### Compatibility and documentation

- FR-37: Every existing 1.x and 2.0 public constructor MUST continue compiling
  with unchanged required parameters and defaults.
- FR-38: New public APIs MUST be exported, fully documented, and demonstrated
  in the example and README.
- FR-39: The 2.0 changelog and migration guide MUST explain picker correction,
  motion, carousel, horizon, heatmap, fold-control, widget, and legacy-gallery
  additions.

## Non-Functional Requirements

- NFR-1: Package and example analysis MUST report zero issues.
- NFR-2: All package, legacy, and example tests MUST pass.
- NFR-3: Pana MUST report 160/160 and 100% public API documentation.
- NFR-4: The example MUST build in JavaScript and WebAssembly release modes.
- NFR-5: Tested public surfaces MUST render at widths 240, 280, 320, 430, 768,
  and 1200 with text scales 1.0 and 2.0 in LTR and RTL without overflow.
- NFR-6: A 366-day carousel and contribution heatmap MUST build fewer than 30
  date elements before scrolling in a 430-pixel viewport.
- NFR-7: All animation values passed to opacity MUST remain from zero through
  one and blur sigma MUST remain finite and non-negative.
- NFR-8: No runtime dependency MAY be added for animation, astronomy,
  responsiveness, scrolling, or state management.
- NFR-9: No generated-author, assistant, or tool attribution MAY appear in
  shipped Dart source.
- NFR-10: No repository content MAY be staged, committed, pushed, or published
  without a later explicit instruction.

## Acceptance Criteria

### AC-1: Legacy capture gallery (FR-1, FR-2, FR-3, FR-4)
Given the example is rendered at a phone-sized viewport
When the legacy category or legacy capture route is opened
Then all three retained widgets render with interactive selection/navigation
And no overflow, duplicate-key, or missing-ancestor exception occurs.

### AC-2: Correct Cupertino wheel route (FR-5, FR-6, FR-7, FR-8)
Given Cupertino Tinted appearance and explicit wheel presentation
When the adaptive picker is opened
Then one `CupertinoDatePicker` is present and no `MonthCalendar` is present
And the modal background covers the full bottom safe-area width
And cancel returns null while confirm returns the provisional value.

### AC-3: Visible button page transitions (FR-9, FR-10, FR-11, FR-12)
Given each non-none transition with a 300-millisecond duration
When previous or next is activated from the calendar header
Then old and new keyed pages coexist after 100 milliseconds
And no transform, opacity, blur, or layout assertion occurs.

### AC-4: Transition input and reduced motion (FR-13, FR-14, NFR-7)
Given an active page transition
When semantics and hit testing are inspected
Then only the incoming page is enabled
And with reduced motion the final page is present after one pump.

### AC-5: Carousel layouts (FR-15, FR-16, FR-17, FR-18, FR-19)
Given every carousel layout at 280 pixels and text scale 2.0
When metadata, long badges, and three events are rendered and the controlled
selection moves to an offscreen date
Then no overflow occurs
And the selected card is revealed with neighboring context
And typed selection fires once only after a user tap.

### AC-6: Continuous horizon motion (FR-20, FR-21, FR-22, FR-23, FR-24)
Given every built-in sky style and a non-zero celestial duration
When the controlled date changes twice before the first animation completes
Then the sun and moon positions at the intermediate frames differ continuously
And the second animation begins from the first animation's current value
And no duplicate date callback occurs.

### AC-7: Accessible celestial controls (FR-25, NFR-5)
Given bounds, disabled dates, RTL, text scale 2.0, and reduced motion
When day, month, drag, and keyboard controls are used
Then only valid normalized dates are proposed once
And the final state renders without overflow after one pump.

### AC-8: Heatmap design matrix (FR-26, FR-27, NFR-5)
Given every heatmap design in compact LTR and RTL layouts
When zero, fractional, one, negative, and non-finite values are supplied
Then values resolve to finite clamped intensity states
And each design renders without overflow and returns the normalized tapped date.

### AC-9: Contribution heatmap laziness (FR-28, NFR-6)
Given 366 contiguous dates in a 430-pixel viewport
When the contribution heatmap first renders
Then fewer than 30 date cells are built
And scrolling reveals later unique dates without gaps or duplicates.

### AC-10: Configurable fold controls (FR-29, FR-30)
Given each fold-control presentation and each calendar style
When its enabled control is activated or the controlled state changes
Then exactly one fold proposal is emitted
And focus, selection, events, and only active semantics are retained.

### AC-11: Responsive planning and duration surfaces (FR-31, FR-32, NFR-5)
Given each listed surface at every required width, direction, and text scale
When long localized labels and overlapping durations are rendered
Then no `RenderFlex` overflow occurs
And content remains readable through adaptive geometry or intended-axis scroll.

### AC-12: Additional widgets (FR-33, FR-34, FR-35, FR-36)
Given each new widget in standalone Material and Cupertino applications
When an enabled typed item or action is activated
Then the original payload/date is returned once
And semantics, RTL, reduced motion, and platform target sizes remain valid.

### AC-13: Compatibility and release gates (FR-37, FR-38, FR-39, NFR-1, NFR-2, NFR-3, NFR-4, NFR-8, NFR-9, NFR-10)
Given the expansion is complete
When formatting, analysis, tests, dartdoc, Pana, release builds, trace scans, and
publish dry-run are executed
Then every gate passes at its stated threshold
And nothing is staged, committed, pushed, or published.

## Edge Cases and Error Scenarios

- EC-1: Cupertino Tinted wheel on Android theme → explicit wheel still uses the
  Cupertino modal because explicit appearance wins over platform.
- EC-2: Modal view padding changes while open → opaque background continues
  through the updated bottom inset.
- EC-3: Page curve overshoots below zero or above one → transform progress,
  opacity, and blur are clamped before rendering.
- EC-4: Page changes again mid-transition → latest page becomes interactive and
  stale pages remain semantics-excluded until removal.
- EC-5: Carousel width is below configured extent → extent clamps to viewport
  while internal content adopts compact layout.
- EC-6: Carousel metadata is absent → date hierarchy fills the card without an
  empty spacer region.
- EC-7: Celestial target changes across a month/year boundary → animation uses
  normalized progress and does not reverse unexpectedly because of day number.
- EC-8: Celestial target changes while animation is active → controller retargets
  from its current value, not the previous date endpoint.
- EC-9: Heatmap color list contains one color → empty theme surface plus supplied
  active color form a valid palette.
- EC-10: Contribution heatmap start date is not the configured week start →
  leading placeholders preserve weekday rows without representing fake dates.
- EC-11: Fold control is hidden and gestures are disabled → fold state changes
  only from the controlled value/controller and remains usable from code.
- EC-12: Countdown target is in the past or completed → state is explicit and
  duration is never displayed as a negative value.
- EC-13: Date range endpoints are equal → summary reports one inclusive day.
- EC-14: Viewport width is unbounded → responsive metrics use component defaults
  and do not perform infinite-size arithmetic.
- EC-15: Temporary screenshot files are unavailable → implementation relies on
  reproduced widget states and automated layout tests, not missing assets.

## API Contracts

```typescript
interface CalendarStyleResolver {
  resolve(style: CalendarStyle, platform: TargetPlatform): CalendarStyle;
  isCupertino(style: CalendarStyle, platform?: TargetPlatform): boolean;
}

type CalendarPageTransition =
  | "none" | "slide" | "fadeThrough" | "scale" | "sharedAxis"
  | "zoom" | "flip" | "parallax" | "coverFlow" | "verticalReveal"
  | "blurThrough";

interface CalendarMotion {
  pageRotation: number;       // finite, 0...0.5 radians
  pageBlur: number;           // finite, 0...20 sigma
  outgoingPageScale: number;  // finite, 0.5...1.1
}

type CalendarCarouselLayout = "classic" | "compact" | "spotlight" | "editorial";

interface CalendarCarouselVisualStyle {
  layout: CalendarCarouselLayout;
  selectedScale: number;
  inactiveScale: number;
  inactiveOpacity: number;
  spacing?: number;
  elevation: number;
  borderWidth: number;
  showMonth: boolean;
  showEventCount: boolean;
  useGradient: boolean;
}

type CelestialSkyStyle = "dawn" | "day" | "dusk" | "midnight" | "aurora" | "monochrome";

interface CelestialMotion {
  duration: Duration;
  arcHeight: number;
  drift: number;
  parallax: number;
  rotation: number;
  trailLength: number;
  starTwinkle: number;
}

type CalendarHeatmapDesign = "block" | "circle" | "pill" | "ring" | "bar" | "diamond";
type CalendarFoldControl = "handle" | "button" | "both" | "hidden";
```

## Data Models

### CalendarCarouselVisualStyle

| Field | Type | Constraints |
|---|---|---|
| layout | CalendarCarouselLayout | Non-null, default classic |
| selectedScale | double | Finite, 1.0 through 1.2 |
| inactiveScale | double | Finite, 0.75 through 1.0 |
| inactiveOpacity | double | Finite, 0.3 through 1.0 |
| spacing | double? | Null uses theme spacing; otherwise non-negative |
| elevation | double | Finite, non-negative |
| borderWidth | double | Finite, non-negative |
| showMonth | bool | Default true |
| showEventCount | bool | Default true |
| useGradient | bool | Default true |

### CelestialMotion

| Field | Type | Constraints |
|---|---|---|
| duration | Duration | Non-negative |
| arcHeight | double | Finite, 0 through 1 |
| drift | double | Finite, 0 through 1 |
| parallax | double | Finite, 0 through 1 |
| rotation | double | Finite, 0 through 2π |
| trailLength | double | Finite, 0 through 1 |
| starTwinkle | double | Finite, 0 through 1 |

### CalendarCountdownState<T>

| Field | Type | Constraints |
|---|---|---|
| targetDate | DateTime | Normalized civil date |
| remainingDays | int | Non-negative |
| state | CountdownState | past, today, upcoming, completed |
| progress | double | Finite, zero through one |
| data | T? | Original unchanged payload |
| semanticLabel | String | Non-empty localized label |

### CalendarWeekProgressDayState

| Field | Type | Constraints |
|---|---|---|
| date | DateTime | Normalized unique civil date |
| state | WeekProgressState | completed, current, upcoming, selected, disabled |
| progress | double | Finite, zero through one |
| semanticLabel | String | Non-empty localized label |

### CalendarDateRangeSummaryState<T>

| Field | Type | Constraints |
|---|---|---|
| range | CalendarDateRange | Normalized inclusive range |
| inclusiveDays | int | At least one |
| elapsedDays | int | Zero through inclusiveDays |
| progress | double | Finite, zero through one |
| data | T? | Original unchanged payload |
| semanticLabel | String | Non-empty localized label |

## Out of Scope

- OS-1: Astronomically accurate sun/moon positions — requires location, time,
  and astronomy data and would change the horizon widget's decorative contract.
- OS-2: Video rendering or social-platform export — the example supplies clean
  capture routes; recording/editing remains an external production workflow.
- OS-3: Third-party responsive, animation, calendar, or state libraries —
  prohibited by the package's lightweight dependency contract.
- OS-4: Removal or semantic modification of legacy APIs — compatibility is a
  release requirement, not a migration cleanup opportunity.
- OS-5: Automatic Figma or remote design synchronization — the gallery and
  source themes are the design source for this expansion.
- OS-6: Publishing, committing, staging, or pushing — requires a later explicit
  instruction from the package owner.
