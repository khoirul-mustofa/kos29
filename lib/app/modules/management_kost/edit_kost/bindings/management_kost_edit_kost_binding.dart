import 'package:get/get.dart';

import '../controllers/management_kost_edit_kost_controller.dart';

class ManagementKostEditKostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagementKostEditKostController>(
      () => ManagementKostEditKostController(),
    );
  }
}
