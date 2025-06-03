import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/services/visit_history_service.dart';

class HistorySearchController extends GetxController {
  final ScrollController scrollController = ScrollController();
  List<Map<String, String>> historyVisit = [];
  VisitHistoryService visitHistoryService = VisitHistoryService();
  RxList<KostModel> kostData = <KostModel>[].obs;
  RxBool isLoading = true.obs;

  int currentPage = 0;
  final int pageSize = 10;
  RxBool hasMore = true.obs;
  RxBool isFetchingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    getHistorySearch();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMoreHistory();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> getHistorySearch() async {
    isLoading.value = true;
    kostData.clear();

    historyVisit = await visitHistoryService.getVisitedKosts();

    historyVisit.sort(
      (a, b) => DateTime.parse(
        b['visitedAt']!,
      ).compareTo(DateTime.parse(a['visitedAt']!)),
    );

    currentPage = 0;
    hasMore.value = true;
    await loadMoreHistory();

    isLoading.value = false;
  }

  Future<void> loadMoreHistory() async {
    if (!hasMore.value || isFetchingMore.value) return;

    isFetchingMore.value = true;

    final start = currentPage * pageSize;
    final end = (currentPage + 1) * pageSize;
    final itemsToLoad = historyVisit.toList().sublist(
      start,
      end > historyVisit.length ? historyVisit.length : end,
    );

    List<Future<void>> futures =
        itemsToLoad.map((element) {
          return getKostById(element['kostId']!, element['visitedAt']!);
        }).toList();

    await Future.wait(futures);

    currentPage++;
    if (end >= historyVisit.length) hasMore.value = false;

    isFetchingMore.value = false;
  }

  Future<void> getKostById(String id, String visitedAt) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('kosts').doc(id).get();

      final data = snapshot.data();
      if (data == null) {
        logger.e('Data kosan tidak ditemukan');
        return;
      }

      kostData.add(KostModel.fromMap(data)..visitedAt = visitedAt);
    } catch (e) {
            logger.e('Gagal mengambil data kosan: $e');
    }
  }
}
