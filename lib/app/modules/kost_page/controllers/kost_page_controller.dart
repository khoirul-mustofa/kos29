import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kos29/app/modules/home/controllers/home_controller.dart';

import 'package:kos29/app/routes/app_pages.dart';

class KostPageController extends GetxController {
  final kosanList = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final int limit = 10;
  DocumentSnapshot? lastDocument;

  @override
  void onInit() {
    super.onInit();
    loadKos(firstLoad: true);
  }

  void refreshHomePage() {
    Get.find<HomeController>().refreshHomePage();
  }

  Future<void> loadKos({bool firstLoad = false}) async {
    if (firstLoad) {
      isLoading.value = true;
      kosanList.clear();
      lastDocument = null;
      hasMore.value = true;
    } else {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('kosts')
          .orderBy('created_at', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;

        final loadedKost =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'nama': data['nama'] ?? 'Tanpa Nama',
                'alamat': data['alamat'] ?? '',
                ...data,
              };
            }).toList();

        kosanList.addAll(loadedKost);

        if (loadedKost.length < limit) hasMore.value = false;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data kost: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void goToAddKost() => Get.toNamed(Routes.MANAGEMENT_KOST_ADD_KOST);

  void goToDetail(String id) =>
      Get.toNamed(Routes.MANAGEMENT_KOST_DETAIL_KOST, arguments: {'id': id});

  @override
  void onClose() {
    super.onClose();
    refreshHomePage();
  }
}
