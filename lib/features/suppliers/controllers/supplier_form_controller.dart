import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/repositories/supplier_repository.dart';
import '../models/supplier_model.dart';

class SupplierFormController extends GetxController {
  SupplierFormController(this._repo);

  final SupplierRepository _repo;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isActive = true.obs;
  SupplierModel? editing;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is SupplierModel) {
      editing = args;
      nameCtrl.text = args.name;
      phoneCtrl.text = args.phone ?? '';
      emailCtrl.text = args.email ?? '';
      addressCtrl.text = args.address ?? '';
      notesCtrl.text = args.notes ?? '';
      isActive.value = args.isActive;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }

  String? requiredText(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (!RegExp(r'^[\w\.\-]+@[\w\.-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  Future<bool> submit() async {
    if (isLoading.value) return false;
    if (!(formKey.currentState?.validate() ?? false)) return false;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      if (editing == null) {
        await _repo.create(
          name: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
          email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
          address:
              addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        );
      } else {
        await _repo.update(
          editing!.id,
          name: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          notes: notesCtrl.text.trim(),
          isActive: isActive.value,
        );
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
