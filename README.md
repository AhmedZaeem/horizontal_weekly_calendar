# 📅 Horizontal Weekly Calendar

## 🌟 Project Overview

A **feature-rich**, *highly customizable* horizontal calendar widget for Flutter applications, designed to provide seamless date selection and beautiful UI experiences.

> **Note:** This widget supports multiple display modes and offers smooth animations!

### 🎨 Visual Demonstration


## ✨ Key Features

- **4 Built-in Styles**
  - Standard
    ![Standard](https://github.com/user-attachments/assets/07b6ed0a-878b-408f-9f0c-758dff22c806)
  - Outlined
    ![Outlined](https://github.com/user-attachments/assets/f02deb5f-7896-42f7-9a87-76e51e242ef0)
  - Minimal
    ![Minimal](https://github.com/user-attachments/assets/e7580224-08bf-4d72-914e-5497ba8db19d)
  - Elevated
   ![Elevated](https://github.com/user-attachments/assets/9a7e7a88-3253-4eb4-9459-7cfdc45a0762)

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

