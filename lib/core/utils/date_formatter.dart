import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _api = DateFormat('yyyy-MM-dd');
  static final DateFormat _display = DateFormat('dd MMM yyyy');
  static final DateFormat _displayShort = DateFormat('dd/MM/yyyy');
  static final DateFormat _displayWithTime = DateFormat('dd MMM yyyy HH:mm');

  /// Indonesian month names. Used by [toDisplayId] so dates render as
  /// "10 Mei 2025" without needing `intl` locale data initialization.
  static const List<String> _idMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String toApi(DateTime date) => _api.format(date);

  static String toDisplay(DateTime date) => _display.format(date);

  /// Indonesian display format, e.g. "10 Mei 2025".
  static String toDisplayId(DateTime date) =>
      '${date.day} ${_idMonths[date.month - 1]} ${date.year}';

  static String toDisplayShort(DateTime date) => _displayShort.format(date);

  static String toDisplayWithTime(DateTime date) =>
      _displayWithTime.format(date);

  static DateTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
