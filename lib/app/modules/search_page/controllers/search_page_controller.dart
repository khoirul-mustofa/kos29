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

    // Apply category filter
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

    // Apply search text filter
    if (_searchText.isNotEmpty) {
      list =
          list
              .where(
                (k) => k.nama.toLowerCase().contains(_searchText.toLowerCase()),
              )
              .toList();
    }

    // Calculate and sort by distance if location is available
    if (currentPosition != null) {
      final currentLat = currentPosition!.latitude;
      final currentLon = currentPosition!.longitude;

      // Calculate distance for each kost
      list =
          list.map((k) {
            k.distance = calculateDistanceService(
              currentLat,
              currentLon,
              k.latitude ?? 0,
              k.longitude ?? 0,
            );
            return k;
          }).toList();

      // Sort by distance (nearest to farthest)
      list.sort((a, b) => a.distance.compareTo(b.distance));
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
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Error',
            'Izin lokasi diperlukan untuk mengurutkan berdasarkan jarak',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Error',
          'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.',
          snackPosition: SnackPosition.BOTTOM,
        );
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
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi saat ini',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchKostData({bool loadMore = false}) async {
    if (isLoading || (!hasMore && loadMore)) return;

    try {
      isLoading = true;
      update();

      // Get all kost data without ordering to allow distance-based sorting
      Query query = FirebaseFirestore.instance.collection('kosts').limit(limit);

      if (loadMore && lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.last;

        final newKost =
            snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final kost = KostModel.fromMap({...data, 'idKos': doc.id});

              // Calculate distance if location is available
              if (currentPosition != null) {
                kost.distance = calculateDistanceService(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                  kost.latitude ?? 0,
                  kost.longitude ?? 0,
                );
              }

              return kost;
            }).toList();

        if (loadMore) {
          kostList.addAll(newKost);
        } else {
          kostList = newKost;
        }

        // Sort the entire list by distance if location is available
        if (currentPosition != null) {
          kostList.sort((a, b) => a.distance.compareTo(b.distance));
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      logger.e('⛔ fetchKostData error: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil data kos',
        snackPosition: SnackPosition.BOTTOM,
      );
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
