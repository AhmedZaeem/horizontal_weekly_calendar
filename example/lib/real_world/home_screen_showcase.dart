import 'package:flutter/material.dart';
import 'package:horizontal_weekly_calendar/horizontal_weekly_calendar.dart';

import 'data.dart';

/// Every widget family placed on a phone home screen.
///
/// The families are drawn at the point sizes iOS and Android actually give a
/// widget in a 4-column grid, so the preview reflects the real thing rather
/// than an arbitrarily sized card.
class HomeScreenShowcasePage extends StatelessWidget {
  const HomeScreenShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9F8CFF),
          brightness: Brightness.dark,
        ),
      ),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2B2350),
                Color(0xFF141A32),
                Color(0xFF0B1220),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // A home-screen cell plus its gutter, derived the way a
                // launcher derives it: four columns across the usable width.
                const gutter = 14.0;
                const padding = 18.0;
                final cell =
                    (constraints.maxWidth - padding * 2 - gutter * 3) / 4;
                final small = cell * 2 + gutter;
                final medium = cell * 4 + gutter * 3;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    padding,
                    10,
                    padding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Clock(),
                      const SizedBox(height: 14),
                      _Row(
                        label: 'Small · countdown and progress',
                        child: Row(
                          children: [
                            SizedBox(
                              width: small,
                              height: small,
                              child: CalendarHomeWidget(
                                data: heroWidgetData,
                                family: CalendarHomeWidgetFamily.small,
                                content: CalendarHomeWidgetContent.countdown,
                                theme: heroWidgetTheme,
                              ),
                            ),
                            const SizedBox(width: gutter),
                            SizedBox(
                              width: small,
                              height: small,
                              child: CalendarHomeWidget(
                                data: heroWidgetData,
                                family: CalendarHomeWidgetFamily.small,
                                content: CalendarHomeWidgetContent.progress,
                                theme: heroWidgetTheme,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Row(
                        label: 'Medium · this week',
                        child: SizedBox(
                          width: medium,
                          height: small,
                          child: CalendarHomeWidget(
                            data: heroWidgetData,
                            family: CalendarHomeWidgetFamily.medium,
                            content: CalendarHomeWidgetContent.week,
                            theme: heroWidgetTheme,
                          ),
                        ),
                      ),
                      _Row(
                        label: 'Large · agenda',
                        child: SizedBox(
                          width: medium,
                          height: small * 1.34,
                          child: CalendarHomeWidget(
                            data: heroWidgetData,
                            family: CalendarHomeWidgetFamily.large,
                            content: CalendarHomeWidgetContent.agenda,
                            theme: heroWidgetTheme,
                          ),
                        ),
                      ),
                      _Row(
                        label: 'Accessory · lock screen',
                        child: SizedBox(
                          width: medium,
                          height: 62,
                          child: CalendarHomeWidget(
                            data: heroWidgetData,
                            family: CalendarHomeWidgetFamily.accessory,
                            content: CalendarHomeWidgetContent.today,
                            theme: heroWidgetTheme,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Clock extends StatelessWidget {
  const _Clock();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              height: 1.05,
              fontWeight: FontWeight.w300,
              letterSpacing: -1,
            ),
          ),
          Text(
            'Wednesday 12 August',
            style: TextStyle(
              color: Color(0xFFD5DDF2),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF93A2C6),
              fontSize: 10.5,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
