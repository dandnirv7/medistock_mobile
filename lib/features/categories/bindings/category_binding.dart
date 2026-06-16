import 'package:get/get.dart';

import '../../../core/config/dummy_flag.dart';
import '../../../core/network/api_client.dart';
import '../controllers/category_form_controller.dart';
import '../controllers/category_list_controller.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/category_repository_api.dart';
import '../data/repositories/category_repository_dummy.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryRepository>(
      () => kUseDummyData
          ? CategoryRepositoryDummy()
          : CategoryRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => CategoryListController(Get.find<CategoryRepository>()));
    Get.lazyPut(
        () => CategoryFormController(Get.find<CategoryRepository>()));
  }
}
