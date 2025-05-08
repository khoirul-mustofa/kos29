import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/services/visit_history_service.dart';

class HistorySearchController extends GetxController {
  List<Map<String, String>> historyVisit = [];
  VisitHistoryService visitHistoryService = VisitHistoryService();
  RxList<KostModel> kostData = <KostModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getHistorySearch();
  }

  void getHistorySearch() async {
    isLoading.value = true;
    kostData.clear();
    historyVisit = await visitHistoryService.getVisitedKosts();

    // Load data in reverse order to show newest first
    for (var element in historyVisit.reversed) {
      await getKostById(element['kostId']!, element['visitedAt']!);
    }
    isLoading.value = false;
  }

  Future<void> getKostById(String id, String visitedAt) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('kosts').doc(id).get();

      final data = snapshot.data();
      if (data == null) {
        Get.snackbar('Error', 'Data kosan tidak ditemukan');
        return;
      }

      kostData.add(KostModel.fromMap(data)..visitedAt = visitedAt);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data kosan');
    }
  }
}
