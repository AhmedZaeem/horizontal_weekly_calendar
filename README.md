# ☕️ Support My Work!
[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-4B0082?style=for-the-badge&logo=buymeacoffee&logoColor=white)](https://www.buymeacoffee.com/ahmedzaeem)

---

# 🚀 horizontal_weekly_calendar v1.3.0 — DST Fix & Code Quality

**v1.3.0 is here!** This update fixes a critical calendar generation bug and improves code quality:

- **DST Calendar Fix**: Fixed a bug where months crossing daylight saving time boundaries could show missing days, duplicate days, or incomplete weeks. All date math now uses DST-safe `DateTime` constructor arithmetic.
- **Shared Utilities**: Extracted common calendar logic into `calendar_utils.dart` for a single source of truth.
- **552+ Tests**: Comprehensive test suite covering every month from 2024–2028 with all 7 starting days, plus widget tests for all calendar types.
- **Overlapping Event Support**: Events that overlap in time are displayed side by side.
- **TableWeeklyCalendar**: A full table-style monthly calendar with week rows, focus dates, and custom header support.
- **EventCalendar**: A professional event calendar view with time slots, event blocks, and full customization.
- **Date Range Restrictions**: Set `minDate` and `maxDate` on all calendar widgets with automatic navigation disabling.

All previous styles (Standard, Outlined, Minimal, Elevated) are still available and improved!

---

# 📅 Horizontal Weekly Calendar

## 🌟 Project Overview

A **feature-rich**, *highly customizable* horizontal calendar widget for Flutter applications, designed to provide seamless date selection and beautiful UI experiences.

> **Note:** This widget supports multiple display modes and offers smooth animations!

### 🎨 Visual Demonstration

## ✨ Key Features

- **6 Built-in Styles**
  - Standard
  - Outlined
  - Minimal
  - Elevated
  - **TableWeeklyCalendar**
  - **EventCalendar**

| Style                | Preview                                                                                                                                     |
|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| **Standard**        | <img src="https://github.com/user-attachments/assets/07b6ed0a-878b-408f-9f0c-758dff22c806" width="200" height="450" alt="Standard Style" /> |
| **Outlined**        | <img src="https://github.com/user-attachments/assets/f02deb5f-7896-42f7-9a87-76e51e242ef0" width="200" height="450" alt="Outlined Style" /> |
| **Minimal**         | <img src="https://github.com/user-attachments/assets/e7580224-08bf-4d72-914e-5497ba8db19d" width="200" height="450" alt="Minimal Style" />  |
| **Elevated**        | <img src="https://github.com/user-attachments/assets/9a7e7a88-3253-4eb4-9459-7cfdc45a0762" width="200" height="450" alt="Elevated Style" /> |
| **Table Calendar**  | <img src="https://github.com/user-attachments/assets/b2816295-b1d4-467c-8897-456edc62db9f" width="200" height="450" alt="Table Style" >     |
| **Event Calendar**  | <img src="https://github.com/user-attachments/assets/6d3616e2-b577-4432-a43c-e0c1eda41a63" width="200" height="450" alt="Event Style" >     |

- **Flexible Date Selection**
- **Month Navigation Controls**
- **Fully Customizable Theming**
- **Table & Event Views**
- **Focus Dates, Custom Headers, and More!**
- **Overlapping Event Support**
- **Min/Max Date Restrictions**

## 🆕 What's New in 1.3.0

- **Fixed DST-related calendar generation bug**: Months crossing daylight saving time boundaries (March, April, October, November) could show missing or duplicate days. All date calculations now use DST-safe arithmetic.
- **Fixed table calendar missing days**: Certain month/starting-day combinations (e.g., March 2026 with Saturday start) would only show 27 days instead of 31.
- **Fixed horizontal weekly calendar day drift**: Custom starting days could cause off-by-one errors near DST transitions.
- **Shared calendar utilities**: Common logic extracted into `calendar_utils.dart` — `generateWeeks`, `isSameDay`, `isDateDisabled`, `canNavigateToPreviousMonth`, `canNavigateToNextMonth`, `buildNavigationIcon`.
- **552+ tests**: Full coverage of calendar generation across 5 years × 12 months × 7 starting days, plus widget tests for all calendar types.

## 🆕 What's New in 1.2.8

- **Overlapping Event Support**: Events that overlap in time are now displayed side by side instead of stacking on top of each other.
- **Smart Event Layout**: When multiple events overlap, they automatically split the available horizontal space equally.
- **Customizable Event Margin**: Added `overlappingEventMargin` property to `EventCalendarStyle` for controlling the spacing between side-by-side events (default: 2.0).

## 🆕 What's New in 1.2.7

- **Date Range Restrictions**: Set `minDate` and `maxDate` on all calendar widgets to restrict selectable dates.
- **Disabled Date Styling**: Customize disabled dates with `disabledDayTextStyle` and `disabledDayColor` in HorizontalCalendarStyle.
- **Non-Clickable Disabled Dates**: Dates outside the allowed range are visually distinct and cannot be selected.
- **Navigation Boundary Enforcement**: Previous/next month buttons are automatically disabled when reaching minDate/maxDate boundaries.

## 🔧 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  horizontal_weekly_calendar: ^1.3.0
```

## 💡 Quick Start

```dart
HorizontalWeeklyCalendar(
  initialDate: DateTime.now(),
  selectedDate: _selectedDate,
  onDateSelected: (date) => setState(() => _selectedDate = date),
)
```

## 🛠 Customization Options

### Style Configuration

```dart
HorizontalCalendarStyle(
  activeDayColor: Colors.blue,
  dayIndicatorSize: 40,
  monthHeaderStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
)
```

### Date Range Restrictions

```dart
HorizontalWeeklyCalendar(
  initialDate: DateTime.now(),
  selectedDate: _selectedDate,
  onDateSelected: (date) => setState(() => _selectedDate = date),
  minDate: DateTime(2026, 1, 1),
  maxDate: DateTime(2026, 12, 31),
  calendarStyle: HorizontalCalendarStyle(
    disabledDayTextStyle: TextStyle(fontSize: 16, color: Colors.grey.shade300),
    disabledDayColor: Colors.grey.shade100,
  ),
)
```

### Overlapping Events

```dart
EventCalendar(
  currentMonth: DateTime.now(),
  selectedDate: _selectedDate,
  events: myEvents,
  onDateSelected: (date) => setState(() => _selectedDate = date),
  onNextMonth: () {},
  onPreviousMonth: () {},
  style: EventCalendarStyle(
    overlappingEventMargin: 4.0,
  ),
)
```

## 🌈 Theming Support

The calendar adapts seamlessly to your app's theme:

```dart
Theme(
  data: ThemeData(
    colorScheme: ColorScheme.light(
      primary: Colors.purple,
      secondary: Colors.orange,
    ),
  ),
  child: HorizontalWeeklyCalendar(...),
)
```

## 📚 API Reference

| Parameter | Description | Type | Required |
|:---------|:------------|:-----|:--------:|
| `initialDate` | Starting display month | `DateTime` | ✅ |
| `selectedDate` | Currently selected date | `DateTime` | ✅ |
| `onDateSelected` | Date selection callback | `Function(DateTime)` | ✅ |
| `calendarType` | Display style type | `HorizontalCalendarType` | ❌ |
| `calendarStyle` | Visual styling configuration | `HorizontalCalendarStyle` | ❌ |
| `minDate` | Minimum selectable date | `DateTime?` | ❌ |
| `maxDate` | Maximum selectable date | `DateTime?` | ❌ |
| `startingDay` | First day of the week | `Weekday?` | ❌ |
| `enableAnimations` | Toggle all animations | `bool` | ❌ |
| `showMonthHeader` | Show/hide month header | `bool` | ❌ |
| `previousMonthIcon` | Custom previous icon | `IconData?` | ❌ |
| `nextMonthIcon` | Custom next icon | `IconData?` | ❌ |
| `iconColor` | Navigation icon color | `Color?` | ❌ |

## 📁 File Structure

```
lib/
  weekly_calendar.dart          # Package exports
  src/
    calendar_utils.dart         # Shared utilities (generateWeeks, isSameDay, etc.)
    calendar_with_event.dart    # EventCalendar widget
    horizontal_weekly_calendar_widget.dart  # HorizontalWeeklyCalendar widget
    table_weekly_calendar.dart  # TableWeeklyCalendar widget
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. 🍴 Fork the repository
2. 🌿 Create a feature branch
3. 💾 Commit your changes
4. 📤 Push to the branch
5. 🔀 Open a Pull Request

## 📄 License

**MIT License** - See `LICENSE` file for details.

---

**Crafted with ❤️ by github.com/ahmedzaeem**
