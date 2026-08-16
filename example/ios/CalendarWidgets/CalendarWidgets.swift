import SwiftUI
import WidgetKit

private enum Contract {
  static let appGroup = "group.com.ahmedzaeem.horizontalWeeklyCalendarExample"
  static let payloadKey = "calendar_widget_payload"
  static let kind = "HorizontalWeeklyCalendarWidget"
}

private struct CalendarPayload: Decodable {
  struct Action: Decodable { let uri: String }
  struct Configuration: Decodable {
    struct Theme: Decodable {
      let backgroundColor: Int?
      let foregroundColor: Int?
      let secondaryColor: Int?
      let accentColor: Int?
      let surfaceStyle: String?
      let gradientColors: [Int]?
      let headerStyle: String?
      let weekdayFormat: String?
      let maximumEvents: Int?
      let showWeekday: Bool?
      let showEventTime: Bool?
      let showSubtitle: Bool?
      let showLocation: Bool?
      let useEventColors: Bool?
    }

    let family: String?
    let content: String?
    let theme: Theme?
  }

  struct Event: Decodable {
    let id: String
    let title: String
    let subtitle: String?
    let location: String?
    let start: String
    let end: String
    let colorValue: Int?
    let action: Action?
  }

  let selectedDate: String
  let title: String?
  let subtitle: String?
  let events: [Event]
  let action: Action?
  let targetDate: String?
  let completedCount: Int?
  let totalCount: Int?
  let configuration: Configuration?

  static let placeholder = CalendarPayload(
    selectedDate: "2026-08-10T00:00:00.000",
    title: "My week",
    subtitle: "A calm, focused day",
    events: [Event(
      id: "review",
      title: "Design review",
      subtitle: nil,
      location: "Studio",
      start: "2026-08-10T09:00:00.000",
      end: "2026-08-10T10:00:00.000",
      colorValue: nil,
      action: nil
    )],
    action: Action(uri: "calendar-example://day/2026-08-10"),
    targetDate: "2026-08-24T00:00:00.000",
    completedCount: 3,
    totalCount: 5,
    configuration: nil
  )

  static func load() -> CalendarPayload {
    guard
      let encoded = UserDefaults(suiteName: Contract.appGroup)?.string(forKey: Contract.payloadKey),
      let data = encoded.data(using: .utf8),
      let payload = try? JSONDecoder().decode(CalendarPayload.self, from: data)
    else { return .placeholder }
    return payload
  }
}

private struct CalendarEntry: TimelineEntry {
  let date: Date
  let payload: CalendarPayload
}

private struct CalendarProvider: TimelineProvider {
  func placeholder(in context: Context) -> CalendarEntry {
    CalendarEntry(date: .now, payload: .placeholder)
  }

  func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
    completion(CalendarEntry(date: .now, payload: context.isPreview ? .placeholder : .load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
    let entry = CalendarEntry(date: .now, payload: .load())
    completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(30 * 60))))
  }
}

private struct CalendarWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: CalendarEntry

  private var theme: CalendarPayload.Configuration.Theme? {
    entry.payload.configuration?.theme
  }

  private var content: String {
    entry.payload.configuration?.content ?? "week"
  }

  private var foreground: Color {
    Color(argb: theme?.foregroundColor ?? 0xffffffff)
  }

  private var secondary: Color {
    Color(argb: theme?.secondaryColor ?? 0xffaeb4c5)
  }

  private var accent: Color {
    Color(argb: theme?.accentColor ?? 0xff9f8cff)
  }

  private var surface: Color {
    let fallback = theme?.backgroundColor ?? 0xff11131a
    let value = theme?.surfaceStyle == "gradient"
      ? theme?.gradientColors?.first ?? fallback
      : fallback
    return Color(argb: value)
  }

  private var maximumEvents: Int {
    min(max(theme?.maximumEvents ?? 5, 0), 12)
  }

  private var showSubtitle: Bool { theme?.showSubtitle ?? true }
  private var showLocation: Bool { theme?.showLocation ?? true }
  private var showEventTime: Bool { theme?.showEventTime ?? true }
  private var showWeekday: Bool { theme?.showWeekday ?? true }

  private var headerLabel: String? {
    switch theme?.headerStyle ?? "title" {
    case "hidden": return nil
    case "month": return selected.formatted(.dateTime.month(.wide).year())
    case "compact": return selected.formatted(.dateTime.month(.abbreviated).day())
    default: return entry.payload.title ?? "My calendar"
    }
  }

  private var selected: Date {
    let prefix = String(entry.payload.selectedDate.prefix(10))
    return ISO8601DateFormatter().date(from: "\(prefix)T00:00:00Z") ?? .now
  }

  private var actionURL: URL? {
    URL(string: entry.payload.action?.uri ?? "calendar-example://calendar")
  }

  var body: some View {
    Group {
      switch family {
      case .accessoryCircular, .accessoryInline, .accessoryRectangular:
        accessory
      case .systemSmall:
        small
      case .systemMedium:
        medium
      case .systemLarge, .systemExtraLarge:
        large
      default:
        small
      }
    }
    .widgetURL(actionURL)
    .foregroundStyle(foreground)
    .calendarWidgetBackground(surface)
  }

  private var accessory: some View {
    VStack(spacing: 0) {
      Text(selected, format: .dateTime.day())
        .font(.system(.title2, design: .rounded, weight: .bold))
      Text(selected, format: .dateTime.month(.abbreviated))
        .font(.caption2.weight(.semibold))
    }
  }

  private var small: some View {
    VStack(alignment: .leading, spacing: 6) {
      if let headerLabel {
        Text(headerLabel)
          .font(.caption.weight(.semibold))
          .lineLimit(1)
      }
      Spacer()
      HStack(alignment: .lastTextBaseline, spacing: 6) {
        Text(selected, format: .dateTime.day())
          .font(.system(size: 48, weight: .bold, design: .rounded))
        Text(selected, format: .dateTime.month(.abbreviated))
          .font(.caption.weight(.bold))
          .foregroundStyle(accent)
      }
      if showSubtitle {
        Text(entry.payload.subtitle ?? "Tap to open your week")
          .font(.caption2)
          .foregroundStyle(secondary)
          .lineLimit(1)
      }
    }
    .padding(16)
  }

  private var medium: some View {
    HStack(spacing: 16) {
      VStack(spacing: 0) {
        Text(selected, format: .dateTime.month(.abbreviated))
          .font(.caption.weight(.bold))
          .foregroundStyle(accent)
        Text(selected, format: .dateTime.day())
          .font(.system(size: 46, weight: .bold, design: .rounded))
      }
      Divider()
      VStack(alignment: .leading, spacing: 6) {
        if let headerLabel {
          Text(headerLabel)
            .font(.headline)
            .lineLimit(1)
        }
        if maximumEvents == 0 {
          Text("Calendar ready")
            .font(.subheadline)
            .foregroundStyle(secondary)
        } else if content == "progress" || content == "countdown" {
          Text(summaryTitle)
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
          Text(summaryDetail)
            .font(.caption)
            .foregroundStyle(secondary)
            .lineLimit(1)
        } else if let event = entry.payload.events.first {
          Label(event.title, systemImage: "circle.fill")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(eventColor(event))
            .lineLimit(1)
          Text(eventDetails(event))
            .font(.caption)
            .foregroundStyle(secondary)
            .lineLimit(1)
        } else {
          Text("Your calendar is clear")
            .font(.subheadline)
            .foregroundStyle(secondary)
        }
      }
      Spacer(minLength: 0)
    }
    .padding(16)
  }

  private var large: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        VStack(alignment: .leading) {
          if let headerLabel {
            Text(headerLabel)
              .font(.headline)
          }
          if showSubtitle {
            Text(entry.payload.subtitle ?? "Your week at a glance")
              .font(.caption)
              .foregroundStyle(secondary)
          }
        }
        Spacer()
        Text(selected, format: .dateTime.month(.abbreviated).day())
          .font(.title2.bold())
      }
      if content == "week" && showWeekday && theme?.weekdayFormat != "hidden" {
        HStack(spacing: 6) {
          ForEach(0..<7, id: \.self) { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset - 3, to: selected) ?? selected
            VStack(spacing: 5) {
              Text(weekdayLabel(date))
                .font(.caption2)
                .foregroundStyle(secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
              Text(date, format: .dateTime.day())
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity, minHeight: 28)
                .background(Calendar.current.isDate(date, inSameDayAs: selected) ? accent : Color.clear)
                .clipShape(Circle())
            }
            .frame(maxWidth: .infinity)
          }
        }
      }
      Divider()
      if maximumEvents == 0 {
        Label("Event details hidden", systemImage: "eye.slash")
          .font(.subheadline)
          .foregroundStyle(secondary)
      } else if content == "progress" || content == "countdown" {
        HStack(spacing: 9) {
          Capsule().fill(accent).frame(width: 4, height: 30)
          VStack(alignment: .leading, spacing: 2) {
            Text(summaryTitle).font(.subheadline.weight(.semibold)).lineLimit(1)
            Text(summaryDetail).font(.caption2).foregroundStyle(secondary).lineLimit(1)
          }
        }
      } else if entry.payload.events.isEmpty {
        Label("Nothing scheduled", systemImage: "calendar.badge.checkmark")
          .font(.subheadline)
          .foregroundStyle(secondary)
      } else {
        ForEach(entry.payload.events.prefix(min(maximumEvents, 3)), id: \.id) { event in
          HStack(spacing: 9) {
            Capsule().fill(eventColor(event)).frame(width: 4, height: 30)
            VStack(alignment: .leading, spacing: 2) {
              Text(event.title).font(.subheadline.weight(.semibold)).lineLimit(1)
              Text(eventDetails(event))
                .font(.caption2).foregroundStyle(secondary).lineLimit(1)
            }
          }
        }
      }
      Spacer(minLength: 0)
    }
    .padding(18)
  }

  private var summaryTitle: String {
    if content == "progress" {
      return "\(entry.payload.completedCount ?? 0) of \(entry.payload.totalCount ?? 0) complete"
    }
    let targetPrefix = String((entry.payload.targetDate ?? entry.payload.selectedDate).prefix(10))
    let target = ISO8601DateFormatter().date(from: "\(targetPrefix)T00:00:00Z") ?? selected
    let days = abs(Calendar.current.dateComponents([.day], from: selected, to: target).day ?? 0)
    return days == 1 ? "1 day remaining" : "\(days) days remaining"
  }

  private var summaryDetail: String {
    if content == "progress" {
      let completed = entry.payload.completedCount ?? 0
      let total = entry.payload.totalCount ?? 0
      let percent = total == 0 ? 0 : min(max(completed * 100 / total, 0), 100)
      return "\(percent)% progress"
    }
    return showSubtitle ? entry.payload.subtitle ?? "Countdown" : "Countdown"
  }

  private func eventColor(_ event: CalendarPayload.Event) -> Color {
    guard theme?.useEventColors ?? true, let value = event.colorValue else { return accent }
    return Color(argb: value)
  }

  private func eventDetails(_ event: CalendarPayload.Event) -> String {
    var parts: [String] = []
    if showEventTime, let start = clock(event.start), let end = clock(event.end) {
      parts.append("\(start)–\(end)")
    }
    if showSubtitle, let subtitle = event.subtitle, !subtitle.isEmpty {
      parts.append(subtitle)
    }
    if showLocation, let location = event.location, !location.isEmpty {
      parts.append(location)
    }
    return parts.isEmpty ? "Scheduled" : parts.joined(separator: " · ")
  }

  private func clock(_ value: String) -> String? {
    guard value.count >= 16 else { return nil }
    let start = value.index(value.startIndex, offsetBy: 11)
    let end = value.index(start, offsetBy: 5)
    return String(value[start..<end])
  }

  private func weekdayLabel(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = .current
    formatter.dateFormat = switch theme?.weekdayFormat ?? "narrow" {
    case "short": "EEE"
    case "full": "EEEE"
    default: "EEEEE"
    }
    return formatter.string(from: date)
  }
}

private extension View {
  @ViewBuilder
  func calendarWidgetBackground(_ color: Color) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(color, for: .widget)
    } else {
      background(color)
    }
  }
}

private extension Color {
  init(argb: Int) {
    let value = UInt64(bitPattern: Int64(argb))
    self.init(
      .sRGB,
      red: Double((value >> 16) & 0xff) / 255,
      green: Double((value >> 8) & 0xff) / 255,
      blue: Double(value & 0xff) / 255,
      opacity: Double((value >> 24) & 0xff) / 255
    )
  }
}

@main
struct HorizontalWeeklyCalendarWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: Contract.kind, provider: CalendarProvider()) { entry in
      CalendarWidgetView(entry: entry)
    }
    .configurationDisplayName("Calendar UI Kit")
    .description("Your date, week, agenda, and next event at a glance.")
    .supportedFamilies([
      .systemSmall,
      .systemMedium,
      .systemLarge,
      .systemExtraLarge,
      .accessoryCircular,
      .accessoryRectangular,
      .accessoryInline,
    ])
  }
}
