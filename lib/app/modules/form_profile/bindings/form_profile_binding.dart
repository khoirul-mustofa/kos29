import 'package:get/get.dart';

import '../controllers/form_profile_controller.dart';

class FormProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormProfileController>(
      () => FormProfileController(),
    );
  }
}
