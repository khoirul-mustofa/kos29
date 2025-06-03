import 'package:get/get.dart';

import 'package:package_info_plus/package_info_plus.dart';

class AboutAppController extends GetxController {
  var appVersion = ''.obs;
  @override
  void onInit() {
    super.onInit();
    loadAppVersion();
  }

  void loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
    update();
  }
}
