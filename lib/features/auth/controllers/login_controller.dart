import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  LoginController(this._repo);

  final AuthRepository _repo;

  final usernameCtrl = TextEditingController(text: 'admin');
  final passwordCtrl = TextEditingController(text: 'admin123');
  final formKey = GlobalKey<FormState>();

  final RxBool obscure = true.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }

  void toggleObscure() => obscure.value = !obscure.value;

  String? validateRequired(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  Future<void> submit() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await _repo.login(
        username: usernameCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      await Get.find<AuthSession>().setAuth(
        token: res.token,
        user: res.user,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      errorMessage.value = _humanize(e);
    } finally {
      isLoading.value = false;
    }
  }

  String _humanize(Object e) {
    final msg = e.toString();
    if (msg.contains('Username atau password salah')) return msg;
    if (msg.contains('401')) return 'Username atau password salah';
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return 'Tidak dapat terhubung ke server';
    }
    return 'Terjadi kesalahan: $msg';
  }
}
