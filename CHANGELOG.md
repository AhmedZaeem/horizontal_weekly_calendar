# Changelog

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