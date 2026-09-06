import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatShort(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatFull(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }
}
