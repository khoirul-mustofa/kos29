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
    logger.i('Mencoba mengambil kunjungan terakhir');
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
      if (kDebugMode) {
        logger.i('Kunjungan terakhir berhasil diambil');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.e('Gagal ambil kunjungan terakhir: $e');
      }
      kunjunganTerakhir.value = null;
    }
  }

  Future<void> ambilRekomendasiTerdekat() async {
    try {
      final izin = await cekIzinLokasi();
      if (!izin) return;

      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      final snapshot = await _firestore.collection('kosts').get();

      final List<MapEntry<KostModel, dynamic>> kostWithDistance =
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

                final distance = calculateDistanceService(
                  posisi.latitude,
                  posisi.longitude,
                  (lat as num).toDouble(),
                  (lon as num).toDouble(),
                );

                final kost = KostModel.fromMap({'idKos': doc.id, ...data});
                kost.distance = distance;
                return MapEntry(kost, distance);
              })
              .whereType<MapEntry<KostModel, dynamic>>()
              .toList();

      kostWithDistance.sort((a, b) => a.value.compareTo(b.value));
      rekomendasiKosts.value =
          kostWithDistance.take(5).map((e) => e.key).toList();

      if (kDebugMode) {
        logger.i("Berhasil ambil rekomendasi kost terdekat");
      }
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
