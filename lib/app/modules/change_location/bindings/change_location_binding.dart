import 'package:get/get.dart';

import '../controllers/change_location_controller.dart';

class ChangeLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChangeLocationController>(
      () => ChangeLocationController(),
    );
  }
}
