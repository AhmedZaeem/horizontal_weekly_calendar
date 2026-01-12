void main() {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  COMPREHENSIVE CALENDAR VALIDATION TEST FOR 2025          ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  final startDays = [
    ('Monday', 1),
    ('Saturday', 6),
    ('Sunday', 7),
  ];

  bool allPassed = true;

  for (var startDayConfig in startDays) {
    print('\n${'=' * 60}');
    print('Testing with week starting on: ${startDayConfig.$1}');
    print('=' * 60);

    for (int month = 1; month <= 12; month++) {
      final result = testMonth(2025, month, startDayConfig.$2, verbose: false);
      if (!result) {
        allPassed = false;
        print('');
        testMonth(2025, month, startDayConfig.$2, verbose: true);
      }
    }
  }

  print('\n${'═' * 60}');
  if (allPassed) {
    print('✅ ALL TESTS PASSED! Calendar is working perfectly!');
  } else {
    print('❌ SOME TESTS FAILED! Please review the errors above.');
  }
  print('═' * 60);
}

bool testMonth(int year, int month, int startDay, {bool verbose = false}) {
  final date = DateTime(year, month, 1);
  final firstDayOfMonth = DateTime(date.year, date.month, 1);
  final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

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

  final daysInTargetMonth = weeks
      .expand((week) => week)
      .where((day) => day.month == month)
      .toList();

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
  final expectedDays = List.generate(lastDayOfMonth.day, (i) => i + 1).toSet();
  final actualDays = daysInTargetMonth.map((d) => d.day).toSet();
  final missing = expectedDays.difference(actualDays);

  bool passed = daysInTargetMonth.length == lastDayOfMonth.day &&
                dupsFound.isEmpty &&
                missing.isEmpty &&
                weekStart.weekday == startDay &&
                (weekEnd.weekday == (startDay - 1 + 7) % 7 || weekEnd.weekday == ((startDay - 1) == 0 ? 7 : startDay - 1));

  if (verbose || !passed) {
    print('\n${_monthName(month)} $year:');
    print('  First: ${firstDayOfMonth.day}/${firstDayOfMonth.month} (${_weekdayName(firstDayOfMonth.weekday)})');
    print('  Last: ${lastDayOfMonth.day}/${lastDayOfMonth.month} (${_weekdayName(lastDayOfMonth.weekday)})');
    print('  Grid: ${weekStart.day}/${weekStart.month} to ${weekEnd.day}/${weekEnd.month}');
    print('  Weeks: $numberOfWeeks, Total days in grid: $totalDays');
    print('  Days in month: ${daysInTargetMonth.length}/${lastDayOfMonth.day}');

    if (dupsFound.isNotEmpty) {
      print('  ❌ DUPLICATES: ${dupsFound.map((e) => 'day ${e.key} (${e.value.length}x)').join(', ')}');
    }

    if (missing.isNotEmpty) {
      print('  ❌ MISSING: $missing');
    }

    if (passed) {
      print('  ✅ PASSED');
    } else {
      print('  ❌ FAILED');
    }
  } else {
    final status = passed ? '✅' : '❌';
    print('  $status ${_monthName(month).padRight(10)} - ${daysInTargetMonth.length}/${lastDayOfMonth.day} days, $numberOfWeeks weeks');
  }

  return passed;
}

String _weekdayName(int weekday) {
  const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[weekday];
}

String _monthName(int month) {
  const names = ['', 'January', 'February', 'March', 'April', 'May', 'June',
                 'July', 'August', 'September', 'October', 'November', 'December'];
  return names[month];
}

