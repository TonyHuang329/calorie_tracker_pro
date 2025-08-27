// lib/utils/date_utils.dart

import 'package:intl/intl.dart';

/// Date processing utility class
/// Provides all date-related formatting, calculation and conversion functions for the app
class AppDateUtils {
  AppDateUtils._(); // Private constructor to prevent instantiation

  // Common date formatters
  static final DateFormat _yyyyMMdd = DateFormat('yyyy-MM-dd');
  static final DateFormat _yyyyMMddHHmm = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _MMdd = DateFormat('MM-dd');
  static final DateFormat _MMddEEE = DateFormat('MM-dd EEE');
  static final DateFormat _yyyyMMddEEE = DateFormat('yyyy-MM-dd EEEE');
  static final DateFormat _MMddHHmm = DateFormat('MM-dd HH:mm');
  static final DateFormat _HHmm = DateFormat('HH:mm');
  static final DateFormat _full = DateFormat('MMMM dd, yyyy');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _weekday = DateFormat('EEEE');
  static final DateFormat _shortMonth = DateFormat('MMM dd');
  static final DateFormat _longDate = DateFormat('EEEE, MMMM dd, yyyy');

  /// Get today's date (without time)
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get yesterday's date
  static DateTime get yesterday {
    return today.subtract(const Duration(days: 1));
  }

  /// Get tomorrow's date
  static DateTime get tomorrow {
    return today.add(const Duration(days: 1));
  }

  /// Get start of this week (Monday)
  static DateTime get thisWeekStart {
    final now = today;
    final weekday = now.weekday;
    return now.subtract(Duration(days: weekday - 1));
  }

  /// Get end of this week (Sunday)
  static DateTime get thisWeekEnd {
    return thisWeekStart.add(const Duration(days: 6));
  }

  /// Get start of this month
  static DateTime get thisMonthStart {
    final now = today;
    return DateTime(now.year, now.month, 1);
  }

  /// Get end of this month
  static DateTime get thisMonthEnd {
    final now = today;
    return DateTime(now.year, now.month + 1, 0);
  }

  /// Get start of last month
  static DateTime get lastMonthStart {
    final now = today;
    return DateTime(now.year, now.month - 1, 1);
  }

  /// Get end of last month
  static DateTime get lastMonthEnd {
    final now = today;
    return DateTime(now.year, now.month, 0);
  }

  /// Format date as yyyy-MM-dd
  static String formatDate(DateTime date) {
    return _yyyyMMdd.format(date);
  }

  /// Format datetime as yyyy-MM-dd HH:mm
  static String formatDateTime(DateTime dateTime) {
    return _yyyyMMddHHmm.format(dateTime);
  }

  /// Format as short date MM-dd
  static String formatShortDate(DateTime date) {
    return _MMdd.format(date);
  }

  /// Format as short date with weekday MM-dd EEE
  static String formatShortDateWithWeekday(DateTime date) {
    return _MMddEEE.format(date);
  }

  /// Format as full date with weekday
  static String formatFullDateWithWeekday(DateTime date) {
    return _yyyyMMddEEE.format(date);
  }

  /// Format as short datetime MM-dd HH:mm
  static String formatShortDateTime(DateTime dateTime) {
    return _MMddHHmm.format(dateTime);
  }

  /// Format time HH:mm
  static String formatTime(DateTime dateTime) {
    return _HHmm.format(dateTime);
  }

  /// Format as full date
  static String formatFullDate(DateTime date) {
    return _full.format(date);
  }

  /// Format as year and month
  static String formatYearMonth(DateTime date) {
    return _monthYear.format(date);
  }

  /// Get weekday name
  static String formatWeekday(DateTime date) {
    return _weekday.format(date);
  }

  /// Format as short month and day
  static String formatShortMonth(DateTime date) {
    return _shortMonth.format(date);
  }

  /// Format as long date with full weekday
  static String formatLongDate(DateTime date) {
    return _longDate.format(date);
  }

  /// Relative date description (today, yesterday, tomorrow, etc.)
  static String formatRelativeDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final todayDate = today;
    final yesterdayDate = yesterday;
    final tomorrowDate = tomorrow;

    if (targetDate.isAtSameMomentAs(todayDate)) {
      return 'Today';
    } else if (targetDate.isAtSameMomentAs(yesterdayDate)) {
      return 'Yesterday';
    } else if (targetDate.isAtSameMomentAs(tomorrowDate)) {
      return 'Tomorrow';
    } else {
      final difference = targetDate.difference(todayDate).inDays;
      if (difference > 0 && difference <= 7) {
        return 'In $difference day${difference == 1 ? '' : 's'}';
      } else if (difference < 0 && difference >= -7) {
        return '${difference.abs()} day${difference.abs() == 1 ? '' : 's'} ago';
      } else {
        return formatShortDate(date);
      }
    }
  }

  /// Relative datetime description
  static String formatRelativeDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    } else {
      return formatShortDateTime(dateTime);
    }
  }

  /// Parse date string yyyy-MM-dd
  static DateTime? parseDate(String dateString) {
    try {
      return _yyyyMMdd.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse datetime string yyyy-MM-dd HH:mm
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return _yyyyMMddHHmm.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if two dates are in the same week
  static bool isSameWeek(DateTime date1, DateTime date2) {
    final startOfWeek1 = getStartOfWeek(date1);
    final startOfWeek2 = getStartOfWeek(date2);
    return isSameDay(startOfWeek1, startOfWeek2);
  }

  /// Check if two dates are in the same month
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  /// Check if two dates are in the same year
  static bool isSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, today);
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    return isSameDay(date, yesterday);
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    return isSameDay(date, tomorrow);
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    return isSameWeek(date, today);
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime date) {
    return isSameMonth(date, today);
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(today);
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(today);
  }

  /// Get start of week (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: weekday - 1));
  }

  /// Get end of week (Sunday)
  static DateTime getEndOfWeek(DateTime date) {
    return getStartOfWeek(date).add(const Duration(days: 6));
  }

  /// Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get start of year
  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get end of year
  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }

  /// Get all dates within a date range
  static List<DateTime> getDatesInRange(DateTime startDate, DateTime endDate) {
    final dates = <DateTime>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(endDateOnly) ||
        currentDate.isAtSameMomentAs(endDateOnly)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Get all dates in a week
  static List<DateTime> getWeekDates(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return getDatesInRange(startOfWeek, getEndOfWeek(date));
  }

  /// Get all dates in a month
  static List<DateTime> getMonthDates(DateTime date) {
    final startOfMonth = getStartOfMonth(date);
    final endOfMonth = getEndOfMonth(date);
    return getDatesInRange(startOfMonth, endOfMonth);
  }

  /// Calculate days between two dates
  static int daysBetween(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.difference(start).inDays;
  }

  /// Calculate weeks between two dates
  static int weeksBetween(DateTime startDate, DateTime endDate) {
    return (daysBetween(startDate, endDate) / 7).ceil();
  }

  /// Calculate months between two dates
  static int monthsBetween(DateTime startDate, DateTime endDate) {
    int months = (endDate.year - startDate.year) * 12;
    months += endDate.month - startDate.month;
    return months;
  }

  /// Add specified days
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Add specified weeks
  static DateTime addWeeks(DateTime date, int weeks) {
    return date.add(Duration(days: weeks * 7));
  }

  /// Add specified months
  static DateTime addMonths(DateTime date, int months) {
    int year = date.year;
    int month = date.month + months;

    while (month > 12) {
      year++;
      month -= 12;
    }
    while (month < 1) {
      year--;
      month += 12;
    }

    // Handle day mismatch in months
    int day = date.day;
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    if (day > lastDayOfMonth) {
      day = lastDayOfMonth;
    }

    return DateTime(year, month, day, date.hour, date.minute, date.second);
  }

  /// Subtract specified days
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// Subtract specified weeks
  static DateTime subtractWeeks(DateTime date, int weeks) {
    return date.subtract(Duration(days: weeks * 7));
  }

  /// Subtract specified months
  static DateTime subtractMonths(DateTime date, int months) {
    return addMonths(date, -months);
  }

  /// Calculate age (from birthday)
  static int calculateAge(DateTime birthday) {
    final today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  /// Get season based on date
  static String getSeason(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
  }

  /// Check if year is leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get number of days in month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Get weekdays (Monday to Friday)
  static List<DateTime> getWeekdays(DateTime startDate, DateTime endDate) {
    final allDates = getDatesInRange(startDate, endDate);
    return allDates.where((date) => date.weekday <= 5).toList();
  }

  /// Get weekends (Saturday and Sunday)
  static List<DateTime> getWeekends(DateTime startDate, DateTime endDate) {
    final allDates = getDatesInRange(startDate, endDate);
    return allDates.where((date) => date.weekday > 5).toList();
  }

  /// Check if date is a weekday
  static bool isWeekday(DateTime date) {
    return date.weekday <= 5;
  }

  /// Check if date is weekend
  static bool isWeekend(DateTime date) {
    return date.weekday > 5;
  }

  /// Get this week's weekdays
  static List<DateTime> getThisWeekWorkdays() {
    return getWeekdays(thisWeekStart, thisWeekEnd);
  }

  /// Get this month's weekdays
  static List<DateTime> getThisMonthWorkdays() {
    return getWeekdays(thisMonthStart, thisMonthEnd);
  }

  /// Format duration (seconds to readable format)
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0
          ? '${minutes}m ${remainingSeconds}s'
          : '${minutes}m';
    } else if (seconds < 86400) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      final days = seconds ~/ 86400;
      final hours = (seconds % 86400) ~/ 3600;
      return hours > 0 ? '${days}d ${hours}h' : '${days}d';
    }
  }

  /// Create DateTime with only date (time set to 0)
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Create DateTime with specified time
  static DateTime withTime(DateTime date, int hour,
      [int minute = 0, int second = 0]) {
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }

  /// Get time of day description (morning, afternoon, etc.)
  static String getTimeOfDayDescription(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 5 && hour < 8) return 'Early Morning';
    if (hour >= 8 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 14) return 'Noon';
    if (hour >= 14 && hour < 18) return 'Afternoon';
    if (hour >= 18 && hour < 22) return 'Evening';
    return 'Night';
  }

  /// Get meal time type based on time
  static String getMealTimeType(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 5 && hour < 10) return 'breakfast';
    if (hour >= 10 && hour < 15) return 'lunch';
    if (hour >= 15 && hour < 21) return 'dinner';
    return 'snack';
  }

  /// Get meal time display name
  static String getMealTimeDisplayName(DateTime dateTime) {
    final mealType = getMealTimeType(dateTime);
    switch (mealType) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
      default:
        return 'Snack';
    }
  }

  /// Get default meal time for meal type
  static DateTime getDefaultMealTime(String mealType) {
    final today = AppDateUtils.today;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return withTime(today, 8, 0); // 8:00 AM
      case 'lunch':
        return withTime(today, 12, 30); // 12:30 PM
      case 'dinner':
        return withTime(today, 18, 30); // 6:30 PM
      case 'snack':
      default:
        return withTime(today, 15, 0); // 3:00 PM
    }
  }

  /// Get time period for analytics (morning, afternoon, evening, night)
  static String getTimePeriod(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 22) return 'evening';
    return 'night';
  }

  /// Get week number in year
  static int getWeekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday =
        startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));

    if (date.isBefore(firstMonday)) {
      // Date is in week 1 or belongs to previous year
      return 1;
    }

    final daysDifference = date.difference(firstMonday).inDays;
    return (daysDifference / 7).floor() + 2; // +2 because we start from week 2
  }

  /// Get quarter of year (1-4)
  static int getQuarter(DateTime date) {
    return ((date.month - 1) ~/ 3) + 1;
  }

  /// Check if date is in current quarter
  static bool isCurrentQuarter(DateTime date) {
    final now = DateTime.now();
    return getQuarter(date) == getQuarter(now) && date.year == now.year;
  }

  /// Get start of quarter
  static DateTime getStartOfQuarter(DateTime date) {
    final quarter = getQuarter(date);
    final startMonth = (quarter - 1) * 3 + 1;
    return DateTime(date.year, startMonth, 1);
  }

  /// Get end of quarter
  static DateTime getEndOfQuarter(DateTime date) {
    final quarter = getQuarter(date);
    final endMonth = quarter * 3;
    return DateTime(date.year, endMonth + 1, 0);
  }

  /// Format date for file names (safe characters only)
  static String formatForFileName(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get business days between two dates (excluding weekends)
  static int getBusinessDaysBetween(DateTime startDate, DateTime endDate) {
    final allDates = getDatesInRange(startDate, endDate);
    return allDates.where((date) => isWeekday(date)).length;
  }

  /// Get next business day (skip weekends)
  static DateTime getNextBusinessDay(DateTime date) {
    DateTime nextDay = date.add(const Duration(days: 1));
    while (isWeekend(nextDay)) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    return nextDay;
  }

  /// Get previous business day (skip weekends)
  static DateTime getPreviousBusinessDay(DateTime date) {
    DateTime prevDay = date.subtract(const Duration(days: 1));
    while (isWeekend(prevDay)) {
      prevDay = prevDay.subtract(const Duration(days: 1));
    }
    return prevDay;
  }

  /// Check if time is within business hours (9 AM - 5 PM)
  static bool isBusinessHours(DateTime dateTime) {
    final hour = dateTime.hour;
    return isWeekday(dateTime) && hour >= 9 && hour < 17;
  }

  /// Get time until next meal time
  static Duration timeUntilNextMeal(DateTime currentTime) {
    final hour = currentTime.hour;
    DateTime nextMealTime;

    if (hour < 8) {
      // Before breakfast
      nextMealTime = withTime(currentTime, 8, 0);
    } else if (hour < 12) {
      // Before lunch
      nextMealTime = withTime(currentTime, 12, 30);
    } else if (hour < 18) {
      // Before dinner
      nextMealTime = withTime(currentTime, 18, 30);
    } else {
      // After dinner, next meal is tomorrow's breakfast
      nextMealTime = withTime(currentTime.add(const Duration(days: 1)), 8, 0);
    }

    return nextMealTime.difference(currentTime);
  }
}
