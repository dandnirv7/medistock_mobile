import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/storage/auth_session.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.redirectRoute = AppRoutes.login});

  final String redirectRoute;

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<AuthSession>();
    if (!session.isAuthenticated) {
      return RouteSettings(name: redirectRoute);
    }
    return null;
  }
}
