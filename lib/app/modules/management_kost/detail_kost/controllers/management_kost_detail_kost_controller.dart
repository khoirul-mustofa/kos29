import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/routes/app_pages.dart';

class ManagementKostDetailKostController extends GetxController {
  final kostData = <String, dynamic>{}.obs;
  final id = Get.arguments;

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
  }

  void goToEdit() {
    Get.toNamed(Routes.MANAGEMENT_KOST_EDIT_KOST, arguments: {'id': id});
  }

  void deleteKost() {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Yakin ingin menghapus kosan ini?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      onConfirm: () {
        Get.back(); // tutup dialog
        Get.back(); // kembali ke list
        Get.snackbar('Berhasil', 'Kosan telah dihapus');
      },
    );
  }
}
