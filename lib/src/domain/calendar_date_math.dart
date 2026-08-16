/// Civil-date arithmetic shared by every calendar view.
///
/// A civil date is identified by its year, month, and day alone. Every
/// operation here is performed on an integer *day number* — the count of days
/// since 1970-01-01 — using the proleptic Gregorian algorithms published by
/// Howard Hinnant. `DateTime` is only ever used to read a civil triple out and
/// to materialize one back in.
///
/// That matters because the obvious implementations are subtly wrong:
///
/// * Adding a `Duration` skips or repeats a local date whenever a
///   daylight-saving transition shortens or lengthens a day.
/// * Deriving a day number from `millisecondsSinceEpoch` inherits the
///   platform's epoch precision and truncation behaviour.
/// * Constructing a local midnight fails in zones that begin daylight saving
///   at 00:00 — the requested civil date does not exist as a local instant, and
///   the constructor silently returns a neighbouring day, which is how a grid
///   ends up with a duplicated or missing date.
///
/// Day numbers are small integers (roughly ±10^5 for supported years), so this
/// arithmetic is exact on every platform, including the web where `int` is a
/// double.
abstract final class CalendarDateMath {
  /// Day number of 1970-01-01 expressed in Hinnant's 0000-03-01 era origin.
  static const int _epochShift = 719468;

  /// Days in one 400-year Gregorian era.
  static const int _daysPerEra = 146097;

  /// Day number for the civil date [year]-[month]-[day].
  ///
  /// Out-of-range [month] and [day] values normalize exactly the way
  /// `DateTime` normalizes them, so `daysFromCivil(2026, 13, 0)` is the last
  /// day of 2026.
  static int daysFromCivil(int year, int month, int day) {
    // Fold month overflow into the year using floor division, because Dart's
    // `~/` truncates toward zero and would map month 0 to the wrong year.
    final monthIndex = month - 1;
    final monthOfYear = monthIndex % 12; // Dart's % is never negative here.
    var y = year + (monthIndex - monthOfYear) ~/ 12;
    final m = monthOfYear + 1;

    y -= m <= 2 ? 1 : 0;
    final era = (y >= 0 ? y : y - 399) ~/ 400;
    final yearOfEra = y - era * 400; // [0, 399]
    final dayOfYear = (153 * (m + (m > 2 ? -3 : 9)) + 2) ~/ 5 + day - 1;
    final dayOfEra =
        yearOfEra * 365 + yearOfEra ~/ 4 - yearOfEra ~/ 100 + dayOfYear;
    return era * _daysPerEra + dayOfEra - _epochShift;
  }

  /// Civil year, month, and day for the day number [dayNumber].
  static (int year, int month, int day) civilFromDays(int dayNumber) {
    final z = dayNumber + _epochShift;
    final era = (z >= 0 ? z : z - (_daysPerEra - 1)) ~/ _daysPerEra;
    final dayOfEra = z - era * _daysPerEra; // [0, 146096]
    final yearOfEra = (dayOfEra -
            dayOfEra ~/ 1460 +
            dayOfEra ~/ 36524 -
            dayOfEra ~/ (_daysPerEra - 1)) ~/
        365; // [0, 399]
    final y = yearOfEra + era * 400;
    final dayOfYear =
        dayOfEra - (365 * yearOfEra + yearOfEra ~/ 4 - yearOfEra ~/ 100);
    final monthPrime = (5 * dayOfYear + 2) ~/ 153; // [0, 11]
    final day = dayOfYear - (153 * monthPrime + 2) ~/ 5 + 1; // [1, 31]
    final month = monthPrime + (monthPrime < 10 ? 3 : -9); // [1, 12]
    return (y + (month <= 2 ? 1 : 0), month, day);
  }

  /// Day number identifying the civil date of [date].
  static int dayNumber(DateTime date) =>
      daysFromCivil(date.year, date.month, date.day);

  /// Dart weekday constant, [DateTime.monday]–[DateTime.sunday], for a day
  /// number.
  ///
  /// Derived arithmetically rather than read from `DateTime.weekday`, so it
  /// stays correct for dates whose local midnight does not exist.
  static int weekdayOf(int dayNumber) {
    // 1970-01-01 was a Thursday, so shifting by 3 puts Monday at 0.
    return (dayNumber + 3) % 7 + 1;
  }

  /// Number of days in [month] of [year].
  static int daysInMonth(int year, int month) =>
      daysFromCivil(year, month + 1, 1) - daysFromCivil(year, month, 1);

  /// Whether [year] is a Gregorian leap year.
  static bool isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Returns [date] reduced to its civil date, preserving UTC or local mode.
  ///
  /// The result is local midnight where that instant exists. In zones that
  /// start daylight saving at 00:00 it is midday instead, so the civil date
  /// this returns always matches the civil date that was asked for.
  static DateTime dateOnly(DateTime date) =>
      _materialize(date.isUtc, date.year, date.month, date.day);

  /// Whether [first] and [second] identify the same civil date.
  static bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  /// Adds [count] calendar days to [date].
  ///
  /// Performed on day numbers, never on elapsed durations, so the result is
  /// exactly [count] civil days away regardless of any daylight-saving
  /// transition in between.
  static DateTime addDays(DateTime date, int count) {
    final (year, month, day) = civilFromDays(dayNumber(date) + count);
    return _materialize(date.isUtc, year, month, day);
  }

  /// Returns the first date in the week containing [date].
  ///
  /// [firstDayOfWeek] uses Dart's weekday constants from [DateTime.monday]
  /// through [DateTime.sunday].
  static DateTime startOfWeek(DateTime date, int firstDayOfWeek) {
    _checkWeekday(firstDayOfWeek);
    final number = dayNumber(date);
    final offset = (weekdayOf(number) - firstDayOfWeek + 7) % 7;
    final (year, month, day) = civilFromDays(number - offset);
    return _materialize(date.isUtc, year, month, day);
  }

  /// Generates [count] contiguous, unique civil dates beginning at [start].
  static List<DateTime> days(DateTime start, int count) {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'Must not be negative.');
    }
    final utc = start.isUtc;
    final first = dayNumber(start);
    return List<DateTime>.unmodifiable(
      List<DateTime>.generate(
        count,
        (index) {
          final (year, month, day) = civilFromDays(first + index);
          return _materialize(utc, year, month, day);
        },
        growable: false,
      ),
    );
  }

  /// Generates a complete month grid aligned to [firstDayOfWeek].
  ///
  /// The natural grid uses four, five, or six rows and always contains every
  /// day of [month] exactly once. Set [fixedSixWeeks] when a stable 42-cell
  /// surface is required.
  static List<DateTime> monthGrid(
    DateTime month,
    int firstDayOfWeek, {
    bool fixedSixWeeks = false,
  }) {
    _checkWeekday(firstDayOfWeek);
    final firstOfMonth = daysFromCivil(month.year, month.month, 1);
    final lastOfMonth = daysFromCivil(month.year, month.month + 1, 1) - 1;
    final offset = (weekdayOf(firstOfMonth) - firstDayOfWeek + 7) % 7;
    final gridStart = firstOfMonth - offset;
    final rowCount = ((lastOfMonth - gridStart + 1) / 7).ceil();
    final (year, monthOfYear, day) = civilFromDays(gridStart);
    return days(
      _materialize(month.isUtc, year, monthOfYear, day),
      fixedSixWeeks ? 42 : rowCount * 7,
    );
  }

  /// Clamps [date] to the inclusive civil-date interval [minimum, maximum].
  static DateTime clamp(
    DateTime date,
    DateTime minimum,
    DateTime maximum,
  ) {
    final minimumOrdinal = dayNumber(minimum);
    final maximumOrdinal = dayNumber(maximum);
    if (minimumOrdinal > maximumOrdinal) {
      throw ArgumentError('minimum must not be after maximum.');
    }
    final dateOrdinal = dayNumber(date);
    if (dateOrdinal < minimumOrdinal) return dateOnly(minimum);
    if (dateOrdinal > maximumOrdinal) return dateOnly(maximum);
    return dateOnly(date);
  }

  /// The signed number of civil days from [start] to [end].
  static int civilDayDifference(DateTime start, DateTime end) =>
      dayNumber(end) - dayNumber(start);

  /// Builds a `DateTime` whose civil date is exactly [year]-[month]-[day].
  ///
  /// Local zones do not always have an instant available for a civil date:
  ///
  /// * A zone that begins daylight saving at 00:00 has no local midnight on
  ///   that date, so the result is anchored at midday instead.
  /// * A zone can skip a civil date outright. `Pacific/Apia` never had a
  ///   30 December 2011 — it crossed the international date line and went
  ///   straight from the 29th to the 31st. No local instant carries that
  ///   date, so it is materialized in UTC.
  ///
  /// Whichever branch is taken, the returned value always reports the civil
  /// date that was requested, which is what a calendar grid renders.
  static DateTime _materialize(bool utc, int year, int month, int day) {
    if (utc) return DateTime.utc(year, month, day);
    final midnight = DateTime(year, month, day);
    if (_isCivil(midnight, year, month, day)) return midnight;
    final midday = DateTime(year, month, day, 12);
    if (_isCivil(midday, year, month, day)) return midday;
    return DateTime.utc(year, month, day);
  }

  static bool _isCivil(DateTime date, int year, int month, int day) =>
      date.year == year && date.month == month && date.day == day;

  static void _checkWeekday(int weekday) {
    if (weekday < DateTime.monday || weekday > DateTime.sunday) {
      throw ArgumentError.value(
        weekday,
        'firstDayOfWeek',
        'Must be a DateTime weekday constant from monday through sunday.',
      );
    }
  }
}
