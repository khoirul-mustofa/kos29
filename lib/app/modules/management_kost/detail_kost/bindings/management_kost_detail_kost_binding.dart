import 'package:get/get.dart';

import '../controllers/management_kost_detail_kost_controller.dart';

class ManagementKostDetailKostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagementKostDetailKostController>(
      () => ManagementKostDetailKostController(),
    );
  }
}
