import 'package:get/get.dart';

import '../controllers/auth_reset_password_controller.dart';

class AuthResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthResetPasswordController>(
      () => AuthResetPasswordController(),
    );
  }
}
