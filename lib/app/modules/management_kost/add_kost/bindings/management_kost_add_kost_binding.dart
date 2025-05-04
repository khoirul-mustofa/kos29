import 'package:get/get.dart';

import '../controllers/management_kost_add_kost_controller.dart';

class ManagementKostAddKostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagementKostAddKostController>(
      () => ManagementKostAddKostController(),
    );
  }
}
