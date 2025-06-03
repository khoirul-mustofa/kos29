import 'package:get/get.dart';
import '../controllers/kos_registration_controller.dart';

class KosRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KosRegistrationController>(
      () => KosRegistrationController(),
    );
  }
} 