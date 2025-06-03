import 'package:get/get.dart';
import 'package:kos29/app/modules/admin/kost_update_requests/controllers/admin_kost_update_requests_controller.dart';

class AdminKostUpdateRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminKostUpdateRequestsController>(
      () => AdminKostUpdateRequestsController(),
    );
  }
}
