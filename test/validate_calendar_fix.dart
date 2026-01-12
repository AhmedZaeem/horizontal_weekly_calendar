void main() {
  print('Testing August 2025 calendar generation...');
  testMonth(2025, 8, DateTime.friday);

  print('\nTesting October 2025 calendar generation...');
  testMonth(2025, 10, DateTime.saturday);
}

void testMonth(int year, int month, int startDay) {
  final date = DateTime(year, month, 1);
  final firstDayOfMonth = DateTime(date.year, date.month, 1);
  final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

  print('Month: ${date.month}/${date.year}');
  print('First day: ${firstDayOfMonth.day}/${firstDayOfMonth.month} (weekday: ${firstDayOfMonth.weekday})');
  print('Last day: ${lastDayOfMonth.day}/${lastDayOfMonth.month} (weekday: ${lastDayOfMonth.weekday})');

  int daysToSubtract = (firstDayOfMonth.weekday - startDay + 7) % 7;
  DateTime weekStart = firstDayOfMonth.subtract(Duration(days: daysToSubtract));

  int daysToAdd = (6 - (lastDayOfMonth.weekday - startDay + 7) % 7);
  DateTime weekEnd = lastDayOfMonth.add(Duration(days: daysToAdd));

  print('Week starts: ${weekStart.day}/${weekStart.month}');
  print('Week ends: ${weekEnd.day}/${weekEnd.month}');

  final totalDays = weekEnd.difference(weekStart).inDays + 1;
  final numberOfWeeks = (totalDays / 7).ceil();

  print('Total days in grid: $totalDays');
  print('Number of weeks: $numberOfWeeks');

  final weeks = List.generate(numberOfWeeks, (weekIndex) {
    return List.generate(7, (dayIndex) {
      return weekStart.add(Duration(days: (weekIndex * 7) + dayIndex));
    });
  });

  print('\nWeek layout:');
  for (var i = 0; i < weeks.length; i++) {
    final weekStr = weeks[i].map((d) => '${d.month}/${d.day}'.padLeft(5)).join(' ');
    print('Week ${i + 1}: $weekStr');
  }

  final daysInTargetMonth = weeks
      .expand((week) => week)
      .where((day) => day.month == month)
      .toList();

  print('\nDays in month $month: ${daysInTargetMonth.length}');
  print('First: ${daysInTargetMonth.first.day}/${daysInTargetMonth.first.month}');
  print('Last: ${daysInTargetMonth.last.day}/${daysInTargetMonth.last.month}');

  if (daysInTargetMonth.length != lastDayOfMonth.day) {
    print('ERROR: Expected ${lastDayOfMonth.day} days but got ${daysInTargetMonth.length}');
  } else {
    print('SUCCESS: All days present!');
  }
}

