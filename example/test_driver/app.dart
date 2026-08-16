import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

void main() {
  enableFlutterDriverExtension();
  runApp(const _VisualHarness());
}

class _VisualHarness extends StatefulWidget {
  const _VisualHarness();

  @override
  State<_VisualHarness> createState() => _VisualHarnessState();
}

class _VisualHarnessState extends State<_VisualHarness> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5547D7)),
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  key: const ValueKey('open-material-sheet'),
                  onPressed: () => showAdaptiveCalendarPicker(
                    context: context,
                    initialDate: DateTime(2026, 8, 5),
                    bounds: CalendarDateRange(
                      DateTime(2026, 1, 1),
                      DateTime(2027, 12, 31),
                    ),
                    appearance:
                        const CalendarAppearance(style: CalendarStyle.material),
                    materialConfiguration:
                        const CalendarMaterialPickerConfiguration(
                      confirmSelection: true,
                      showQuickActions: true,
                      headline: 'Plan something remarkable',
                      helpText: 'Pick a day, then confirm when it feels right.',
                    ),
                  ),
                  child: const Text('Open material sheet'),
                ),
                FilledButton(
                  key: const ValueKey('open-material-dialog'),
                  onPressed: () => showAdaptiveCalendarPicker(
                    context: context,
                    initialDate: DateTime(2026, 8, 5),
                    appearance:
                        const CalendarAppearance(style: CalendarStyle.material),
                    materialConfiguration:
                        const CalendarMaterialPickerConfiguration(
                      presentation: CalendarMaterialPickerPresentation.dialog,
                    ),
                  ),
                  child: const Text('Open material dialog'),
                ),
                FilledButton(
                  key: const ValueKey('open-cupertino-wheel'),
                  onPressed: () => showAdaptiveCalendarPicker(
                    context: context,
                    initialDate: DateTime(2026, 8, 5),
                    appearance: const CalendarAppearance(
                      style: CalendarStyle.cupertinoTinted,
                    ),
                    cupertinoPresentation:
                        CalendarCupertinoPickerPresentation.wheel,
                    cupertinoWheelConfiguration:
                        const CalendarCupertinoPickerConfiguration(
                      showDayOfWeek: true,
                    ),
                  ),
                  child: const Text('Open cupertino wheel'),
                ),
                FilledButton(
                  key: const ValueKey('open-cupertino-calendar'),
                  onPressed: () => showAdaptiveCalendarPicker(
                    context: context,
                    initialDate: DateTime(2026, 8, 5),
                    appearance: const CalendarAppearance(
                      style: CalendarStyle.cupertino,
                    ),
                  ),
                  child: const Text('Open cupertino calendar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
