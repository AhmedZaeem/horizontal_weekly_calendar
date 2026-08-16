# Migrating to 2.0

Version 2.0 adds a new library entrypoint and leaves the 1.3 entrypoint intact.
This lets an application migrate one calendar at a time.

## Entrypoints

| 1.x | 2.0 |
| --- | --- |
| `package:horizontal_weekly_calendar/weekly_calendar.dart` | `package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart` |

The legacy entrypoint exports only the retained 1.3 API. The v2 entrypoint does
not import legacy symbols, which avoids collisions between the two event models.

## Widget mapping

| 1.x type | 2.0 replacement |
| --- | --- |
| `HorizontalWeeklyCalendar` | `HorizontalCalendar` |
| `TableWeeklyCalendar` | `MonthCalendar` |
| `EventCalendar` | `DayTimeline` or `WeekTimeline` |
| `HorizontalCalendarStyle` | `CalendarAppearance` and `HorizontalCalendarThemeData` |
| `HorizontalCalendarType` | A bundled theme factory or `CalendarStyle` |
| `Weekday` | Dart `DateTime.monday` through `DateTime.sunday` |
| `FocusDate` | `CalendarDayBuilder<T>` with `CalendarDayState<T>` |
| Legacy `CalendarEvent` | `CalendarEvent<T>` from the v2 entrypoint |
| `EventCalendarStyle` | `CalendarTimelineConfiguration` and `HorizontalCalendarThemeData` |

## Minimal calendar

Before:

```dart
HorizontalWeeklyCalendar(
  initialDate: selectedDate,
  selectedDate: selectedDate,
  onDateSelected: onDateSelected,
)
```

After:

```dart
HorizontalCalendar(
  selectedDate: selectedDate,
  onDateSelected: onDateSelected,
)
```

The v2 widget derives focus from `selectedDate`; no separate initial date is
needed.

## Parameter mapping

| 1.x parameter | 2.0 location |
| --- | --- |
| `minDate`, `maxDate` | `bounds: CalendarDateRange(min, max)` |
| `startingDay` | `behavior.firstDayOfWeek` |
| `enableAnimations` | `MediaQuery.disableAnimations` and theme motion tokens |
| `showMonthHeader` | `appearance.showHeader` |
| `calendarStyle` | `appearance.theme` or an inherited theme extension |
| `onNextMonth`, `onPreviousMonth` | `onFocusedDateChanged` or controller methods |
| custom day colors/text | `HorizontalCalendarThemeData.copyWith` |
| custom day content | `builders.dayBuilder` |

## Controlled selection

The quick-start callback remains `ValueChanged<DateTime>`. Advanced selection
is explicitly controlled:

```dart
HorizontalCalendar.controlled(
  focusedDate: focusedDate,
  selection: selection,
  onFocusedDateChanged: updateFocus,
  onSelectionChanged: (previous, next) => updateSelection(next),
)
```

The widget proposes state; the application decides whether to accept it. This
prevents hidden state from diverging from routing, forms, or remote data.

## Event migration

The v2 event uses `start` and exclusive `end`, accepts a typed payload, and has
a stable object ID:

```dart
CalendarEvent<Appointment>(
  id: appointment.id,
  title: appointment.title,
  start: appointment.startsAt,
  end: appointment.endsAt,
  data: appointment,
)
```

Use import prefixes while both APIs exist in one file:

```dart
import 'package:horizontal_weekly_calendar/weekly_calendar.dart' as legacy;
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart' as v2;
```

## Optional 2.0 UI kit additions

These additions are independent widgets and do not change legacy behavior:

| Need | 2.0 API |
| --- | --- |
| Date cards with typed metadata | `CalendarDateCarousel<T>` |
| Activity intensity | `CalendarHeatmapStrip` |
| Contribution history | `CalendarContributionHeatmap` |
| Habit or learning streaks | `CalendarStreakStrip` |
| Countdown, weekly progress, range summary | `CalendarCountdownCard<T>`, `CalendarWeekProgress`, `CalendarDateRangeSummary<T>` |
| Platform-specific navigation | `AdaptiveCalendarNavigationBar` |
| Platform-specific date modal | `showAdaptiveCalendarPicker` |
| Native Cupertino date wheels | `CalendarCupertinoDatePicker` |
| Expressive horizon date picker | `CelestialDatePicker` |
| Foldable week-to-month view | `FoldableCalendar` |
| Agenda or schedule view | `CalendarAgenda`, `DayTimeline`, `WeekTimeline` |
| Vertical chronological axis | `CalendarDateRail<T>` |
| Compact time ruler | `CalendarScheduleRibbon<T>` |
| Milestones and booking slots | `CalendarMilestoneTimeline<T>`, `CalendarAvailabilityStrip<T>` |
| Adaptive calendar metrics | `CalendarInsightsDashboard<T>` |
| Phone home-screen content | `CalendarHomeWidget`, `CalendarHomeWidgetBridge` |

Add a named motion preset without changing the widget's dimensions:

```dart
HorizontalCalendar(
  selectedDate: selectedDate,
  onDateSelected: onDateSelected,
  appearance: CalendarAppearance(
    style: CalendarStyle.materialExpressive,
    motion: CalendarMotion.spring(),
  ),
)
```

Omit `motion` to preserve the original 2.0 transition behavior. The named
presets also honor the operating system's reduced-motion preference.

For explicit selection rules, add `CalendarSelectionBehavior` inside
`CalendarBehavior`. Existing defaults remain unchanged:

```dart
const CalendarBehavior(
  selectionBehavior: CalendarSelectionBehavior(
    maximumMultipleDates: 5,
    maximumRangeDays: 14,
  ),
)
```

The original `CalendarDateCarousel` required parameters are unchanged. Its
new `.controlled` constructor adds multiple/range selection, while
`CalendarDateCarouselController.revealDate` scrolls without selecting.
`CalendarCarouselVisualStyle` additively enables classic, compact, spotlight,
and editorial layouts without changing the original default constructor.

Cupertino applications keep the adaptive month modal by default. Opt into
native wheels with
`cupertinoPresentation: CalendarCupertinoPickerPresentation.wheel`.
Cupertino Tinted now belongs to the same native control family as Cupertino and
Cupertino Glass, so an explicit wheel request cannot resolve to a Material
month grid.

Material applications keep immediate return-on-date-tap behavior. Opt into the
new confirmation flow with
`CalendarMaterialPickerConfiguration(confirmSelection: true)`. Sheet/dialog
choice, quick actions, copy, colors, shape, and motion are additive options.

The home-widget Dart API does not add a plugin dependency. A native launcher or
WidgetKit host is still required because those surfaces run outside the Flutter
process. Copy/adapt the complete native example and keep its method-channel,
schema version, storage key, deep-link, and app-group values aligned. See
`doc/home_screen_widgets.md`.

Existing motion presets and defaults are unchanged. New code may opt into
snappy, gentle, cinematic, or premium presets and parallax, cover-flow,
vertical-reveal, or blur-through page transitions.

`CelestialDatePicker` keeps its original controlled callback and custom sky
builder. `CelestialMotion` and `CelestialDatePickerStyle` add continuous
retargetable motion, atmospheric palettes, trails, clouds, constellations,
orbit guides, and progress layers.

`CalendarHeatmapStyle` keeps block cells as its default and adds circle, pill,
ring, bar, and diamond designs. `FoldableCalendar` keeps the original handle by
default; use `foldControl` to choose button, both, or hidden presentations.

## Recommended migration order

1. Upgrade the dependency and keep the legacy import.
2. Add the v2 import with a prefix.
3. Replace horizontal calendars with `HorizontalCalendar`.
4. Move style values into a v2 theme and appearance.
5. Convert event values and event views.
6. Remove the legacy import after the last deprecated widget is gone.
