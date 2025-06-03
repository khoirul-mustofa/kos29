import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:kos29/app/helper/request_permission_location_helper.dart';

double calculateDistanceService(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double R = 6371; // Radius bumi dalam kilometer

  double latDistance = _degToRad(lat2 - lat1);
  double lonDistance = _degToRad(lon2 - lon1);

  double a =
      sin(latDistance / 2) * sin(latDistance / 2) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          sin(lonDistance / 2) *
          sin(lonDistance / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c; // Jarak dalam kilometer
}

Future<double?> calculateDistanceFromCurrentLocation(
  double targetLat,
  double targetLon,
) async {
  try {
    final izin = await cekIzinLokasi();
    if (!izin) return null;

    final posisi = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return calculateDistanceService(
      posisi.latitude,
      posisi.longitude,
      targetLat,
      targetLon,
    );
  } catch (e) {
    return null;
  }
}

double _degToRad(double deg) {
  return deg * (pi / 180);
}

