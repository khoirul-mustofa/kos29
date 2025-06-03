import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/logger_app.dart';
import '../../../../data/models/kos_registration.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KosRegistrationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final registrations = <KosRegistration>[].obs;
  final filteredRegistrations = <KosRegistration>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'pending'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRegistrations();
  }

  Future<void> fetchRegistrations() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot =
          await _firestore
              .collection('kos_registrations')
              .orderBy('createdAt', descending: true)
              .get();

      registrations.value =
          snapshot.docs
              .map(
                (doc) => KosRegistration.fromJson(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

      filterRegistrations();
    } catch (e) {
      logger.e("Gagal mengambil data registrasi kos: $e");
      Get.snackbar(
        'Error',
        'Gagal mengambil data registrasi kos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterRegistrations() {
    if (selectedFilter.value == 'all') {
      filteredRegistrations.value = registrations;
    } else {
      filteredRegistrations.value =
          registrations
              .where((reg) => reg.status == selectedFilter.value)
              .toList();
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    filterRegistrations();
  }

  Future<void> updateRegistrationStatus(
    String registrationId,
    String status, {
    String? rejectionReason,
  }) async {
    try {
      isLoading.value = true;

      final data = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (rejectionReason != null) {
        data['rejectionReason'] = rejectionReason;
      }

      await _firestore
          .collection('kos_registrations')
          .doc(registrationId)
          .update(data);

      // If approved, create the kos listing
      if (status == 'approved') {
        final registration = registrations.firstWhere(
          (r) => r.id == registrationId,
        );
        await _createKosListing(registration);
      }

      Get.snackbar(
        'Sukses',
        'Status registrasi berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await fetchRegistrations();
    } catch (e) {
      logger.e("Gagal memperbarui status registrasi: $e");
      Get.snackbar(
        'Error',
        'Gagal memperbarui status registrasi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createKosListing(KosRegistration registration) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      if (registration.id == null)
        throw Exception('Registration ID is required');

      await _firestore.collection('kosts').doc(registration.id).set({
        'namaKos': registration.namaKos,
        'jenis': registration.jenis,
        'alamat': registration.alamat,
        'latitude': registration.latitude,
        'longitude': registration.longitude,
        'deskripsi': registration.deskripsi,
        'fasilitas': registration.fasilitas,
        'harga': registration.harga,
        'uangJaminan': registration.uangJaminan,
        'fotoKosUrls': registration.fotoKosUrls,
        'namaPemilik': registration.namaPemilik,
        'nomorHp': registration.nomorHp,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'uid': registration.ownerId,
        'ownerId': registration.ownerId,
        'id_kos': registration.id,
        'kamar_tersedia': 0,
        'kebijakan': [],
        'gambar':
            registration.fotoKosUrls.isNotEmpty
                ? registration.fotoKosUrls[0]
                : '',
      });
    } catch (e) {
      logger.e("Error creating kos listing: $e");
    }
  }

  void showRejectionDialog(String registrationId) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Alasan Penolakan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan',
                hintText: 'Masukkan alasan penolakan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Alasan penolakan harus diisi',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              Get.back();
              updateRegistrationStatus(
                registrationId,
                'rejected',
                rejectionReason: reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}
