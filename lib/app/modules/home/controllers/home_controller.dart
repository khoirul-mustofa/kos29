import 'package:get/get.dart';
import 'package:kos29/app/modules/profile/controllers/profile_controller.dart';

class HomeController extends GetxController {
  final prfController = Get.put(ProfileController());
}
