# Horizontal Calendar 2.0 gallery

Interactive Android, iOS, and web gallery for every v2 calendar surface,
preset, density, accessibility mode, typed event example, and native
home-screen widget host.

```sh
flutter pub get
flutter run
```

## Real-world examples

`/real-world` is the fastest way to see one surface doing real work. It holds
thirteen small products, one per calendar type, each wired to a typed
application model that comes straight back out of the callbacks:

| Product | Screen | Surface |
|---|---|---|
| Pulse | Training week | `HorizontalCalendar`, `CalendarWeekProgress` |
| Skyline | Fare finder | `CalendarDateCarousel` |
| Northside Health | Appointment booking | `MonthCalendar`, `CalendarAvailabilityStrip` |
| Aster Stays | Stay dates | `HorizontalCalendar.controlled` (range) |
| Studio Ops | Call sheet | `DayTimeline` |
| Shift Board | Field rota | `WeekTimeline` |
| Margin | Journal | `FoldableCalendar` |
| Parcel | Tracking history | `CalendarAgenda`, `CalendarEventSource` |
| Streak | Habits | `CalendarStreakStrip`, `CalendarContributionHeatmap`, `CalendarInsightsDashboard` |
| Runway | Release readiness | `CalendarCountdownCard`, `CalendarHeatmapStrip` |
| Rundown | iOS reminder | `AdaptiveCalendarNavigationBar`, `CalendarCupertinoDatePicker` |
| Lunar | Sleep log | `CelestialDatePicker` |
| Glance | Home widgets | `CalendarHomeWidget` |

The source lives in `lib/real_world/`: `data.dart` holds the seed content,
`shell.dart` the shared page chrome, and the `screens_*.dart` files the screens
themselves.

Launch straight into one screen on any platform:

```sh
flutter run --dart-define=CALENDAR_ROUTE=/real-world/studio-day
```

## Developer tools

The first gallery section opens two developer tools:

- `/playground` controls the real `HorizontalCalendar` and
  `FoldableCalendar` APIs: selection mode, style, density, page behavior,
  visible dates, indicators, motion, availability rules, headers, and folding.
  It shows callback output and generates a copyable Dart recipe.
- `/home-widget-studio` controls every home-widget family and content layout,
  five surface treatments, four event treatments, four date shapes, four
  progress treatments, weekday formats, palettes, information visibility,
  type scale, spacing, elevation, radius, and event limits. It can send the
  current serialized configuration to the Android or iOS system widget.

Open `/?showcase=1` on web for the hero recording route. Dedicated capture
routes are available through `?capture=styles`, `motion`, `carousel`,
`horizon`, `heatmaps`, `foldable`, `native`, `planning`, `responsive`,
`selection`, `widgets`, `data`, `celestial`, `home-widgets`, and `legacy`.

The home-widget capture route intentionally shows distinct Paper, Aurora,
Sunset, Midnight, outlined, gradient, card-event, rounded-date, and segmented
progress recipes rather than repeating the default skin.
