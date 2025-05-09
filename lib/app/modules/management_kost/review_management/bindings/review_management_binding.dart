import 'package:get/get.dart';

import '../controllers/review_management_controller.dart';

class ReviewManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewManagementController>(
      () => ReviewManagementController(),
    );
  }
}
