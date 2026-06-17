import 'package:get/get.dart';

import '../controllers/home_shell_controller.dart';

class HomeShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeShellController());
  }
}
