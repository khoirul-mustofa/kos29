import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/helper/request_permission_location_helper.dart';
import 'package:kos29/app/modules/profile/controllers/profile_controller.dart';
import 'package:kos29/app/services/haversine_service.dart';
import 'package:kos29/app/services/visit_history_service.dart';

class HomeController extends GetxController {
  final prfController = Get.put(ProfileController());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final VisitHistoryService _visitHistoryService = VisitHistoryService();

  KostModel? kunjunganTerakhir;
  List<KostModel> rekomendasiKosts = [];

  @override
  void onInit() {
    super.onInit();
    ambilKunjunganTerakhir();
    ambilRekomendasiTerdekat();
  }

  Future<void> ambilKunjunganTerakhir() async {
    logger.i('Mencoba mengambil kunjungan terakhir');
    try {
      final visitedIds = await _visitHistoryService.getVisitedKosts();

      if (visitedIds.isEmpty) {
        kunjunganTerakhir = null;
        update();
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
        kunjunganTerakhir = null;
        update();
        if (kDebugMode) {
          logger.w(
            'Dokumen tidak ditemukan di path: '
            'kosts/${latestKostId['kostId']}',
          );
        }
        return;
      }

      kunjunganTerakhir = KostModel.fromMap({
        'idKos': kostDoc.id,
        ...kostDoc.data()!,
      });
      update();
      if (kDebugMode) {
        logger.i('Kunjungan terakhir berhasil diambil');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.e('Gagal ambil kunjungan terakhir: $e');
      }
      kunjunganTerakhir = null;
      update();
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
      final allKosts =
          snapshot.docs.map((doc) {
            final data = {'idKos': doc.id, ...doc.data()};
            final kost = KostModel.fromMap(data);

            // Hitung dan set jarak
            kost.jarak = calculateDistance(
              posisi.latitude,
              posisi.longitude,
              kost.latitude,
              kost.longitude,
            );

            return kost;
          }).toList();

      // Urutkan berdasarkan jarak terdekat
      allKosts.sort((a, b) => (a.jarak ?? 0).compareTo(b.jarak ?? 0));

      // Ambil 5 terdekat
      rekomendasiKosts = allKosts.take(5).toList();
      update();

      logger.i("Berhasil ambil rekomendasi kost terdekat");
    } catch (e) {
      logger.e("Gagal ambil rekomendasi kost terdekat: $e");
      rekomendasiKosts = [];
      update();
    }
  }
}
