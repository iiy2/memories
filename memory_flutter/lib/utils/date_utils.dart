import 'package:intl/intl.dart';

class DateFormatUtils {
  // Format a date object to display in UI
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
  
  // Format a date object with time
  static String formatDateTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }
  
  // Format a date for the event form
  static String formatForForm(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Parse a date string from a form
  static DateTime parseFormDate(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }
}