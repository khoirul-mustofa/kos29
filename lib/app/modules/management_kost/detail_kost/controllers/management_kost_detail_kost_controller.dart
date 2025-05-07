import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/kost_page/controllers/kost_page_controller.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagementKostDetailKostController extends GetxController {
  final kostData = <String, dynamic>{}.obs;
  final id = Get.arguments['id'] as String;

  String? imageUrl;

  @override
  void onInit() {
    super.onInit();
    loadKost(id);
  }

  void loadKost(String id) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('kosts').doc(id).get();

    final data = snapshot.data();
    if (data == null) {
      Get.snackbar('Error', 'Data kosan tidak ditemukan');
      return;
    }

    kostData.value = data;
    imageUrl = data['gambar'] ?? '';
    update();
  }

  void goToEdit() {
    Get.toNamed(Routes.MANAGEMENT_KOST_EDIT_KOST, arguments: {'id': id});
  }

  Future<void> deleteImage() async {
    if (imageUrl == null || imageUrl!.isEmpty) {
      logger.i("Tidak ada gambar untuk dihapus");
      return;
    }

    try {
      final bucket = Supabase.instance.client.storage.from('media');
      final fileName = Uri.parse(imageUrl!).pathSegments.last;
      await bucket.remove(['uploads/$fileName']);
      imageUrl = null;
    } catch (e) {
      logger.e("Gagal menghapus gambar: $e");
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
        Get.back();

        try {
          await deleteImage();

          await FirebaseFirestore.instance.collection('kosts').doc(id).delete();

          Get.back(); // Kembali ke list
          Get.snackbar('Berhasil', 'Kosan telah dihapus');

          final kostPageController = Get.find<KostPageController>();
          kostPageController.loadKos(firstLoad: true);
          Get.offNamed(Routes.KOST_PAGE);
        } catch (e) {
          Get.snackbar('Gagal', 'Terjadi kesalahan: $e');
        }
      },
    );
  }
}
