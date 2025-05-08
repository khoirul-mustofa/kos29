import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/home/controllers/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPageController extends GetxController {
  final dataKost = Get.arguments as KostModel;
  bool isDeskripsiExpanded = false;
  bool isFasilitasExpanded = false;
  bool isKebijakanExpanded = false;
  @override
  void onInit() {
    super.onInit();
    refreshHomePage();

    logger.i('data kost: ${dataKost.fasilitas.join(', ')}');
  }

  void toggleiExpanded(String key) {
    switch (key) {
      case 'fasilitas':
        isFasilitasExpanded = !isFasilitasExpanded;
        break;
      case 'deskripsi':
        isDeskripsiExpanded = !isDeskripsiExpanded;
        break;
      case 'kebijakan':
        isKebijakanExpanded = !isKebijakanExpanded;
        break;
    }
    update();
  }

  refreshHomePage() {
    Get.find<HomeController>().refreshHomePage();
  }

  void launchMapOnAndroid(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    try {
      String markerLabel = dataKost.nama;
      final url = Uri.parse(
        'geo:$latitude,$longitude?q=$latitude,$longitude($markerLabel)',
      );
      await launchUrl(url);
    } catch (error) {
      if (context.mounted) {
        Get.snackbar('Error', error.toString());
      }
    }
  }
}
