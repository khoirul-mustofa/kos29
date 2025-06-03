import 'package:get/get.dart';

import '../controllers/register_kos_controller.dart';

class RegisterKosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterKosController>(
      () => RegisterKosController(),
    );
  }
}
