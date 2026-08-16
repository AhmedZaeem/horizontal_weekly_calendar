# Changelog

## [2.0.0] - 2026-08-10

### Date generation

- Rebuilt `CalendarDateMath` on integer day numbers using the proleptic
  Gregorian algorithms. Every surface now generates dates without adding
  `Duration`s and without deriving day numbers from epoch milliseconds, so the
  arithmetic is exact on every platform including the web.
- **Fixed missing and duplicated dates in zones that skip a civil date.**
  `Pacific/Apia` went straight from 29 to 31 December 2011 when it crossed the
  international date line, and `Pacific/Kiritimati` skipped 31 December 1994.
  The previous implementation produced a December 2011 grid with no 30th and
  two 31sts. A civil date with no local instant is now materialized in UTC so
  the grid still renders it exactly once.
- Fixed dates anchored to a local midnight that does not exist, which happens
  in every zone that begins daylight saving at 00:00 (`America/Santiago`,
  `America/Havana`, `America/Sao_Paulo`). Those dates are anchored at midday
  instead, so the civil identity always matches what was requested.
- `startOfWeek` and weekday alignment are now derived arithmetically instead of
  from `DateTime.weekday`, so a week never starts on the wrong weekday near a
  transition.
- Exported `CalendarDateMath`, and added `daysFromCivil`, `civilFromDays`,
  `dayNumber`, `weekdayOf`, `daysInMonth`, and `isLeapYear`.
- The 1.x `generateWeeks` and `generateWeeksChunked` helpers now delegate to the
  same engine, so existing 1.x code gets the same guarantees unchanged.
- Added an exhaustive proof suite: every month from 1900 to 2100 against every
  first day of week, asserted contiguous, duplicate-free, correctly aligned and
  complete, cross-checked against an independent oracle. CI runs it under ten
  time zones chosen for how they break naive date arithmetic.

### Gesture-driven motion

- Horizontal page navigation now follows the drag. The strip translates under
  the pointer with rubber-band resistance, settles on a spring, and commits a
  page step from combined distance, width fraction, and fling velocity instead
  of a bare 56-pixel threshold. Blocked directions resist instead of ignoring
  the gesture.
- `FoldableCalendar` interpolates its real height between the week strip and
  the month grid through a dedicated render object, so a vertical drag expands
  or collapses the calendar continuously and releases onto a spring. Both
  surfaces are mounted only while the fold is moving, and only the dominant one
  is hit-tested or announced.
- Selection transitions are interruptible: a change continues from the current
  position at a constant perceived speed rather than restarting, and the day
  cell now interpolates fill, outline, padding, and label colors alongside the
  transform.
- Added press feedback to day cells, carousel cards, and event tiles, applied
  outside the gesture arena so taps, drags, and ink responses are unaffected.
- Added `CalendarMotion.followGestures`, `CalendarMotion.pressScale`,
  `CalendarMotion.spring`, `CalendarMotion.settleSpring`, and
  `CalendarMotion.isEnabled`.
- Carousel snapping now projects the fling before rounding, so a hard flick
  travels several cards, and the spotlight layout derives its emphasis from
  scroll position instead of discrete selection state.
- Replaced the carousel card's separate opacity, scale, physical-model, and
  container animations with a single animated decoration that carries its own
  elevation, and wrapped cards in repaint boundaries.
- Compositing-heavy page transitions (`blurThrough`, `coverFlow`, `flip`,
  `parallax`) now paint into their own layer, and spatial page transitions
  translate by a fraction of the page rather than of the window.
- `CalendarAgenda` moves through loading, error, empty, and populated states in
  one switcher instead of swapping subtrees in a single frame.
- Day and week timelines keep a live current-time indicator that glides between
  minutes, and open centred on the current time when the timeline covers today.
  Added `CalendarTimelineConfiguration.autoScrollToNow`.
- The calendar header cross-fades its month label instead of replacing it.

### Layout and composition

- A page of dates that fits its container is now laid out edge to edge; only a
  viewport too narrow for the minimum target size falls back to a scrolling
  strip. Previously a full week could be clipped by a scroll viewport the user
  had no reason to discover.
- Added `CalendarAppearance.showSurface` for composing a calendar inside a card
  or sheet the application already draws. `FoldableCalendar` uses it internally,
  which removes the nested card its collapsed state used to draw.
- Exported `CalendarThemeResolver` so custom day, header, and event builders can
  read the same resolved tokens the built-in cells use.

### Fixes

- `CalendarCupertinoDatePicker` no longer forwards `showDayOfWeek` in modes the
  native picker rejects, which previously threw an assertion from inside
  Flutter's `CupertinoDatePicker`.

### Example and documentation

- `CalendarHomeWidget` adopts its family's natural aspect when a parent gives no
  bounded height, instead of failing layout. Dropping a preview straight into a
  scroll view now works.

- Added thirteen real-world example screens under `example/lib/real_world/`,
  one per calendar surface, each wired to a typed application model, plus a
  catalogue at `/real-world` and a `CALENDAR_ROUTE` launch override.
- Added a motion and gesture guide, and refreshed the README with screenshots
  captured from the example app on an iPhone simulator.

### Visual quality and home-screen widgets

- Unified selected, range, today, focused, disabled, and event-marker color
  precedence across month and horizontal day cells.
- Corrected spotlight carousel semantics so centered focus never impersonates
  controlled selection, refined its card hierarchy, bounded pill radii, and
  aligned page snapping with the centered spotlight position.
- Added serene, orbital, minimal, and cinematic celestial compositions with a
  date capsule, richer depth, orbit geometry, haze, and foreground layers.
- Contained every celestial layer inside the sky viewport, replaced full-circle
  off-canvas paths with visible horizon arcs, and constrained constellation
  links to nearby stars.
- Added automatic, horizontal, wrap, and grid availability layouts plus card,
  pill, schedule, and compact designs with duration/status presentation.
- Added timeline, roadmap, steps, cards, and minimal milestone designs,
  configurable connectors, and an explicit blocked state.
- Added the typed responsive `CalendarInsightsDashboard<T>` with six adaptive
  presentations, padding-aware columns, readable ring-label contrast, and
  compact contribution-week spacing.
- Redesigned the Material adaptive picker with an opaque responsive sheet or
  dialog, summary header, quick actions, and optional provisional confirmation.
  Immediate selection remains the compatibility default.
- Fixed a confirm-action overflow in the Material adaptive picker's dialog and
  sheet presentations on narrow widths and large text scales by switching its
  action row to an `OverflowBar`, and removed a fixed-height quick-action chip
  row that could clip content at large text scales.
- Fixed the Material adaptive picker's available-height calculation producing
  negative, non-normalized layout constraints when keyboard insets nearly
  consume the visible viewport.
- Added versioned `CalendarHomeWidgetData`, six Flutter size families, six
  content layouts, visual tokens, deep-link actions, JSON round trips, and the
  dependency-free `CalendarHomeWidgetBridge`.
- Added the versioned `CalendarHomeWidgetConfiguration` contract and expanded
  home-widget theming with five surfaces, four headers, four event treatments,
  four date shapes, four progress treatments, four weekday formats, gradients,
  borders, elevation, spacing, limits, information rules, JSON round trips, and
  additive bridge configuration payloads.
- Added a registered, resizable Android `AppWidgetProvider` with responsive
  small/medium/large `RemoteViews`, persisted refresh, preview, and deep links.
- Added an iOS WidgetKit extension target with app-group payloads, timeline
  refresh, small through extra-large and accessory families, and deep links.
- Updated the Android and WidgetKit hosts to honor the portable content, color,
  header, weekday, event, limit, and visibility configuration while degrading
  unsupported system effects to documented solid surfaces.
- Expanded the gallery with redesigned insight, horizon, milestone,
  availability, picker, and dedicated home-widget capture surfaces.
- Added direct calendar-playground and home-widget-studio routes with live API
  controls, controlled callback inspection, native updates, responsive
  previews, and copyable recipes; rebuilt the home-widget capture route around
  six distinct launch-ready designs.

### Showcase expansion

- Corrected explicit Cupertino Tinted wheel presentation so it can never fall
  back to the Material month grid, and made the modal surface opaque across the
  full bottom safe area.
- Added snappy, gentle, cinematic, and premium motion presets plus parallax,
  cover-flow, vertical-reveal, and blur-through page transitions. Page depth,
  rotation, blur, and outgoing scale are independently configurable.
- Added classic, compact, spotlight, and editorial date-carousel layouts with
  center-aware reveal, neighboring context, bounded metadata, selection depth,
  event summaries, and complete additive visual configuration.
- Rebuilt horizon transitions as continuous retargetable sun and moon paths.
  Added dawn, day, dusk, midnight, aurora, and monochrome skies plus trails,
  clouds, parallax, constellations, orbit guides, horizon glow, and date
  progress.
- Added block, circle, pill, ring, bar, and diamond heatmap designs and the lazy
  `CalendarContributionHeatmap` week-column history surface.
- Added handle, button, both, hidden, and custom fold-control presentations to
  `FoldableCalendar` while preserving its original default and controlled
  contract.
- Added responsive typed `CalendarCountdownCard<T>`, `CalendarWeekProgress`,
  and `CalendarDateRangeSummary<T>` widgets.
- Expanded the example into a recording-ready gallery with dedicated carousel,
  horizon, heatmap, responsive-widget, and legacy capture routes. All three
  retained 1.x widgets are interactive in the legacy gallery.

### New horizontal-first API

- Added the three-line `HorizontalCalendar` quick start and a fully controlled
  constructor for single, multiple, and range selection.
- Added typed behavior, appearance, density, event-indicator, and builder
  configuration instead of an oversized flat constructor.
- Added page/free scrolling, touch, keyboard, RTL, bounds, today controls,
  haptics, accessibility state, and controller synchronization.
- Added optional `CalendarMotion` choreography with none, subtle, fluid,
  spring, and playful presets for selection, page, event, hover, and fold
  transitions.
- Added shared-axis, zoom, and perspective flip page transitions with tunable
  page offset, scale, and perspective for both week and month navigation.
- Added `CalendarSelectionBehavior` for same-date single taps, empty and
  limited multiple selection, completed-range behavior, and maximum ranges.

### Calendar UI kit

- Added natural-height `MonthCalendar` and drag/tap/controller-driven
  `FoldableCalendar` surfaces using the same selection, event, and theme models.
- Added `CalendarAgenda`, `DayTimeline`, and `WeekTimeline` with typed event
  callbacks, all-day events, current-time presentation, and deterministic
  overlap columns.
- Added reusable header, day-cell, event-marker, event-tile, now-indicator, and
  fold-handle components.
- Added `CalendarDateCarousel<T>` for horizontally scrollable application cards
  with typed metadata, badges, events, bounds, snapping, and custom builders.
- Rebuilt the date carousel around lazy fixed-extent cards, adjacent-card
  snapping, controlled selection following, a reveal controller, and complete
  single, multiple, and range selection.
- Added `CelestialDatePicker`, an original horizon date scrubber with
  decorative sun/moon feedback, drag, keyboard, bounds, disabled dates, month
  navigation, and custom sky builders.
- Added `CalendarDateRail<T>`, `CalendarScheduleRibbon<T>`,
  `CalendarMilestoneTimeline<T>`, and `CalendarAvailabilityStrip<T>` as typed,
  independently composable planning surfaces.
- Added `CalendarHeatmapStrip` and `CalendarStreakStrip` for accessible activity,
  completion, habit, finance, and wellness experiences.
- Added `AdaptiveCalendarNavigationBar` and
  `showAdaptiveCalendarPicker`, including Material bottom-sheet and Cupertino
  modal-popup presentation.
- Added `CalendarCupertinoDatePicker` and
  `showCalendarCupertinoDatePicker` around Flutter's native date, time,
  date-time, and month/year wheels with styled overlays and provisional modal
  confirmation. The adaptive picker can opt into wheel presentation.

### Themes and data

- Added adaptive plus thirteen explicit style families: Material, Cupertino,
  neutral, glass, editorial, bold, Material Expressive, Cupertino Glass,
  minimal, pill, soft, neon, and monochrome.
- Added eight more style families: aurora, sunset, midnight, paper, terminal,
  luxury, Material You, and Cupertino Tinted.
- Added light, dark, high-contrast, compact, comfortable, and spacious
  presentation through a complete `HorizontalCalendarThemeData`
  `ThemeExtension`.
- Added typed synchronous events, async event sources, latest-request-wins
  loading, stale response rejection, interval deduplication, cross-midnight
  segmentation, and stable event identity.
- Added dot, count, bar, stack, and custom event indicator presentations.

### Compatibility and quality

- Kept the complete 1.3 API under `weekly_calendar.dart` and marked it
  deprecated with direct v2 replacement guidance.
- Rebuilt civil-date arithmetic and exhaustive date tests to prevent missing or
  duplicate days across leap years, DST, month boundaries, and week starts.
- Replaced the example with a standalone interactive Android, iOS, and web
  gallery with live style, motion, density, brightness, text-scale, contrast,
  and RTL controls.
- Added filterable horizontal, native, motion, events, planning, data, and
  custom gallery categories plus dedicated hero, styles, motion, foldable,
  native, planning, and data capture routes.
- Added live selection, picker, date-rail, schedule-ribbon, milestone, and
  availability gallery sections plus selection, celestial, and widget capture
  routes. Every displayed selection is controlled and visibly persisted.
- Expanded documentation with runnable examples for every UI-kit family and a
  direct 1.x-to-2.0 migration guide.
- Added exhaustive 1900–2100 civil-date coverage, randomized responsive layout
  tests, async race tests, event stress tests, reduced-motion tests, and compact
  high-accessibility widget tests.

## [1.3.0] - 2026-03-29
#### Bug Fixes
- **Fixed DST-related calendar generation bug**: Months crossing daylight saving time boundaries (e.g., March, April, October, November) could show missing days, duplicate days, or incomplete weeks. The root cause was using `Duration`-based date arithmetic which is unreliable across DST transitions. All date calculations now use `DateTime` constructor arithmetic and UTC-based difference calculations.
- **Fixed table calendar missing days**: The table calendar could show fewer days than expected for certain month/starting-day combinations (e.g., March 2026 with Saturday start showing only 27 days).
- **Fixed horizontal weekly calendar day drift**: The horizontal weekly calendar with a custom starting day could produce off-by-one day errors near DST boundaries.

#### Improvements
- **Shared calendar utilities**: Extracted common logic (`generateWeeks`, `isSameDay`, `isDateDisabled`, `canNavigateToPreviousMonth`, `canNavigateToNextMonth`, `buildNavigationIcon`) into `calendar_utils.dart` for consistency and maintainability.
- **Comprehensive test suite**: Added 552+ unit and widget tests covering all month/year/starting-day combinations from 2024–2028, DST-prone months, leap years, disabled date logic, navigation boundary enforcement, and all three calendar widgets.
- **Code cleanup**: Removed duplicated helper methods across widgets in favor of shared utilities.

## [1.2.8] - 2026-01-12
#### Features
- **Overlapping Event Support**: Events that overlap in time are now displayed side by side instead of stacking.
- **Smart Event Layout**: Multiple overlapping events automatically split the available horizontal space equally.
- **Customizable Event Margin**: Added `overlappingEventMargin` property to `EventCalendarStyle` for controlling spacing between side-by-side events.

## [1.2.6] - 2025-12-30
#### Features
- **Added `minDate` and `maxDate` parameters** to all calendar widgets (HorizontalWeeklyCalendar, TableWeeklyCalendar, EventCalendar).
- **Added `disabledDayTextStyle` and `disabledDayColor`** to HorizontalCalendarStyle for customizing disabled date appearance.
- **Disabled dates** before minDate or after maxDate are now non-clickable and visually distinct.
- **Navigation buttons are now disabled** when reaching the boundary months defined by minDate/maxDate.

## [1.2.4] - 2025-10-15
#### Bug Fixes

## [1.2.3] - 2025-10-15
#### Bug Fixes

## [1.2.2] - 2025-10-15
#### Bug Fixes

## [1.2.1] - 2025-10-14
#### Bug Fixes

## [1.2.0] - 2025-10-14
#### Bug Fixes
- **Fixed a bug** where the table calendar would show odd days (like repeated days or missed ones).
- **Added feature** You can now add custom horizontal and vertical spacing in the table calendar between days.


## [1.1.5] - 2025-07-28
#### Bug Fixes
- **Fixed a bug** where the table calendar would add an extra space under it.


## [1.1.4] - 2025-07-28
#### Bug Fixes
- **Fixed a bug** where the calendar would show an extra divider at the end and fixed the styling of the event calendar.


## [1.1.3] - 2025-07-26
#### Bug Fixes
- **Fixed a bug** where the event calendar would show broken sometimes.


## [1.1.2] - 2025-07-26
- **Readme** Added preview images to the README file for better visualization of the calendar widget.


## [1.1.1] - 2025-07-26
#### Bug Fixes
- **Fixed a bug** where the calendar would not display correctly on certain devices.
- **Improved performance** for smoother scrolling and date selection.
#### Features
- **Added 2 new calendar styles**: 
    - Table calendar
    - Event calendar



## [1.0.1] - 2025-04-23


#### Documentation
- **Added a full Documentation to the package**
#### Example project
- **Added an Example to the package**
#### General bug fixes
- **General bug fixes**
- Changed min SDK to 3

## [1.0.0] - 2025-04-23


#### Features
- **Horizontal Weekly Calendar Widget** introduced
- **4 Built-in Display Styles**
    - Standard
    - Outlined
    - Minimal
    - Elevated
- Flexible date selection mechanism
- Month navigation controls
- Comprehensive customization options
    - Color theming
    - Text styling
    - Size adjustments

#### Core Capabilities
- Smooth date selection with callbacks
- Responsive design for multiple screen sizes
- Null safety implementation
- Configurable week start day
- Optional animated transitions

#### Customization Highlights
- Fully customizable `HorizontalCalendarStyle`
- Support for custom day indicators
- Adaptable to application themes
- Configurable month header styles

#### Technical Specifications
- Minimum Flutter SDK: 2.12.0
- Dart null safety compliance
- Lightweight and performant implementation

#### Known Limitations
- Initial release may have minor bugs
- Limited to weekly calendar view
- Potential performance considerations on older devices

**Breaking Changes**:
- Initial release - No prior version to compare

**Note**: We welcome community feedback and contributions to improve future versions!
