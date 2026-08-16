# Home-screen widget integration

`CalendarHomeWidgetData` is the stable boundary between your Flutter app and a
phone home-screen widget. It carries civil date, events, countdown, progress,
locale, clock preference, and deep-link actions as versioned JSON.

`CalendarHomeWidget` renders the same payload inside Flutter for previews,
settings screens, screenshots, and tests. `CalendarHomeWidgetBridge` stores and
refreshes it through this method channel:

```text
dev.ahmedzaeem.horizontal_weekly_calendar/home_widgets
```

Supported methods are `update` with the payload map and `refresh` without
arguments. Both return `true` when a native host handled the request and
`false` when no host is installed, such as web or a unit test.

Pass a `CalendarHomeWidgetConfiguration` to keep the content and portable theme
beside the data:

```dart
final configuration = CalendarHomeWidgetConfiguration(
  family: CalendarHomeWidgetFamily.medium,
  content: CalendarHomeWidgetContent.agenda,
  theme: const CalendarHomeWidgetTheme(
    surfaceStyle: CalendarHomeWidgetSurfaceStyle.gradient,
    gradientColors: [Color(0xff07111f), Color(0xff183f4d)],
    headerStyle: CalendarHomeWidgetHeaderStyle.month,
    eventStyle: CalendarHomeWidgetEventStyle.card,
    dateShape: CalendarHomeWidgetDateShape.rounded,
    progressStyle: CalendarHomeWidgetProgressStyle.segmented,
    weekdayFormat: CalendarHomeWidgetWeekdayFormat.short,
    maximumEvents: 4,
    showLocation: true,
  ),
);

await const CalendarHomeWidgetBridge().update(
  data,
  configuration: configuration,
);
```

The old `update(data)` call is unchanged. Current hosts find configuration in
the optional top-level `configuration` map, so older hosts safely ignore it.

## Android

The example contains a complete `CalendarHomeWidgetProvider`, three responsive
`RemoteViews` layouts, provider metadata, widget-picker preview, manifest
registration, persistent JSON storage, resize handling, and a deep link. Copy
these files into the consuming application and change the Kotlin package:

```text
example/android/app/src/main/kotlin/.../CalendarHomeWidgetProvider.kt
example/android/app/src/main/res/layout/calendar_widget_*.xml
example/android/app/src/main/res/xml/calendar_home_widget_info.xml
```

Register the receiver in the application manifest and register the method
channel in the app's `FlutterActivity`. Keep `PREFERENCES` and `PAYLOAD_KEY`
stable between both classes. The provider selects small, medium, or large
geometry from the launcher's current width and height and updates again from
`onAppWidgetOptionsChanged`.

The example provider consumes portable background, foreground, secondary,
accent, header, weekday-format, content, event-detail, event-limit, and
visibility values. Dynamic `RemoteViews` cannot reproduce Flutter blur,
arbitrary shadows, or animated gradients; gradient, glass, and transparent
surfaces therefore use a readable solid-color fallback. The payload's event
colors are ARGB integers. Point action URIs at a scheme registered by the
application so a widget tap opens the correct date or event.

## iOS

WidgetKit requires a separate SwiftUI extension target; a Dart package cannot
inject or sign that target in a consuming Xcode project. The example includes
the complete `CalendarWidgets` target, source, Info.plist, entitlements, embed
phase, timeline provider, deep link, and size-specific views.

1. Replace the example bundle identifiers with identifiers owned by your team.
2. Enable App Groups for the Runner and widget-extension targets in Xcode.
3. Replace
   `group.com.ahmedzaeem.horizontalWeeklyCalendarExample` in both entitlement
   files, `AppDelegate.swift`, and `CalendarWidgets.swift` with your group.
4. Keep the payload key `calendar_widget_payload` and WidgetKit kind aligned.
5. Register your action URL scheme in Runner's Info.plist.
6. Select a development team and provisioning profiles for both targets.

The extension supports system small, medium, large, extra large, circular,
rectangular, and inline accessory families. The timeline refreshes at least
every 30 minutes and refreshes immediately when the Flutter bridge saves a new
payload. If shared storage is unavailable, deterministic placeholder content
keeps the widget useful and the host app unaffected.

The SwiftUI host consumes the same portable colors, header, content, weekday,
event-detail, event-limit, and visibility values. WidgetKit owns refresh timing
and system margins, and does not run Flutter animations. Effects unsupported by
the host resolve to the configured background or the first gradient color.

## Flutter preview customization

`CalendarHomeWidgetTheme` controls five surface treatments, four header modes,
four event treatments, four selected-date shapes, four progress treatments,
four weekday formats, four densities, two-color gradients, borders, elevation,
corner radius, type scale, content padding, item spacing, event-indicator
width, event limits, information visibility, event colors, and change motion.
Every option is available in the example's `/home-widget-studio` route.

Flutter previews implement the complete theme. Android and iOS consume the
portable subset described above because system home-screen processes render
`RemoteViews` or SwiftUI, not arbitrary Flutter widget trees.

## Payload evolution

The current data and configuration `schemaVersion` values are both `1`. Native
hosts should treat missing or invalid payloads as an empty/placeholder state,
not crash. When extending the contract, add optional fields first and increment
the version only for incompatible changes. Always round-trip payloads and
configuration in Dart tests before changing native views.
