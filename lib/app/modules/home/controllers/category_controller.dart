import 'dart:developer';

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
    var kosts = query.docs
        .map((doc) => KostModel.fromMap({'idKos': doc.id, ...doc.data()}))
        .toList();

    // Cek izin lokasi dan hitung jarak di awal
    final izin = await cekIzinLokasi();
    if (izin) {
      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      for (var kost in kosts) {
        final lat = kost.latitude;
        final lon = kost.longitude;

        if (lat != null && lon != null) {
          final distanceInKm = calculateDistanceService(
            posisi.latitude,
            posisi.longitude,
            lat,
            lon,
          );
          kost.distance = distanceInKm;
        } else {
          kost.distance = double.infinity;
        }
      }
    } else if (category == 'Terdekat') {
      Get.snackbar(
        'Peringatan',
        'Izin lokasi diperlukan untuk menampilkan kost terdekat',
        snackPosition: SnackPosition.TOP,
      );
      isLoading.value = false;
      return;
    }

    // Pemrosesan berdasarkan kategori
    if (category == 'Terdekat') {
      kosts.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (category == 'Terbaik') {
      final Map<String, Map<String, dynamic>> kostRatings = {};

      final reviewsQuery = await _firestore
          .collection('reviews')
          .where('hidden', isEqualTo: false)
          .get();

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

      kosts.sort((a, b) {
        final aRating = kostRatings[a.idKos]?['totalRating'] ?? 0.0;
        final bRating = kostRatings[b.idKos]?['totalRating'] ?? 0.0;
        final aCount = kostRatings[a.idKos]?['count'] ?? 0;
        final bCount = kostRatings[b.idKos]?['count'] ?? 0;

        if (aRating == bRating) {
          return bCount.compareTo(aCount);
        }
        return bRating.compareTo(aRating);
      });
    } else {
      switch (category) {
        case 'Termurah':
          kosts.sort((a, b) => a.harga.compareTo(b.harga));
          break;
        case 'Termahal':
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
