void main() {
  final year = 2025;
  final startConfigs = [
    ('Monday', 1),
    ('Saturday', 6),
    ('Sunday', 7),
  ];

  bool allPassed = true;

  for (var cfg in startConfigs) {
    final name = cfg.$1;
    final startDay = cfg.$2;
    print('\nTesting with $name as first day');
    for (int month = 1; month <= 12; month++) {
      final result = checkMonth(year, month, startDay);
      final status = result ? 'PASS' : 'FAIL';
      print('  $status ${_monthName(month)}');
      if (!result) allPassed = false;
    }
  }

  print('\nOverall: ${allPassed ? 'ALL PASSED' : 'SOME FAILURES'}');
}

bool checkMonth(int year, int month, int startDay) {
  final firstDayOfMonth = DateTime(year, month, 1);
  final lastDayOfMonth = DateTime(year, month + 1, 0);

  int daysToSubtract = (firstDayOfMonth.weekday - startDay + 7) % 7;
  final weekStart = firstDayOfMonth.subtract(Duration(days: daysToSubtract));

  DateTime weekEnd = lastDayOfMonth;
  while (((weekEnd.weekday - startDay + 7) % 7) != 6) {
    weekEnd = weekEnd.add(Duration(days: 1));
  }

  final totalDays = weekEnd.difference(weekStart).inDays + 1;
  final days = List.generate(totalDays, (i) => weekStart.add(Duration(days: i)));

  final weeks = <List<DateTime>>[];
  for (int i = 0; i < days.length; i += 7) {
    weeks.add(days.sublist(i, i + 7));
  }

  final dayCounts = <int, int>{};
  for (var w in weeks) {
    for (var d in w) {
      if (d.month == month) {
        dayCounts[d.day] = (dayCounts[d.day] ?? 0) + 1;
      }
    }
  }

  final duplicates = dayCounts.entries.where((e) => e.value > 1).toList();
  final expectedCount = lastDayOfMonth.day;
  final actualCount = dayCounts.length;
  if (duplicates.isNotEmpty || actualCount != expectedCount) {
    if (duplicates.isNotEmpty) {
      print('    DUPLICATES: ${duplicates.map((e) => '${e.key}(${e.value})').join(', ')}');
    }
    if (actualCount != expectedCount) {
      print('    COUNT MISMATCH: expected $expectedCount, got $actualCount');
    }
    return false;
  }
  return true;
}

String _monthName(int month) {
  const names = ['', 'January', 'February', 'March', 'April', 'May', 'June',
                 'July', 'August', 'September', 'October', 'November', 'December'];
  return names[month];
}

