void main() {
  print('=== Testing August 2025 with Saturday start ===');
  testMonth(2025, 8, 6);

  print('\n=== Testing October 2025 with Saturday start ===');
  testMonth(2025, 10, 6);
}

void testMonth(int year, int month, int startDay) {
  final date = DateTime(year, month, 1);
  final firstDayOfMonth = DateTime(date.year, date.month, 1);
  final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

  print('Month: ${date.month}/${date.year}');
  print('First day: ${firstDayOfMonth.day}/${firstDayOfMonth.month}/${firstDayOfMonth.year} (weekday: ${firstDayOfMonth.weekday} - ${_weekdayName(firstDayOfMonth.weekday)})');
  print('Last day: ${lastDayOfMonth.day}/${lastDayOfMonth.month}/${lastDayOfMonth.year} (weekday: ${lastDayOfMonth.weekday} - ${_weekdayName(lastDayOfMonth.weekday)})');
  print('Starting day of week: $startDay (${_weekdayName(startDay)})');

  int daysToSubtract = (firstDayOfMonth.weekday - startDay + 7) % 7;
  print('Days to subtract from first day: $daysToSubtract');

  DateTime weekStart = firstDayOfMonth.subtract(Duration(days: daysToSubtract));
  print('Week starts on: ${weekStart.day}/${weekStart.month}/${weekStart.year} (weekday: ${weekStart.weekday} - ${_weekdayName(weekStart.weekday)})');

  int daysToAdd = (startDay - 1 - lastDayOfMonth.weekday + 7) % 7;
  print('Days to add after last day: $daysToAdd');
  print('Calculation: ($startDay - 1 - ${lastDayOfMonth.weekday} + 7) % 7 = ${(startDay - 1 - lastDayOfMonth.weekday + 7)} % 7 = $daysToAdd');

  DateTime weekEnd = lastDayOfMonth.add(Duration(days: daysToAdd));
  print('Week ends on: ${weekEnd.day}/${weekEnd.month}/${weekEnd.year} (weekday: ${weekEnd.weekday} - ${_weekdayName(weekEnd.weekday)})');

  final totalDays = weekEnd.difference(weekStart).inDays + 1;
  final numberOfWeeks = (totalDays / 7).ceil();

  print('Total days in grid: $totalDays');
  print('Number of weeks: $numberOfWeeks');

  final weeks = List.generate(numberOfWeeks, (weekIndex) {
    return List.generate(7, (dayIndex) {
      return weekStart.add(Duration(days: (weekIndex * 7) + dayIndex));
    });
  });

  print('\nCalendar Grid (starting from Saturday):');
  print('${"Sa".padLeft(4)} ${"Su".padLeft(4)} ${"Mo".padLeft(4)} ${"Tu".padLeft(4)} ${"We".padLeft(4)} ${"Th".padLeft(4)} ${"Fr".padLeft(4)}');
  print('─' * 32);

  for (var i = 0; i < weeks.length; i++) {
    final weekStr = weeks[i].map((d) {
      final dayStr = '${d.day}'.padLeft(2);
      return d.month == month ? ' $dayStr ' : '(${dayStr})';
    }).join(' ');
    print(weekStr);
  }

  final daysInTargetMonth = weeks
      .expand((week) => week)
      .where((day) => day.month == month)
      .toList();

  print('\nDays in month $month: ${daysInTargetMonth.length}');
  print('Expected: ${lastDayOfMonth.day}');
  print('First day in month: ${daysInTargetMonth.first.day}');
  print('Last day in month: ${daysInTargetMonth.last.day}');

  final allDays = weeks.expand((week) => week).toList();
  final duplicates = <int, List<DateTime>>{};
  for (var day in allDays) {
    if (day.month == month) {
      if (!duplicates.containsKey(day.day)) {
        duplicates[day.day] = [];
      }
      duplicates[day.day]!.add(day);
    }
  }

  final dupsFound = duplicates.entries.where((e) => e.value.length > 1).toList();
  if (dupsFound.isNotEmpty) {
    print('❌ DUPLICATE DAYS FOUND:');
    for (var dup in dupsFound) {
      print('   Day ${dup.key} appears ${dup.value.length} times');
    }
  }

  if (daysInTargetMonth.length != lastDayOfMonth.day) {
    print('❌ ERROR: Expected ${lastDayOfMonth.day} days but got ${daysInTargetMonth.length}!');
    final expectedDays = List.generate(lastDayOfMonth.day, (i) => i + 1).toSet();
    final actualDays = daysInTargetMonth.map((d) => d.day).toSet();
    final missing = expectedDays.difference(actualDays);
    if (missing.isNotEmpty) {
      print('   Missing days: $missing');
    }
  } else {
    print('✓ All days present');
  }
}

String _weekdayName(int weekday) {
  const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[weekday];
}
