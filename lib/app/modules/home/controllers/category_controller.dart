import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/helper/request_permission_location_helper.dart';
import 'package:kos29/app/services/haversine_service.dart';

class CategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final categoryKosts = <KostModel>[].obs;
  final isLoading = false.obs;
  final String category;

  CategoryController({required this.category});

  @override
  void onInit() {
    super.onInit();
    getKostsByCategory();
  }

  Future<void> getKostsByCategory() async {
    try {
      isLoading.value = true;
      final query = await _firestore.collection('kosts').get();
      var kosts =
          query.docs
              .map((doc) => KostModel.fromMap({'idKos': doc.id, ...doc.data()}))
              .toList();

      if (category == 'Terdekat') {
        final izin = await cekIzinLokasi();
        if (!izin) {
          Get.snackbar(
            'Peringatan',
            'Izin lokasi diperlukan untuk menampilkan kost terdekat',
            snackPosition: SnackPosition.TOP,
          );
          isLoading.value = false;
          return;
        }

        final posisi = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        // Hitung jarak untuk setiap kost
        for (var kost in kosts) {
          final lat = kost.latitude;
          final lon = kost.longitude;

          if (lat != null && lon != null) {
            // Konversi jarak ke kilometer
            final distanceInMeters = Geolocator.distanceBetween(
              posisi.latitude,
              posisi.longitude,
              lat,
              lon,
            );
            kost.distance = distanceInMeters / 1000; // Konversi ke kilometer
          } else {
            kost.distance =
                double.infinity; // Kost tanpa koordinat akan muncul di akhir
          }
        }

        // Urutkan berdasarkan jarak
        kosts.sort((a, b) => a.distance.compareTo(b.distance));
      } else if (category == 'Terbaik') {
        // Buat map untuk menyimpan rating dan jumlah ulasan
        final Map<String, Map<String, dynamic>> kostRatings = {};

        // Ambil semua ulasan yang tidak disembunyikan
        final reviewsQuery =
            await _firestore
                .collection('reviews')
                .where('hidden', isEqualTo: false)
                .get();

        // Hitung rating dan jumlah ulasan untuk setiap kost
        for (var review in reviewsQuery.docs) {
          final data = review.data();
          final kostId = data['kostId'] as String;
          final rating = (data['rating'] ?? 0).toDouble();

          if (!kostRatings.containsKey(kostId)) {
            kostRatings[kostId] = {'totalRating': 0.0, 'count': 0};
          }

          kostRatings[kostId]!['totalRating'] += rating;
          kostRatings[kostId]!['count'] += 1;
        }

        // Urutkan kost berdasarkan rating dan jumlah ulasan
        kosts.sort((a, b) {
          final aRating = kostRatings[a.idKos]?['totalRating'] ?? 0.0;
          final bRating = kostRatings[b.idKos]?['totalRating'] ?? 0.0;
          final aCount = kostRatings[a.idKos]?['count'] ?? 0;
          final bCount = kostRatings[b.idKos]?['count'] ?? 0;

          // Jika rating sama, bandingkan jumlah ulasan
          if (aRating == bRating) {
            return bCount.compareTo(aCount);
          }
          // Urutkan berdasarkan rating tertinggi
          return bRating.compareTo(aRating);
        });
      } else {
        switch (category) {
          case 'Termurah':
            // Sort by price ascending
            kosts.sort((a, b) => a.harga.compareTo(b.harga));
            break;
          case 'Termahal':
            // Sort by price descending
            kosts.sort((a, b) => b.harga.compareTo(a.harga));
            break;
        }
      }

      categoryKosts.value = kosts;
      isLoading.value = false;
    } catch (e) {
      logger.e('Error getting kosts by category: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal mengambil data kost',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
