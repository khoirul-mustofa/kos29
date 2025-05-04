import 'package:get/get.dart';

import '../controllers/unauth_controller.dart';

class UnauthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnauthController>(
      () => UnauthController(),
    );
  }
}
