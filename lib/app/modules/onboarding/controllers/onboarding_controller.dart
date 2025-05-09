import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  late final PageController pageController;
  final RxInt currentPage = 0.obs;

  final images = [
    'assets/lottie/Animation-onboarding-3.json',
    'assets/lottie/Animation-onboarding-2.json',
    'assets/lottie/Animation-onboarding-1.json',
  ];
  final List<String> titles = [
    'Temukan Kost Terdekat Secara Akurat',
    'Rekomendasi Cerdas Sesuai Kebutuhanmu',
    'Pencarian Kost Lebih Cepat dan Efisien',
  ];

  final List<String> descriptions = [
    'Dengan teknologi Haversine, kami menghitung jarak antar lokasi secara presisi. Kamu bisa melihat kost terdekat dari tempat kamu berada — tanpa ribet!',
    'Pakai algoritma KNN, kami menyarankan kost berdasarkan preferensi kamu seperti harga, fasilitas, dan lokasi. Nggak perlu cari manual satu-satu!',
    'Gabungan algoritma pintar bikin kamu hemat waktu dan tenaga. Cukup satu aplikasi, semua kost relevan langsung muncul!',
  ];

  void completeOnboarding() {
    Get.offAllNamed(Routes.BOTTOM_NAV);
  }

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();

    pageController.addListener(() {
      final newPage = pageController.page?.round() ?? 0;
      if (newPage != currentPage.value) {
        currentPage.value = newPage;
      }
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
