import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:kos29/app/services/haversine_service.dart';

class SearchPageController extends GetxController {
  List<KostModel> kostList = [];
  List<String> category = ["semua", "putra", "putri", "campur"];
  int selectedCategory = 0;
  bool isLoading = false;
  bool hasMore = true;
  int limit = 10;
  DocumentSnapshot? lastDoc;
  String _searchText = '';
  Position? currentPosition;
  List<KostModel> get filteredKost {
    List<KostModel> list = kostList;

    if (selectedCategory > 0) {
      list =
          list
              .where(
                (k) =>
                    k.jenis.toLowerCase() ==
                    category[selectedCategory].toLowerCase(),
              )
              .toList();
    }

    if (currentPosition != null) {
      final currentLat = currentPosition!.latitude;
      final currentLon = currentPosition!.longitude;

      list =
          list.map((k) {
            k.distance = calculateDistanceService(
              currentLat,
              currentLon,
              k.latitude,
              k.longitude,
            );
            return k;
          }).toList();

      list.sort((a, b) => a.distance.compareTo(b.distance));
    }

    if (_searchText.isNotEmpty) {
      list =
          list
              .where(
                (k) => k.nama.toLowerCase().contains(_searchText.toLowerCase()),
              )
              .toList();
    }

    return list;
  }

  void changeCategory(int index) {
    selectedCategory = index;
    update();
  }

  void search(String text) {
    _searchText = text;
    update();
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        logger.e('❌ Location permission denied forever');
        return;
      }

      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      update();
    } catch (e) {
      logger.e('❌ Error getting location: $e');
    }
  }

  Future<void> fetchKostData({bool loadMore = false}) async {
    if (isLoading || (!hasMore && loadMore)) return;

    try {
      isLoading = true;
      update();

      Query query = FirebaseFirestore.instance
          .collection('kosts')
          .orderBy('nama')
          .limit(limit);

      if (loadMore && lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.last;

        final newKost =
            snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final kost = KostModel.fromMap(data);
              kost.idKos = doc.id; // Assign document ID ke model

              if (currentPosition != null) {
                final distance = Geolocator.distanceBetween(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                  kost.latitude,
                  kost.longitude,
                );
                kost.distance = distance / 1000;
              }

              return kost;
            }).toList();

        if (loadMore) {
          kostList.addAll(newKost);
        } else {
          kostList = newKost;
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      logger.e('⛔ fetchKostData error: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> gotoDetailPage(KostModel kost) async {
    if (kost.idKos.isEmpty) return;
    Get.toNamed(Routes.DETAIL_PAGE, arguments: kost);
  }

  Future<void> refreshKost() async {
    kostList.clear();
    lastDoc = null;
    hasMore = true;
    await getCurrentLocation();
    await fetchKostData();
  }

  @override
  void onInit() {
    super.onInit();
    refreshKost();
  }
}
