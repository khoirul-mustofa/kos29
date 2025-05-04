import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/kost_page/controllers/kost_page_controller.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagementKostDetailKostController extends GetxController {
  final kostData = <String, dynamic>{}.obs;
  final id = Get.arguments;
  String? imageUrl;

  @override
  void onInit() {
    super.onInit();
    loadKost(id);
  }

  void loadKost(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Pengguna belum login');
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('kostan')
            .doc(user.uid)
            .collection('kost')
            .doc(id)
            .get();

    final data = snapshot.data();
    if (data == null) {
      Get.snackbar('Error', 'Data kosan tidak ditemukan');
      return;
    }
    kostData.value = data;
    imageUrl = data['gambar'];
  }

  void goToEdit() {
    Get.toNamed(Routes.MANAGEMENT_KOST_EDIT_KOST, arguments: {'id': id});
  }

  Future<void> deleteImage() async {
    if (imageUrl == null) {
      logger.i("Tidak ada gambar untuk dihapus");
      return;
    }

    try {
      final bucket = Supabase.instance.client.storage.from('media');

      // Ekstrak nama file dari URL
      final fileName = Uri.parse(imageUrl!).pathSegments.last;

      // Hapus file dari bucket Supabase
      await bucket.remove(['uploads/$fileName']);

      imageUrl = null; // Kosongkan URL
      update(); // Update UI jika pakai GetBuilder
    } catch (e) {
      logger.e(e);
    }
  }

  void deleteKost() async {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Yakin ingin menghapus kosan ini?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // Tutup dialog konfirmasi
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            Get.snackbar('Error', 'Pengguna belum login');
            return;
          }

          // Panggil dulu delete gambar
          await deleteImage();

          // Lanjutkan dengan menghapus data kosan
          await FirebaseFirestore.instance
              .collection('kostan')
              .doc(user.uid)
              .collection('kost')
              .doc(id)
              .delete();

          Get.back(); // Kembali ke halaman sebelumnya (daftar kos)
          Get.snackbar('Berhasil', 'Kosan telah dihapus');

          // Refresh daftar kosan
          final listController = Get.find<KostPageController>();
          listController.loadKos();
        } catch (e) {
          Get.snackbar('Gagal', 'Terjadi kesalahan: $e');
        }
      },
    );
  }
}
