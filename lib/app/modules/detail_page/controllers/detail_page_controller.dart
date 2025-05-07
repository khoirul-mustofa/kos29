import 'package:get/get.dart';
import 'package:kos29/app/modules/home/controllers/home_controller.dart';

class DetailPageController extends GetxController {
  refreshHomePage() {
    Get.find<HomeController>().ambilKunjunganTerakhir();
  }
}
