void main() {
  print('Testing specific problem months...\n');

  print('═' * 70);
  print('AUGUST 2025 - Saturday Start');
  print('═' * 70);
  testMonthDetailed(2025, 8, 6);

  print('\n${'═' * 70}');
  print('OCTOBER 2025 - Saturday Start');
  print('═' * 70);
  testMonthDetailed(2025, 10, 6);

  print('\n${'═' * 70}');
  print('TESTING ALL MONTHS OF 2025');
  print('═' * 70);
  testAllMonths();
}

void testMonthDetailed(int year, int month, int startDay) {
  final firstDayOfMonth = DateTime(year, month, 1);
  final lastDayOfMonth = DateTime(year, month + 1, 0);

  print('Month: ${_monthName(month)} $year');
  print('First day: ${firstDayOfMonth.day} ${_monthName(month)} (${_weekdayName(firstDayOfMonth.weekday)})');
  print('Last day: ${lastDayOfMonth.day} ${_monthName(month)} (${_weekdayName(lastDayOfMonth.weekday)})');
  print('Week starts on: ${_weekdayName(startDay)}\n');

  int daysToSubtract = (firstDayOfMonth.weekday - startDay + 7) % 7;
  DateTime weekStart = firstDayOfMonth.subtract(Duration(days: daysToSubtract));

  int daysToAdd = (startDay - 1 - lastDayOfMonth.weekday + 7) % 7;
  DateTime weekEnd = lastDayOfMonth.add(Duration(days: daysToAdd));

  print('Calendar starts: ${weekStart.day} ${_monthName(weekStart.month)} (${_weekdayName(weekStart.weekday)})');
  print('Calendar ends: ${weekEnd.day} ${_monthName(weekEnd.month)} (${_weekdayName(weekEnd.weekday)})\n');

  final totalDays = weekEnd.difference(weekStart).inDays + 1;
  final numberOfWeeks = (totalDays / 7).ceil();

  final weeks = List.generate(numberOfWeeks, (weekIndex) {
    return List.generate(7, (dayIndex) {
      return weekStart.add(Duration(days: (weekIndex * 7) + dayIndex));
    });
  });

  print('Calendar Grid:');
  print('${"Sa".padLeft(5)} ${"Su".padLeft(4)} ${"Mo".padLeft(4)} ${"Tu".padLeft(4)} ${"We".padLeft(4)} ${"Th".padLeft(4)} ${"Fr".padLeft(4)}');
  print('─' * 35);

  for (var week in weeks) {
    final weekStr = week.map((d) {
      final dayStr = '${d.day}'.padLeft(2);
      if (d.month == month) {
        return ' $dayStr ';
      } else {
        return '(${dayStr})';
      }
    }).join(' ');
    print(weekStr);
  }

  final daysInMonth = weeks
      .expand((week) => week)
      .where((day) => day.month == month)
      .toList();

  print('\n✓ Total weeks: $numberOfWeeks');
  print('✓ Total grid cells: $totalDays');
  print('✓ Days in ${_monthName(month)}: ${daysInMonth.length}/${lastDayOfMonth.day}');

  final allDays = weeks.expand((week) => week).toList();
  final dayNumbers = <int, int>{};
  for (var day in allDays) {
    if (day.month == month) {
      dayNumbers[day.day] = (dayNumbers[day.day] ?? 0) + 1;
    }
  }

  final duplicates = dayNumbers.entries.where((e) => e.value > 1).toList();
  final expectedDays = Set.from(List.generate(lastDayOfMonth.day, (i) => i + 1));
  final actualDays = Set.from(dayNumbers.keys);
  final missing = expectedDays.difference(actualDays);

  if (duplicates.isEmpty && missing.isEmpty && daysInMonth.length == lastDayOfMonth.day) {
    print('✅ PERFECT! All days present, no duplicates, no missing days.');
  } else {
    if (duplicates.isNotEmpty) {
      print('❌ DUPLICATES: ${duplicates.map((e) => 'day ${e.key} (${e.value}x)').join(', ')}');
    }
    if (missing.isNotEmpty) {
      print('❌ MISSING: $missing');
    }
    if (daysInMonth.length != lastDayOfMonth.day) {
      print('❌ COUNT MISMATCH: Expected ${lastDayOfMonth.day}, got ${daysInMonth.length}');
    }
  }
}

void testAllMonths() {
  final startConfigs = [
    ('Monday', 1),
    ('Saturday', 6),
    ('Sunday', 7),
  ];

  for (var config in startConfigs) {
    print('\nTesting with ${config.$1} as first day:');
    bool allPassed = true;

    for (int month = 1; month <= 12; month++) {
      final passed = quickTestMonth(2025, month, config.$2);
      final status = passed ? '✅' : '❌';
      print('  $status ${_monthName(month).padRight(10)}');
      if (!passed) allPassed = false;
    }

    if (allPassed) {
      print('  ✅ All months passed!');
    }
  }
}

bool quickTestMonth(int year, int month, int startDay) {
  final firstDayOfMonth = DateTime(year, month, 1);
  final lastDayOfMonth = DateTime(year, month + 1, 0);

  int daysToSubtract = (firstDayOfMonth.weekday - startDay + 7) % 7;
  DateTime weekStart = firstDayOfMonth.subtract(Duration(days: daysToSubtract));

  int daysToAdd = (startDay - 1 - lastDayOfMonth.weekday + 7) % 7;
  DateTime weekEnd = lastDayOfMonth.add(Duration(days: daysToAdd));

  final totalDays = weekEnd.difference(weekStart).inDays + 1;
  final numberOfWeeks = (totalDays / 7).ceil();

  final weeks = List.generate(numberOfWeeks, (weekIndex) {
    return List.generate(7, (dayIndex) {
      return weekStart.add(Duration(days: (weekIndex * 7) + dayIndex));
    });
  });

  final daysInMonth = weeks
      .expand((week) => week)
      .where((day) => day.month == month)
      .toList();

  final dayNumbers = <int>{};
  for (var day in daysInMonth) {
    if (!dayNumbers.add(day.day)) {
      return false;
    }
  }

  return daysInMonth.length == lastDayOfMonth.day &&
         weekStart.weekday == startDay &&
         dayNumbers.length == lastDayOfMonth.day;
}

String _weekdayName(int weekday) {
  const names = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return names[weekday];
}

String _monthName(int month) {
  const names = ['', 'January', 'February', 'March', 'April', 'May', 'June',
                 'July', 'August', 'September', 'October', 'November', 'December'];
  return names[month];
}

