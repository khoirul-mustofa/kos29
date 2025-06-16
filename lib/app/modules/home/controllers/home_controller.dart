import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/helper/request_permission_location_helper.dart';
import 'package:kos29/app/modules/profile/controllers/profile_controller.dart';
import 'package:kos29/app/services/haversine_service.dart';
import 'package:kos29/app/services/visit_history_service.dart';
import 'package:kos29/app/style/theme/theme_controller.dart';


class HomeController extends GetxController {
  final prfController = Get.put(ProfileController());
  final themeController = Get.put(ThemeController());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final VisitHistoryService _visitHistoryService = VisitHistoryService();
  

  final kunjunganTerakhir = Rxn<KostModel>();
  final rekomendasiKosts = <KostModel>[].obs;
  final isLoading = false.obs;
  final isDarkMode = false.obs;

  ThemeMode get theme => themeController.theme;

  void toggleTheme() {
    themeController.toggleTheme();
    isDarkMode.value = themeController.isDarkMode;
  }

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = themeController.isDarkMode;
  
    refreshHomePage();
  }

  Future<void> refreshHomePage() async {
    Future.microtask(() {
      isLoading.value = true;
    });

    await ambilKunjunganTerakhir();
    await ambilRekomendasiTerdekat();

    Future.microtask(() {
      isLoading.value = false;
    });
  }

  Future<void> ambilKunjunganTerakhir() async {
    try {
      final visitedIds = await _visitHistoryService.getVisitedKosts();

      if (visitedIds.isEmpty) {
        kunjunganTerakhir.value = null;
        if (kDebugMode) {
          logger.i('Tidak ada kunjungan terakhir');
        }
        return;
      }

      final latestKostId = visitedIds.last;

      final kostDoc =
          await _firestore
              .collection('kosts')
              .doc(latestKostId['kostId'])
              .get();

      if (!kostDoc.exists) {
        kunjunganTerakhir.value = null;
        if (kDebugMode) {
          logger.w(
            'Dokumen tidak ditemukan di path: '
            'kosts/${latestKostId['kostId']}',
          );
        }
        return;
      }

      kunjunganTerakhir.value = KostModel.fromMap({
        'idKos': kostDoc.id,
        ...kostDoc.data()!,
      });
    } catch (e) {
      if (kDebugMode) {
        logger.e('Gagal ambil kunjungan terakhir: $e');
      }
      kunjunganTerakhir.value = null;
    }
  }

  Future<void> ambilRekomendasiTerdekat() async {
    try {
      final snapshot = await _firestore.collection('kosts').get();

      final List<KostModel> kosts =
          snapshot.docs
              .map((doc) {
                final data = doc.data();
                final lat = data['latitude'];
                final lon = data['longitude'];

                if (lat == null || lon == null) {
                  logger.w(
                    'Data kost ${doc.id} tidak memiliki koordinat lengkap.',
                  );
                  return null;
                }

                return KostModel.fromMap({'idKos': doc.id, ...data});
              })
              .whereType<KostModel>()
              .toList();

      // Calculate distances and sort
      final List<MapEntry<KostModel, double?>> kostsWithDistance = [];

      for (final kost in kosts) {
        final distance = await calculateDistanceFromCurrentLocation(
          kost.latitude!,
          kost.longitude!,
        );
        kostsWithDistance.add(MapEntry(kost, distance));
      }

      // Sort by distance, null distances will be at the end
      kostsWithDistance.sort((a, b) {
        if (a.value == null && b.value == null) return 0;
        if (a.value == null) return 1;
        if (b.value == null) return -1;
        return a.value!.compareTo(b.value!);
      });

      // Take top 5 closest kosts
      rekomendasiKosts.value =
          kostsWithDistance.take(5).map((entry) => entry.key).toList();
    } catch (e) {
      logger.e("Gagal ambil rekomendasi kost terdekat: $e");
      rekomendasiKosts.clear();
    }
  }

  void showLanguageDialog(BuildContext context) {
    final currentLang = Get.locale?.languageCode ?? 'id';
    Get.defaultDialog(
      title: 'home_language_title'.tr,
      content: Column(
        children: [
          ListTile(
            leading: const Text('🇮🇩', style: TextStyle(fontSize: 24)),
            title: Text('home_language_indonesia'.tr),
            trailing:
                currentLang == 'id'
                    ? const Icon(Icons.check, color: Colors.teal)
                    : null,
            onTap: () {
              Get.updateLocale(const Locale('id', 'ID'));
              Get.back();
            },
          ),
          ListTile(
            leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
            title: const Text('English'),
            trailing:
                currentLang == 'en'
                    ? const Icon(Icons.check, color: Colors.teal)
                    : null,
            onTap: () {
              Get.updateLocale(const Locale('en', 'US'));
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
