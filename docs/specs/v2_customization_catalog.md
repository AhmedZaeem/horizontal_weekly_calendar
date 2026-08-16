# Horizontal Weekly Calendar 2.0 customization catalogue

**Author:** Ahmed Zaeem
**Date:** 2026-08-15
**Status:** Approved

## Context

Version 2.0 already contains a broad set of horizontal calendars, date surfaces,
timelines, insight widgets, native pickers, and home-screen widget examples. The
remaining product gap is discoverability and demonstrable control: the gallery
mostly presents fixed compositions, while the home-screen widget renderer and
native hosts expose only a small visual theme. This pass turns the example into a
developer catalogue and makes home-widget customization serializable, testable,
responsive, and consistently rendered.

The public 1.x APIs remain source-compatible and deprecated. Existing 2.0
constructors also remain source-compatible; all additions are optional and have
defaults matching the current behavior.

## Functional Requirements

- FR-1: The package MUST add an immutable, serializable
  `CalendarHomeWidgetConfiguration` that captures family, content, theme, and
  content limits without invalidating existing `CalendarHomeWidget` calls.
- FR-2: `CalendarHomeWidgetTheme` MUST support surface, header, event, selected
  date, progress, weekday-label, spacing, typography, and visibility options,
  and MUST provide `copyWith`, `toJson`, and `fromJson`.
- FR-3: The Flutter home-widget preview MUST visibly honor every added theme
  option across compact, small, medium, large, extra-large, and accessory
  families without overflow.
- FR-4: `CalendarHomeWidgetBridge.update` MUST continue accepting the existing
  data-only call and MAY include a nested configuration payload that native
  Android and iOS example hosts can decode.
- FR-5: The Android RemoteViews example and iOS WidgetKit example MUST honor the
  portable subset of serialized surface colors, foreground colors, accent,
  content choice, event visibility, event limit, and text visibility options.
- FR-6: The example app MUST include an interactive horizontal-calendar
  playground with live controls for style, density, selection, visible dates,
  scroll behavior, event indicators, motion, headers, and folding.
- FR-7: The example app MUST include an interactive home-widget studio with live
  controls for family, content, density, surface, header, event, date, progress,
  labels, colors, and visibility settings.
- FR-8: Example controls MUST produce immediate visible state and callback
  feedback, and MUST include copyable Dart recipes for the current configuration.
- FR-9: Direct gallery routes MUST expose the playground and home-widget studio
  for development, automated capture, and launch-media recording.
- FR-10: Documentation MUST distinguish Flutter preview customization from
  platform-native constraints and MUST show migration-safe examples.

## Non-Functional Requirements

- NFR-1: The change MUST add no runtime package dependency.
- NFR-2: All existing public constructors and serialized data fields MUST remain
  accepted with their previous semantics.
- NFR-3: All family/content/style combinations MUST render at text scale 1.0 and
  1.6 in their documented geometry without `RenderFlex`, clipping exceptions,
  or framework errors.
- NFR-4: Date equality and ordering MUST use date-only normalized values so the
  new presentation options cannot reintroduce duplicate or missing dates.
- NFR-5: Public types and members MUST have Dart documentation and immutable
  value objects SHOULD use `const` constructors where possible.
- NFR-6: Motion MUST respect the package motion configuration and the operating
  system's accessible reduced-motion setting.
- NFR-7: `dart format`, `flutter analyze`, package tests, example tests, and the
  existing quality gates MUST pass before completion.

## Acceptance Criteria

### AC-1: Configuration round trip (FR-1, FR-2)

Given a configuration containing every non-default enum, color, number, and
visibility field, when it is encoded to JSON and decoded, then the decoded
configuration exposes the same values and can render without additional setup.

### AC-2: Legacy-safe construction (FR-1, FR-4)

Given existing code that constructs `CalendarHomeWidget` with only `data`,
`family`, and `content`, when the package is upgraded, then it compiles and the
default visual behavior remains equivalent.

### AC-3: Responsive preview matrix (FR-2, FR-3)

Given every home-widget family and content value at text scales 1.0 and 1.6,
when every supported surface and density is rendered, then no Flutter exception,
overflow stripe, or out-of-bounds paint occurs.

### AC-4: Theme behavior is observable (FR-2, FR-3)

Given a gradient outlined theme with segmented progress, dot events, rounded
selected dates, full weekday labels, hidden subtitle, and a two-event limit,
when the widget renders, then the corresponding decoration, labels, selection,
progress, event markers, and event count are visible in the widget tree.

### AC-5: Bridge compatibility (FR-4)

Given the existing data-only bridge update and a configured bridge update, when
each call is sent through a mock method channel, then the first payload preserves
the schema-v1 data map and the second adds a nested configuration map without
removing data fields.

### AC-6: Native portable theme (FR-5)

Given a configured update delivered to Android or iOS, when the native host
decodes it, then supported colors, content, event limit, and visibility values
alter the system widget while unsupported platform-specific effects degrade to
the documented solid surface.

### AC-7: Calendar playground interaction (FR-6, FR-8)

Given the playground route, when a developer changes selection mode, layout
style, visible-day count, indicator, motion, and fold setting and selects a day,
then the calendar updates immediately, the callback panel reports the normalized
date and selection, and the recipe updates.

### AC-8: Home-widget studio interaction (FR-7, FR-8)

Given the studio route, when a developer changes family, content, surface,
density, event style, selected-date style, and visibility controls, then the
preview resizes safely, every control is reflected, and the generated recipe is
copyable.

### AC-9: Direct routes and catalogue discoverability (FR-6, FR-7, FR-9)

Given the example app, when `/playground` or `/home-widget-studio` is opened,
then the requested tool is shown directly; when the main gallery is opened,
then both tools are reachable from prominent cards.

### AC-10: Documentation and quality (FR-10)

Given the completed implementation, when users read the README and example
README and run the repository quality commands, then supported customization,
native limitations, recipes, and migration behavior are documented and all
commands pass.

## Edge Cases

- EC-1: Empty event lists MUST produce meaningful empty states for agenda,
  next-event, countdown, and progress content.
- EC-2: More events than fit MUST be deterministically limited and summarized;
  the event limit MUST remain within 0 through 12.
- EC-3: A selected date outside the displayed week MUST not color an unrelated
  cell or duplicate a date.
- EC-4: Transparent and glass surfaces on Android RemoteViews MUST fall back to
  a supported solid color while preserving readable contrast.
- EC-5: Invalid or missing native configuration JSON MUST fall back to existing
  schema-v1 behavior rather than preventing the widget from updating.
- EC-6: Compact and accessory families MUST suppress lower-priority content
  before text overflows.
- EC-7: Large text, narrow parent constraints, long localized weekday names,
  long titles, long event titles, and right-to-left direction MUST remain usable.
- EC-8: Repeated rapid control changes MUST not create stale controller state,
  duplicate selections, or animations targeting disposed widgets.

## API Contracts

The method-channel operation is modeled as `POST /calendar-home-widget/update`.
It is a local platform-channel contract, not a network endpoint.

```dart
Future<void> update(
  CalendarHomeWidgetData data, {
  CalendarHomeWidgetConfiguration? configuration,
});
```

Request payload:

```json
{
  "schemaVersion": 1,
  "selectedDate": "2026-08-15T00:00:00.000",
  "title": "Today",
  "events": [],
  "configuration": {
    "schemaVersion": 1,
    "family": "medium",
    "content": "week",
    "theme": {}
  }
}
```

Response: a successful platform-channel completion with no value. Native decode
failures MUST retain the last valid widget state and return a Flutter error only
for an unavailable platform registration.

Conceptual host interface:

```typescript
interface CalendarHomeWidgetUpdate {
  schemaVersion: number;
  selectedDate: string;
  configuration?: CalendarHomeWidgetConfiguration;
}
```

## Data Models

### CalendarHomeWidgetConfiguration

| Field | Type | Constraints |
| --- | --- | --- |
| schemaVersion | int | Fixed at 1 for this release |
| family | CalendarHomeWidgetFamily | Optional; defaults to medium |
| content | CalendarHomeWidgetContent | Defaults to week |
| theme | CalendarHomeWidgetTheme | Defaults preserve existing rendering |

### CalendarHomeWidgetTheme additions

| Field | Type | Constraints |
| --- | --- | --- |
| surfaceStyle | CalendarHomeWidgetSurfaceStyle | solid, gradient, outlined, glass, transparent |
| eventStyle | CalendarHomeWidgetEventStyle | bar, dot, card, minimal |
| dateShape | CalendarHomeWidgetDateShape | circle, rounded, square, none |
| progressStyle | CalendarHomeWidgetProgressStyle | linear, circular, segmented, hidden |
| headerStyle | CalendarHomeWidgetHeaderStyle | title, month, compact, hidden |
| weekdayFormat | CalendarHomeWidgetWeekdayFormat | narrow, short, full, hidden |
| gradientColors | List<Color> | Zero or two colors; empty uses background color |
| borderColor | Color? | Optional; outlined falls back to accent |
| borderWidth | double | 0 through 8 logical pixels |
| elevation | double | 0 through 24 logical pixels |
| contentPadding | EdgeInsets? | Non-negative components |
| itemSpacing | double | 0 through 32 logical pixels |
| eventIndicatorWidth | double | 1 through 16 logical pixels |
| maximumEvents | int | 0 through 12 |
| showSubtitle | bool | Defaults true |
| showLocation | bool | Defaults true |
| useEventColors | bool | Defaults true |
| animateChanges | bool | Defaults true and respects reduced motion |

Existing background, foreground, secondary, accent, divider, radius, typography,
density, first-day, weekday, event-time, and progress fields remain supported.

## Out of Scope

- OS-1: Network fetching, authentication, cloud synchronization, and background
  calendar providers are application responsibilities.
- OS-2: iOS AppIntent-based per-installation configuration and Android widget
  configuration activities are deferred because they change deployment targets
  and application manifests beyond a package example.
- OS-3: Native hosts are examples and MUST NOT pretend to bypass WidgetKit or
  RemoteViews limitations such as arbitrary Flutter painting and animations.
- OS-4: This pass does not add breaking fields to legacy 1.x constructors or
  remove any deprecated symbol.
- OS-5: The example catalogue will expose and explain the existing option set;
  it will not add redundant aliases to every widget merely to increase the API
  surface.
