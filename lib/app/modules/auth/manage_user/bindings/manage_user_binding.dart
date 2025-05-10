import 'package:get/get.dart';
import '../controllers/manage_user_controller.dart';

class ManageUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageUserController>(() => ManageUserController());
  }
}
