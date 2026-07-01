import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/stock_out_report_model.dart';
import '../controllers/stock_out_report_controller.dart';

class StockOutReportView extends StatelessWidget {
  const StockOutReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StockOutReportController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Laporan Stok Keluar'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: ctrl.load,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          _DateRangeBar(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ctrl.errorMessage.value.isNotEmpty) {
                return _ErrorState(
                  message: ctrl.errorMessage.value,
                  onRetry: ctrl.load,
                );
              }
              final report = ctrl.report.value;
              if (report == null) {
                return const _EmptyState();
              }
              return _ReportBody(report: report);
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date range bar
// ---------------------------------------------------------------------------

class _DateRangeBar extends StatelessWidget {
  const _DateRangeBar({required this.ctrl});

  final StockOutReportController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(() {
        final fmt = DateFormat('dd MMM yyyy', 'id_ID');
        return Row(
          children: [
            Icon(LucideIcons.calendar,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              '${fmt.format(ctrl.dateFrom.value)} – ${fmt.format(ctrl.dateTo.value)}',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _pickDateRange(context, ctrl),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  'Ubah',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _pickDateRange(
      BuildContext context, StockOutReportController ctrl) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: ctrl.dateFrom.value,
        end: ctrl.dateTo.value,
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.setDateRange(picked.start, picked.end);
    }
  }
}

// ---------------------------------------------------------------------------
// Report body
// ---------------------------------------------------------------------------

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});

  final StockOutReportModel report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: LucideIcons.packageOpen,
                iconColor: AppColors.primary,
                label: 'Total Quantity',
                value: '${report.totalQuantity}',
                subtitle: 'unit keluar',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: LucideIcons.circleDollarSign,
                iconColor: AppColors.secondary,
                label: 'Total Nilai',
                value: _formatRp(report.totalValue),
                subtitle: 'nilai stok keluar',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Top 5
        Text('5 Obat Teratas', style: AppTextStyles.sectionHeader),
        const SizedBox(height: 10),

        if (report.top5.isEmpty)
          _EmptyTop5()
        else
          ...report.top5.asMap().entries.map(
                (e) => _Top5Tile(rank: e.key + 1, item: e.value),
              ),
      ],
    );
  }

  String _formatRp(double value) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return fmt.format(value);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.sectionHeader,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Top5Tile extends StatelessWidget {
  const _Top5Tile({required this.rank, required this.item});

  final int rank;
  final StockOutTop5Model item;

  @override
  Widget build(BuildContext context) {
    final isTop = rank == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTop
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isTop
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  isTop ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTextStyles.caption.copyWith(
                  color: isTop
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name & code
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.cardTitle),
                Text(
                  item.code,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Totals
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.totalQuantity} unit',
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                _formatRp(item.totalValue),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRp(double value) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return fmt.format(value);
  }
}

class _EmptyTop5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          'Tidak ada data pada periode ini',
          style: AppTextStyles.body
              .copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.clipboardList,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data laporan',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertCircle,
                size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
