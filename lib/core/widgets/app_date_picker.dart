import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/date_formatter.dart';

/// App-wide date picker built on Syncfusion's [SfDateRangePicker].
///
/// Presented as a rounded bottom sheet themed to the MediStock green palette
/// with an Indonesian header ("Pilih Tanggal") and Batal / Pilih actions.
/// Replaces the stock Material `showDatePicker` dialog across the forms.
class AppDatePicker {
  AppDatePicker._();

  /// Opens the picker and resolves with the chosen [DateTime], or `null`
  /// if the user dismisses it / taps Batal.
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String title = 'Pilih Tanggal',
  }) {
    final now = DateTime.now();
    final initial = initialDate ?? now;
    final first = firstDate ?? DateTime(2000);
    final last = lastDate ?? DateTime(2100);

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _DatePickerSheet(
        title: title,
        initialDate: initial,
        firstDate: first,
        lastDate: last,
      ),
    );
  }
}

class _DatePickerSheet extends StatefulWidget {
  const _DatePickerSheet({
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final String title;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _selected = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    DateFormatter.toDisplayId(_selected),
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SfDateRangePicker(
              initialSelectedDate: widget.initialDate,
              initialDisplayDate: widget.initialDate,
              minDate: widget.firstDate,
              maxDate: widget.lastDate,
              selectionMode: DateRangePickerSelectionMode.single,
              selectionShape: DateRangePickerSelectionShape.circle,
              showNavigationArrow: true,
              backgroundColor: AppColors.surface,
              todayHighlightColor: AppColors.primary,
              selectionColor: AppColors.primary,
              startRangeSelectionColor: AppColors.primary,
              headerStyle: const DateRangePickerHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              monthCellStyle: const DateRangePickerMonthCellStyle(
                todayTextStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              yearCellStyle: const DateRangePickerYearCellStyle(
                todayTextStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onSelectionChanged: (args) {
                final value = args.value;
                if (value is DateTime) {
                  setState(() => _selected = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: const Text('Pilih'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
