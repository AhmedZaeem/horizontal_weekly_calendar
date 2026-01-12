import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calendar Generation Tests', () {
    test('August 2025 should have 31 days', () {
      final firstDayOfMonth = DateTime(2025, 8, 1);
      final lastDayOfMonth = DateTime(2025, 8 + 1, 0);

      expect(lastDayOfMonth.day, 31);
      expect(lastDayOfMonth.month, 8);
    });

    test('October 2025 should have 31 days', () {
      final firstDayOfMonth = DateTime(2025, 10, 1);
      final lastDayOfMonth = DateTime(2025, 10 + 1, 0);

      expect(lastDayOfMonth.day, 31);
      expect(lastDayOfMonth.month, 10);
    });

    test('Week generation for August 2025 starting Monday', () {
      final date = DateTime(2025, 8, 1);
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
      final startDay = DateTime.monday;

      int daysToSubtract = (firstDayOfMonth.weekday - startDay + 7) % 7;
      DateTime weekStart = firstDayOfMonth.subtract(Duration(days: daysToSubtract));

      int daysToAdd = (6 - (lastDayOfMonth.weekday - startDay + 7) % 7);
      DateTime weekEnd = lastDayOfMonth.add(Duration(days: daysToAdd));

      final totalDays = weekEnd.difference(weekStart).inDays + 1;
      final numberOfWeeks = (totalDays / 7).ceil();

      final weeks = List.generate(numberOfWeeks, (weekIndex) {
        return List.generate(7, (dayIndex) {
          return weekStart.add(Duration(days: (weekIndex * 7) + dayIndex));
        });
      });

      final allDatesInMonth = weeks.expand((week) => week).where((day) => day.month == 8).toList();

      expect(allDatesInMonth.length, 31);
      expect(allDatesInMonth.first.day, 1);
      expect(allDatesInMonth.last.day, 31);
    });

    test('Week generation for October 2025 starting Saturday', () {
      final date = DateTime(2025, 10, 1);
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
      final startDay = DateTime.saturday;

      int daysToSubtract = (firstDayOfMonth.weekday - startDay + 7) % 7;
      DateTime weekStart = firstDayOfMonth.subtract(Duration(days: daysToSubtract));

      int daysToAdd = (6 - (lastDayOfMonth.weekday - startDay + 7) % 7);
      DateTime weekEnd = lastDayOfMonth.add(Duration(days: daysToAdd));

      final totalDays = weekEnd.difference(weekStart).inDays + 1;
      final numberOfWeeks = (totalDays / 7).ceil();

      final weeks = List.generate(numberOfWeeks, (weekIndex) {
        return List.generate(7, (dayIndex) {
          return weekStart.add(Duration(days: (weekIndex * 7) + dayIndex));
        });
      });

      final allDatesInMonth = weeks.expand((week) => week).where((day) => day.month == 10).toList();
      final allDaysNumbers = weeks.expand((week) => week).map((day) => day.day).toList();

      expect(allDatesInMonth.length, 31);
      expect(allDatesInMonth.first.day, 1);
      expect(allDatesInMonth.last.day, 31);

      final duplicates = <int>[];
      final seen = <int>{};
      for (var day in allDaysNumbers) {
        if (seen.contains(day) && !duplicates.contains(day)) {
          duplicates.add(day);
        }
        seen.add(day);
      }

      expect(duplicates.isEmpty, false);
    });
  });
}

