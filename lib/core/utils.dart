import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount).replaceAll('Rp', 'Rp ');
  }

  static String formatCompact(num amount) {
    return _formatter.format(amount);
  }
}

class DateHelper {
  static String formatTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  static String formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }
}
