import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kos29/app/routes/app_pages.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    final box = GetStorage();
    final hasSeenOnboarding = box.read('onboarding') ?? false;
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAllNamed(
        hasSeenOnboarding ? Routes.BOTTOM_NAV : Routes.ONBOARDING,
      );
    });
  }
}
