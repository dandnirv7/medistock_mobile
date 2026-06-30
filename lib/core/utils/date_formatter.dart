import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _api = DateFormat('yyyy-MM-dd');

  /// Indonesian month names (full). Used so dates render as
  /// "10 Mei 2025" without needing `intl` locale data initialization.
  static const List<String> _idMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String toApi(DateTime date) => _api.format(date);

  /// Indonesian full month, e.g. "6 Juli 2026".
  static String toDisplay(DateTime date) =>
      '${date.day} ${_idMonths[date.month - 1]} ${date.year}';

  /// Indonesian full month, e.g. "6 Juli 2026".
  static String toDisplayId(DateTime date) =>
      '${date.day} ${_idMonths[date.month - 1]} ${date.year}';

  /// Short Indonesian full month, same as [toDisplay].
  static String toDisplayShort(DateTime date) =>
      '${date.day} ${_idMonths[date.month - 1]} ${date.year}';

  /// Indonesian full month with time, e.g. "6 Juli 2026 14:30".
  static String toDisplayWithTime(DateTime date) =>
      '${date.day} ${_idMonths[date.month - 1]} ${date.year} '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  static DateTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
