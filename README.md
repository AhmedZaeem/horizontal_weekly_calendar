# 📅 Horizontal Weekly Calendar

## 🌟 Project Overview

A **feature-rich**, *highly customizable* horizontal calendar widget for Flutter applications, designed to provide seamless date selection and beautiful UI experiences.

> **Note:** This widget supports multiple display modes and offers smooth animations!

### 🎨 Visual Demonstration


## ✨ Key Features

- **4 Built-in Styles**
  - Standard
    ![standard](https://github.com/user-attachments/assets/e99e3a26-9341-4b3b-a904-b4910468def1)
  - Outlined
    ![Outlined](https://github.com/user-attachments/assets/9cc509a9-9aa1-4467-9069-41f4fec47d80)
  - Minimal
    ![Minimal](https://github.com/user-attachments/assets/8c7d25bc-1d2b-40f2-bab4-58001f5b28a9)
  - Elevated
    ![Elevated](https://github.com/user-attachments/assets/179644f1-057c-44dd-ab34-4b79aaff5381)

- **Flexible Date Selection**
- **Month Navigation Controls**
- **Fully Customizable Theming**

## 🔧 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  horizontal_weekly_calendar: ^0.1.0
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
```

