import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAllNamed(Routes.ONBOARDING);
    });
  }
}
