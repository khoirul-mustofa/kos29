import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreenController extends GetxController {
   var appVersion = ''.obs;
  @override
  void onInit() async {
    super.onInit();
    loadAppVersion();
    final box = GetStorage();
    final hasSeenOnboarding = box.read('onboarding') ?? false;
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(
        hasSeenOnboarding ? Routes.BOTTOM_NAV : Routes.ONBOARDING,
      );
    });
    

  }

   void loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';

  }
}
