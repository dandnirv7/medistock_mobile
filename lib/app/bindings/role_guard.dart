import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/storage/auth_session.dart';
import '../../core/utils/snackbar_helper.dart';
import '../routes/app_routes.dart';

class RoleGuard extends GetMiddleware {
  RoleGuard._();

  /// Allows access to admins only. Non-admin authenticated users are
  /// sent back to the home shell with a snackbar. Unauthenticated
  /// users are sent to the login screen.
  static final RoleGuard requireAdmin = RoleGuard._();

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthSession>()) {
      return const RouteSettings(name: AppRoutes.login);
    }
    final session = Get.find<AuthSession>();
    if (!session.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (session.isAdmin) {
      return null;
    }
    _notifyStaffBlocked();
    return const RouteSettings(name: AppRoutes.home);
  }

  void _notifyStaffBlocked() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SnackbarHelper.error('Hanya admin yang dapat membuka halaman ini.');
    });
  }
}
