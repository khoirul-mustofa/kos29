import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/services/haversine.dart';

class SearchPageController extends GetxController {
  String location = "";

  double distance = 0.0;

  double lat1 = -6.2088; // Latitude untuk titik A (misalnya Jakarta)
  double lon1 = 106.8456; // Longitude untuk titik A
  double lat2 = -7.7956; // Latitude untuk titik B (misalnya Yogyakarta)
  double lon2 = 110.3695; // Longitude untuk titik B

  List<String> category = ['Terdekat', 'Termurah', 'Termahal', 'Terbaik'];
  int selectedCategory = 0;

  @override
  void onInit() {
    super.onInit();
    getCurrentPosition();
    distance = calculateDistance(lat1, lon1, lat2, lon2);
  }

  Future<void> getCurrentPosition() async {
    try {
      // meminta izin lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // jika service tidak diaktifkan
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // jika permission denied, mengembalikan error
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // jika izin lokasi ditolak secara permanen
        return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      // mendapatkan lokasi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      location = "${position.latitude}, ${position.longitude}";
      logger.i('location : $position.latitude, $position.longitude');
      update();
    } catch (e) {
      location = "error : $e";
      update();
    }
  }
}
