import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool? hasSeenOnboarding = prefs.getBool('hasSeenOnboarding');
    // Cek apakah pengguna sudah login atau belum
    Future.delayed(const Duration(seconds: 1), () {
      // User? user = FirebaseAuth.instance.currentUser;
      Get.offAllNamed(Routes.BOTTOM_NAV);
      // if (hasSeenOnboarding == null || hasSeenOnboarding == false) {
      //   Get.offNamed(Routes.ONBOARDING);
      // } else {
      //   Get.offNamed(Routes.BOTTOM_NAV);
      // }
      // if (user != null) {
      //   // Jika sudah login, arahkan ke halaman Home
      //   Get.offNamed(Routes.BOTTOM_NAV);
      // } else {
      //   print('belum login');
      //   if (hasSeenOnboarding == null || hasSeenOnboarding == false) {
      //     Get.offNamed(Routes.ONBOARDING);
      //   } else {
      //     Get.offNamed(Routes.BOTTOM_NAV);
      //   }
      //   Get.offNamed(Routes.SIGN_IN);
      // }
    });
  }
}
