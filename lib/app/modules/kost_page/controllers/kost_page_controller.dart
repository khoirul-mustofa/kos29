import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kos29/app/routes/app_pages.dart';

class KostPageController extends GetxController {
  final kosanList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadKos();
  }

  Future<void> loadKos() async {
    try {
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
              .get();

      final List<Map<String, dynamic>> loadedKost =
          snapshot.docs.map((doc) {
            final rawData = doc.data();
            final Map<String, dynamic> informasi = Map<String, dynamic>.from(
              rawData['informasi_kost'] ?? {},
            );
            return {
              'id': doc.id,
              'nama': informasi['nama'] ?? 'Tanpa Nama',
              'alamat': informasi['alamat'] ?? '',
              ...informasi,
            };
          }).toList();

      kosanList.assignAll(loadedKost);
    } catch (e) {
      Get.snackbar('Error loading kos', e.toString());
    }
  }

  void goToAddKost() {
    Get.toNamed(Routes.MANAGEMENT_KOST_ADD_KOST);
  }

  void goToDetail(String id) {
    Get.toNamed(Routes.MANAGEMENT_KOST_DETAIL_KOST, arguments: id);
  }
}
