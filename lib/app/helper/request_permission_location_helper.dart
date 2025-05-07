import 'package:geolocator/geolocator.dart';
import 'package:kos29/app/helper/logger_app.dart';

Future<bool> cekIzinLokasi() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      logger.w('Izin lokasi ditolak');
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    logger.w('Izin lokasi ditolak permanen');
    return false;
  }

  return true;
}
