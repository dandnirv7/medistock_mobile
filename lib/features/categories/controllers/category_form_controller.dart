import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryFormController extends GetxController {
  CategoryFormController(this._repo);

  final CategoryRepository _repo;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isActive = true.obs;
  CategoryModel? editing;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is CategoryModel) {
      editing = args;
      nameCtrl.text = args.name;
      descCtrl.text = args.description ?? '';
      isActive.value = args.isActive;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  String? requiredText(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
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
          description: descCtrl.text.trim().isEmpty
              ? null
              : descCtrl.text.trim(),
        );
      } else {
        await _repo.update(
          editing!.id,
          name: nameCtrl.text.trim(),
          description: descCtrl.text.trim().isEmpty
              ? null
              : descCtrl.text.trim(),
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
