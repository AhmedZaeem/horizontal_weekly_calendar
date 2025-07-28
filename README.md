# ☕️ Support My Work!
[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-4B0082?style=for-the-badge&logo=buymeacoffee&logoColor=white)](https://www.buymeacoffee.com/ahmedzaeem)

---

# 🚀 horizontal_weekly_calendar v1.1.5 — All-New Features!

**v1.1.5 is here!** This update brings two powerful new calendar types:

- **TableWeeklyCalendar**: A full table-style monthly calendar with week rows, focus dates, and custom header support.
- **EventCalendar**: A professional event calendar view with time slots, event blocks, and full customization.

All previous styles (Standard, Outlined, Minimal, Elevated) are still available and improved! Now you can showcase and compare all calendar types in your app.

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
  - **TableWeeklyCalendar** (NEW)
  - **EventCalendar** (NEW)

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
- **Table & Event Views** (NEW!)
- **Focus Dates, Custom Headers, and More!**

## 🆕 What's New in 1.1.5

- **TableWeeklyCalendar**: Display a full month in a table layout, highlight focus dates, and add custom headers.
- **EventCalendar**: Show events in a time-grid, with custom event widgets and time slots.
- **Improved Example App**: See all calendar types side-by-side for easy comparison.
- **Bug Fixes & Performance Improvements**

## 🔧 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  horizontal_weekly_calendar: ^1.1.5
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
