class DateValidator {
  static const int minYear = 1900;
  static const int maxYear = 2100;

  /// Returns an error message if the year is invalid, otherwise null.
  static String? validateYear(String yearStr) {
    if (yearStr.isEmpty) return 'Ano obrigatório';
    final year = int.tryParse(yearStr);
    if (year == null) return 'Ano inválido';
    if (year < minYear || year > maxYear) {
      return 'Ano deve ser entre $minYear e $maxYear';
    }
    return null;
  }

  /// Returns an error message if the day is invalid for the given month/year, otherwise null.
  static String? validateDay(String dayStr, int month, String yearStr) {
    if (dayStr.isEmpty) return 'Dia obrigatório';
    final day = int.tryParse(dayStr);
    if (day == null) return 'Dia inválido';
    if (day < 1 || day > 31) return 'Dia inválido';

    final year = int.tryParse(yearStr);
    // If year is invalid/missing, we can still do basic checks based on month
    // but accurate leap year check needs year.
    // For now, assume non-leap if year missing, or just check standard days.

    final maxDays = _getDaysInMonth(month, year);
    if (day > maxDays) {
      return 'Mês $month tem apenas $maxDays dias';
    }
    return null;
  }

  static int _getDaysInMonth(int month, int? year) {
    if (month == 2) {
      if (year != null && _isLeapYear(year)) return 29;
      return 28;
    }
    const daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month];
  }

  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}
