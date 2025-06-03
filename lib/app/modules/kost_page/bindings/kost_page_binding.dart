import 'package:get/get.dart';

import '../controllers/kost_page_controller.dart';

class KostPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KostPageController>(
      () => KostPageController(
        isForUpdateRequest: Get.arguments?['isForUpdateRequest'] ?? false,
      ),
    );
  }
}
