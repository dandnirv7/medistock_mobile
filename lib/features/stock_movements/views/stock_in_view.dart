import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../medicines/models/medicine_model.dart';
import '../../suppliers/models/supplier_model.dart';
import '../controllers/stock_in_controller.dart';
import '../../../core/theme/app_icons.dart';

class StockInView extends GetView<StockInController> {
  const StockInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stok Masuk')),
      body: Obx(() {
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (controller.errorMessage.value != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    controller.errorMessage.value!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              _LabeledField(
                icon: AppIcons.medicationOutlined,
                child: _ObatDropdown(),
              ),
              if (controller.selectedMedicine != null) ...[
                const SizedBox(height: 8),
                _CurrentStockTile(medicine: controller.selectedMedicine!),
              ],
              const SizedBox(height: 14),
              _LabeledField(
                icon: AppIcons.localShippingOutlined,
                child: _SupplierDropdown(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _LabeledField(
                      icon: AppIcons.inventoryOutlined,
                      child: _QuantityField(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _UnitField(unit: controller.selectedMedicine?.unit ?? ''),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _LabeledField(
                icon: AppIcons.calendar_today_outlined,
                child: _DateField(),
              ),
              const SizedBox(height: 14),
              _LabeledField(
                icon: AppIcons.note_outlined,
                child: _NotesField(),
              ),
              const SizedBox(height: 20),
              _SummaryCard(),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final ok = await controller.submit();
                          if (ok) {
                            Get.back();
                            SnackbarHelper.success('Stok masuk berhasil disimpan');
                            await Haptics.lightSuccess();
                          }
                        },
                  icon: const Icon(AppIcons.save_outlined),
                  label: Text(
                    controller.isLoading.value ? 'Menyimpan…' : 'Simpan Stok Masuk',
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }
}

class _ObatDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<StockInController>();
    return DropdownButtonFormField<String>(
      initialValue: c.medicineId.value,
      isExpanded: true,
      items: c.medicines
          .map(
            (m) => DropdownMenuItem(
              value: m.id,
              child: Text(
                m.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: c.setMedicine,
      decoration: const InputDecoration(labelText: 'Obat'),
      validator: (v) => v == null ? 'Pilih obat terlebih dahulu' : null,
    );
  }
}

class _SupplierDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<StockInController>();
    return DropdownButtonFormField<String?>(
      initialValue: c.supplierId.value,
      isExpanded: true,
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Tanpa supplier'),
        ),
        ...c.suppliers.map(
          (SupplierModel s) => DropdownMenuItem<String?>(
            value: s.id,
            child: Text(s.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: c.setSupplier,
      decoration: const InputDecoration(labelText: 'Supplier'),
    );
  }
}

class _QuantityField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<StockInController>();
    return TextFormField(
      controller: c.quantityCtrl,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: 'Jumlah'),
      validator: c.positiveInt,
    );
  }
}

class _UnitField extends StatelessWidget {
  const _UnitField({required this.unit});
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        unit.isEmpty ? '-' : unit,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<StockInController>();
    return TextFormField(
      controller: c.dateCtrl,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: c.transactionDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) c.setDate(picked);
      },
      decoration: const InputDecoration(labelText: 'Tanggal Transaksi'),
    );
  }
}

class _NotesField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<StockInController>();
    return TextFormField(
      controller: c.notesCtrl,
      decoration: const InputDecoration(labelText: 'Catatan'),
      maxLines: 2,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<StockInController>();
    return Obx(() {
      final med = c.selectedMedicine;
      SupplierModel? supplier;
      for (final s in c.suppliers) {
        if (s.id == c.supplierId.value) {
          supplier = s;
          break;
        }
      }
      final qty = int.tryParse(c.quantityCtrl.text) ?? 0;
      final price = med?.purchasePrice ?? 0;
      final total = price * qty;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Transaksi',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            _SummaryRow('Obat', med?.name ?? '-'),
            _SummaryRow('Supplier', supplier?.name ?? 'Tanpa supplier'),
            _SummaryRow('Jumlah', qty > 0 ? '$qty ${med?.unit ?? ''}'.trim() : '-'),
            _SummaryRow('Harga Beli Satuan', CurrencyFormatter.format(price)),
            const Divider(height: 16),
            _SummaryRow(
              'Total Nilai',
              CurrencyFormatter.format(total),
              highlight: true,
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: highlight ? AppColors.primaryDark : AppColors.textPrimary,
                fontWeight:
                    highlight ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentStockTile extends StatelessWidget {
  const _CurrentStockTile({required this.medicine});
  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.info_outline, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Stok saat ini: ${medicine.currentStock} ${medicine.unit}',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
