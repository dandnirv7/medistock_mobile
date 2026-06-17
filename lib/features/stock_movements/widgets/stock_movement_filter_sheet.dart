import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/stock_movement_list_controller.dart';
import '../models/stock_movement_model.dart';

class StockMovementFilterSheet extends StatefulWidget {
  const StockMovementFilterSheet({super.key});

  @override
  State<StockMovementFilterSheet> createState() =>
      _StockMovementFilterSheetState();
}

class _StockMovementFilterSheetState extends State<StockMovementFilterSheet> {
  late final StockMovementListController _ctrl = Get.find();
  late final TextEditingController _noteCtrl;
  late StockMovementType? _type;
  late DateTime? _start;
  late DateTime? _end;
  late String? _medicineId;

  @override
  void initState() {
    super.initState();
    _type = _ctrl.typeFilter.value;
    _start = _ctrl.startDate.value;
    _end = _ctrl.endDate.value;
    _medicineId = _ctrl.medicineId.value;
    _noteCtrl = TextEditingController(text: _ctrl.noteQuery.value ?? '');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Filter Riwayat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _SectionLabel('Rentang Tanggal'),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: _start == null
                            ? 'Mulai'
                            : DateFormatter.toDisplayShort(_start!),
                        onTap: () => _pickDate(true),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('-'),
                    ),
                    Expanded(
                      child: _DateField(
                        label: _end == null
                            ? 'Selesai'
                            : DateFormatter.toDisplayShort(_end!),
                        onTap: () => _pickDate(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionLabel('Jenis Mutasi'),
                _TypeSelector(
                  value: _type,
                  onChanged: (v) => setState(() => _type = v),
                ),
                const SizedBox(height: 16),
                _SectionLabel('Pilih Obat'),
                _MedicineDropdown(
                  value: _medicineId,
                  onChanged: (v) => setState(() => _medicineId = v),
                ),
                const SizedBox(height: 16),
                _SectionLabel('Catatan (Opsional)'),
                TextField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Cari catatan...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _apply,
                  child: const Text('Terapkan Filter'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset Filter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = (isStart ? _start : _end) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _apply() async {
    await _ctrl.setDateRange(_start, _end);
    await _ctrl.setType(_type);
    await _ctrl.setMedicine(_medicineId);
    await _ctrl.setNoteQuery(_noteCtrl.text);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _reset() async {
    setState(() {
      _type = null;
      _start = null;
      _end = null;
      _medicineId = null;
      _noteCtrl.clear();
    });
    await _ctrl.resetFilters();
    if (mounted) Navigator.of(context).pop();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.value, required this.onChanged});

  final StockMovementType? value;
  final ValueChanged<StockMovementType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _Chip(
          label: 'Semua',
          selected: value == null,
          onTap: () => onChanged(null),
          selectedColor: AppColors.primary,
        ),
        _Chip(
          label: 'Stok Masuk (IN)',
          selected: value == StockMovementType.stockIn,
          onTap: () => onChanged(StockMovementType.stockIn),
          selectedColor: AppColors.success,
        ),
        _Chip(
          label: 'Stok Keluar (OUT)',
          selected: value == StockMovementType.stockOut,
          onTap: () => onChanged(StockMovementType.stockOut),
          selectedColor: AppColors.danger,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor : AppColors.surface,
          border: Border.all(
            color: selected ? selectedColor : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _MedicineDropdown extends StatelessWidget {
  const _MedicineDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StockMovementListController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(
        () => DropdownButton<String?>(
          value: value,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          hint: const Text('Pilih obat...'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Semua Obat'),
            ),
            ...ctrl.medicineOptions.map(
              (m) => DropdownMenuItem<String?>(
                value: m.id,
                child: Text(m.name, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
