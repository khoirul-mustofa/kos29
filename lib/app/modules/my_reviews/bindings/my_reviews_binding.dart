import 'package:get/get.dart';
import '../controllers/my_reviews_controller.dart';

class MyReviewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyReviewsController>(
      () => MyReviewsController(),
    );
  }
} 