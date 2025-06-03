import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/kost_page/controllers/kost_page_controller.dart';

class ManagementKostDetailKostController extends GetxController {
  final kost = Rx<KostModel?>(null);
  final isLoading = true.obs;
  final imageUrls = <String>[].obs;
  final isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final kostId = Get.arguments['id'] as String;
    loadKost(kostId);
  }

  Future<void> loadKost(String kostId) async {
    try {
      isLoading.value = true;
      final doc =
          await FirebaseFirestore.instance
              .collection('kosts')
              .doc(kostId)
              .get();

      if (doc.exists) {
        final kostData = KostModel.fromJson({'id': doc.id, ...doc.data()!});
        kost.value = kostData;
        imageUrls.value = kostData.fotoKosUrls;
      } else {
        Get.snackbar(
          'Error',
          'Data kost tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      }
    } catch (e) {
      logger.e('Error loading kost: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data kost',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToEdit() {
    if (kost.value != null) {
      Get.toNamed(
        Routes.MANAGEMENT_KOST_EDIT_KOST,
        arguments: {'id': kost.value!.id},
      );
    }
  }

  String getFormattedPrice(int price) {
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  String getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'pending':
        return 'Menunggu Persetujuan';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Kost'),
        content: const Text('Apakah Anda yakin ingin menghapus kost ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Get.back();
              deleteKost();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> deleteKost() async {
    if (kost.value == null) return;

    try {
      isDeleting.value = true;

      // Delete images from Firebase Storage
      final storage = FirebaseStorage.instance;
      for (final imageUrl in kost.value!.fotoKosUrls) {
        try {
          final ref = storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          logger.e('Error deleting image: $e');
          // Continue with other images even if one fails
        }
      }

      // Delete kost document from Firestore
      await FirebaseFirestore.instance
          .collection('kosts')
          .doc(kost.value!.id)
          .delete();

      Get.snackbar(
        'Berhasil',
        'Kosan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back to kost list
      Get.until((route) => route.settings.name == Routes.KOST_PAGE);
      Get.find<KostPageController>().loadKos(firstLoad: true);
    } catch (e) {
      logger.e('Error deleting kost: $e');
      Get.snackbar(
        'Error',
        'Gagal menghapus kosan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }
}
