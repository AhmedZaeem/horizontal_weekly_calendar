# Horizontal Weekly Calendar 2.0 — Visual Quality and Home Widgets

**Author:** Ahmed Zaeem  
**Date:** 2026-08-10  
**Status:** Approved  
**Reviewer:** Ahmed Zaeem  
**Related specs:** `v2_0_0.md`, `v2_product_definition.md`, `v2_showcase_expansion.md`  
**Approval source:** Direct implementation request, 2026-08-10

## Context

The 2.0 implementation is broad, but simulator review has exposed a final set
of correctness and product-quality gaps. Month and horizontal day cells resolve
range colors differently. The date carousel, celestial horizon, availability,
milestone, insight, and Android picker surfaces do not yet meet the visual or
responsive standard of the rest of the kit. The package also lacks a contract
for building phone home-screen calendar widgets.

This work is additive and compatibility preserving. Legacy widgets remain
usable and deprecated. Existing 2.0 constructors retain their required
parameters and defaults. New design modes and native-home-widget integration
are opt-in. A Flutter package can supply data, previews, platform messaging,
and installable native examples, but Android launchers render `RemoteViews` and
iOS requires a WidgetKit extension target. The package therefore provides one
serializable payload and responsive Flutter surface plus complete native host
examples for both platforms instead of pretending a Flutter widget alone can
run in a launcher or WidgetKit process.

## Functional Requirements

### Canonical date colors

- FR-1: Month, horizontal, carousel, foldable, and standalone day cells MUST
  resolve visual precedence from one canonical day-state resolver.
- FR-2: Disabled state MUST remain readable; selected start/end/single dates
  MUST use selected foreground and accent background; range-middle dates MUST
  use an explicit range background and readable foreground; today/focus MUST
  not overwrite selection.
- FR-3: Event indicators MUST remain visible against every selected, range,
  today, disabled, light, and dark background.
- FR-4: Civil-date comparisons MUST normalize time and timezone components so
  color state cannot disappear or duplicate for equivalent calendar dates.

### Date carousel

- FR-5: The built-in carousel MUST be redesigned around a compact date spine,
  useful metadata, restrained elevation, and selected context without oversized
  empty cards.
- FR-6: Classic, compact, spotlight, and editorial modes MUST each have distinct
  responsive geometry and MUST honor custom builders unchanged.
- FR-7: Selection changes MUST reveal the selected date, preserve adjacent
  context, and never assign selected visuals to a merely centered card.
- FR-8: User selection MUST emit exactly once in single, multiple, and range
  modes, and disabled dates MUST never emit.
- FR-9: The carousel MUST remain lazy and overflow-free at 240 logical pixels,
  text scale 2.0, RTL, long labels, and three event summaries.

### Celestial horizon

- FR-10: The horizon MUST add layered atmospheric depth, a continuous orbital
  path, moving light bloom, parallax stars/clouds, and a legible date capsule.
- FR-11: Built-in horizon compositions MUST include serene, orbital, minimal,
  and cinematic treatments while preserving custom sky builders.
- FR-12: Rapid date changes MUST retarget from current animation values and
  preserve chronological motion direction without flashing or teleporting.
- FR-13: Drag, buttons, keyboard, bounds, disabled dates, RTL, and reduced
  motion MUST remain correct for every composition.

### Availability and milestones

- FR-14: Availability MUST support automatic, horizontal, wrap, and grid
  layouts selected from actual constraints and text scale.
- FR-15: Availability MUST expose compact, card, pill, and schedule designs,
  minimum/maximum item width, status treatment, duration formatting, selection,
  and a complete custom builder.
- FR-16: Availability rows MUST stay usable from 160 through 1200 logical
  pixels without clipped labels, unbounded-width arithmetic, or `RenderFlex`.
- FR-17: Milestones MUST support timeline, roadmap, steps, cards, and minimal
  designs with horizontal/vertical axes, connector customization, completed,
  current, upcoming, and blocked states, typed actions, and custom builders.
- FR-18: Milestone layouts MUST retain chronological ordering and accessibility
  under compact constraints, text scale 2.0, dark theme, and RTL.

### Calendar insights

- FR-19: Insights MUST be redesigned as a coherent dashboard that can compose
  summary metrics, streak/progress, distribution, trend, and heatmap content.
- FR-20: Insight presentation MUST support cards, dashboard, compact, glass,
  editorial, and minimal designs with adaptive one-, two-, or multi-column
  layouts derived from constraints.
- FR-21: Every metric MUST support formatted values, optional trend direction,
  progress, accent, icon, semantic value, typed action, and custom content.
- FR-22: Empty, zero, negative, non-finite, very large, and localized metric
  values MUST render predictably and without invalid paint values.

### Android adaptive picker

- FR-23: The Material picker MUST provide an intentional opaque dialog/sheet,
  date summary, accessible month controls, optional quick actions, and explicit
  cancel/confirm actions.
- FR-24: A material picker configuration MUST expose dialog/sheet presentation,
  confirm-on-selection, quick actions, headline, help text, shape, color, and
  motion while retaining the existing immediate-selection behavior by default.
- FR-25: Provisional selection MUST respect bounds and enabled-day rules;
  cancel returns null, confirm returns one normalized valid date, and system
  back dismisses safely.
- FR-26: Cupertino wheel behavior and existing adaptive style resolution MUST
  remain unchanged.

### Home-screen widget kit

- FR-27: The package MUST expose immutable, serializable home-widget data for
  today, week, agenda, countdown, progress, and next-event content without app
  model dependencies.
- FR-28: A responsive Flutter preview/surface MUST support compact, small,
  medium, large, extra-large, and accessory families with automatic family
  selection from finite constraints.
- FR-29: Home-widget themes MUST expose background, foreground, accent,
  secondary, divider, corner, density, typography scale, week start, locale,
  clock format, and content visibility options.
- FR-30: The package MUST expose a dependency-free method-channel bridge for
  saving payloads, requesting platform refresh, and encoding deep-link actions,
  with a testable channel override.
- FR-31: The example Android app MUST include a registered, resizable
  `AppWidgetProvider`, responsive `RemoteViews`, widget picker preview, tap
  deep link, persisted payload, refresh handling, and small/medium/large layouts.
- FR-32: The example iOS app MUST include a WidgetKit extension target, shared
  app-group payload contract, timeline provider, deep link, and supported small,
  medium, large, and accessory families with documented signing setup.
- FR-33: Native host limitations and installation steps MUST be explicit: the
  consumer app owns its provider/extension target, identifier, signing, and app
  group; the Dart package owns payload generation, preview, and bridge contracts.

### Example, compatibility, and documentation

- FR-34: The example gallery MUST add capture-ready pages for corrected colors,
  redesigned carousel/horizon/availability/milestones/insights/picker, and every
  home-widget family while retaining all legacy examples.
- FR-35: Existing public source MUST continue compiling with no new required
  constructor arguments and all legacy APIs MUST remain deprecated, not removed.
- FR-36: All new public APIs MUST be exported, documented, tested, shown in the
  README, migration guide, and 2.0 changelog.

## Non-Functional Requirements

- NFR-1: Package and example analysis MUST report zero issues.
- NFR-2: All package, legacy, widget, example, Android, and iOS tests/build
  checks available in the environment MUST pass.
- NFR-3: Pana MUST report 160/160 and public API documentation MUST remain 100%.
- NFR-4: JavaScript and WebAssembly release builds MUST pass.
- NFR-5: Public Flutter surfaces MUST render at widths 160, 240, 280, 320, 430,
  768, and 1200 with text scales 1.0 and 2.0 in LTR and RTL without overflow.
- NFR-6: A 366-day carousel MUST build fewer than 30 date cards before scroll
  in a 430-pixel viewport.
- NFR-7: Serialization MUST round-trip without losing normalized dates, typed
  display fields, widget family, theme values, or action URLs.
- NFR-8: No runtime dependency MAY be added for responsiveness, animation,
  state management, home-widget transport, or serialization.
- NFR-9: No generated-author, assistant, or tool attribution MAY appear in
  shipped source.
- NFR-10: No content MAY be staged, committed, pushed, published, or uploaded.

## Acceptance Criteria

### AC-1: Shared visual precedence (FR-1–FR-4)
Given identical date state in month and horizontal calendars
When single, range-start, range-middle, range-end, today, focused, disabled,
light, and dark combinations render
Then resolved foreground, background, border, and marker roles match
And no date is missing, duplicated, or colored from time-of-day differences.

### AC-2: Carousel reliability and design (FR-5–FR-9, NFR-5, NFR-6)
Given every built-in layout and controlled selection mode
When the selected date moves on- and offscreen and a user taps cards
Then exactly one correct date proposal is emitted, disabled dates emit none,
the selected date is revealed with adjacent context, and no overflow occurs
while fewer than 30 cards build initially.

### AC-3: Horizon continuity (FR-10–FR-13)
Given every composition and a non-zero transition
When date changes retarget before settling
Then celestial position, atmosphere, and date capsule move continuously from
the current frame, controls remain valid, and reduced motion settles at once.

### AC-4: Responsive availability (FR-14–FR-16, NFR-5)
Given every layout/design across the required viewport matrix
When long localized labels and mixed slot durations render
Then automatic layout selects a usable geometry, all enabled slots remain
selectable once, and no layout or paint exception occurs.

### AC-5: Milestone design matrix (FR-17, FR-18, NFR-5)
Given every design, state, axis, direction, and text scale
When milestones render and enabled items are activated
Then chronology, connectors, state styling, semantics, and typed callbacks are
correct without overflow.

### AC-6: Insight dashboard (FR-19–FR-22)
Given all metric variants and invalid numeric inputs
When each design is rendered from compact phone to desktop
Then the dashboard chooses a fitting column count, clamps paint values, retains
legible hierarchy, and emits the original typed metric once.

### AC-7: Material picker (FR-23–FR-26)
Given immediate and confirm-on-selection configurations in dialog and sheet
When quick action, date, cancel, confirm, and back interactions occur
Then only normalized enabled dates can be returned, provisional state is clear,
the surface is opaque and safe-area aware, and Cupertino tests are unchanged.

### AC-8: Dart home-widget kit (FR-27–FR-30, NFR-7)
Given each content type, family, theme, locale, and deep-link action
When data round-trips and the surface renders at its family dimensions
Then content and customization survive exactly, layout is family-appropriate,
and bridge calls contain the documented channel method and payload.

### AC-9: Native examples (FR-31–FR-33)
Given configured example application identifiers
When Android app-widget and iOS WidgetKit targets build and consume a payload
Then supported sizes render calendar content, refresh requests update the
timeline/view, and taps open the documented application route.

### AC-10: Release and compatibility gates (FR-34–FR-36, NFR-1–NFR-10)
Given implementation is complete
When format, analyze, tests, dartdoc, Pana, release builds, source trace scans,
and publish dry-run are run
Then every stated gate passes, legacy use sites still compile, and Git status
shows no staged, committed, pushed, or published work from this task.

## Edge Cases and Error Scenarios

- EC-1: A selected date is also today and focused → selected colors win while
  today remains visible through a non-destructive border or indicator.
- EC-2: A disabled date lies inside a selected range → disabled interaction and
  readable disabled foreground win without visually joining invalid selection.
- EC-3: Range endpoints are reversed or contain times → normalized inclusive
  range roles remain chronological and unique.
- EC-4: Carousel selection changes during ballistic scroll → the latest selected
  date owns styling and final reveal; a centered neighbor never becomes selected.
- EC-5: Availability receives an unbounded main axis → automatic layout uses
  finite component defaults and an intentional scroll axis.
- EC-6: Milestones share a date → stable input order resolves their visual order.
- EC-7: Insight progress is NaN or infinite → paint progress resolves to zero;
  supplied display text may remain visible.
- EC-8: Material provisional date becomes invalid after bounds change → it is
  clamped to the nearest enabled date before confirmation.
- EC-9: A home payload has no events → family-specific empty states remain useful
  and never render an empty white box.
- EC-10: A launcher requests an unsupported Android size → the nearest smaller
  responsive layout is selected without clipping.
- EC-11: WidgetKit cannot access shared payload → the timeline placeholder uses
  deterministic sample/empty content and the host app remains unaffected.
- EC-12: Platform channel is unavailable on web/test → the bridge returns a
  documented unsupported result rather than throwing an uncaught exception.

## Validation Score

**97/100 — Approved for implementation.** Functional requirements are atomic,
acceptance criteria are observable, compatibility and platform ownership are
explicit, and the release gates cover API, layout, native, and publication risk.
The remaining uncertainty is consumer-specific Apple signing and app-group
provisioning, which the package cannot perform on behalf of downstream apps.
