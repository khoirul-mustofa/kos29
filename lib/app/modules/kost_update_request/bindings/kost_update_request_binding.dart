import 'package:get/get.dart';
import 'package:kos29/app/modules/kost_update_request/controllers/kost_update_request_controller.dart';

class KostUpdateRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KostUpdateRequestController>(
      () => KostUpdateRequestController(kost: Get.arguments),
    );
  }
}
