import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeLocationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final currentLocation =
      const LatLng(-6.2088, 106.8456).obs; // Default to Jakarta
  final selectedAddress = ''.obs;
  final markers = <Marker>[].obs;
  final mapController = MapController();
  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Error',
          'Layanan lokasi tidak aktif',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Error',
            'Izin lokasi ditolak',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      currentLocation.value = latLng;
      updateMarker(latLng);
      getAddressFromLatLng(latLng);
      mapController.move(latLng, 15);
    } catch (e) {
      logger.e("Error getting location: $e");
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void onMapTap(TapPosition tapPosition, LatLng point) {
    currentLocation.value = point;
    updateMarker(point);
    getAddressFromLatLng(point);
  }

  void updateMarker(LatLng latLng) {
    markers.clear();
    markers.add(
      Marker(
        point: latLng,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
      ),
    );
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.subLocality}, ${place.locality}';
        selectedAddress.value = address;
        textController.text = '${latLng.latitude}, ${latLng.longitude}';
      }
    } catch (e) {
      selectedAddress.value = 'Tidak dapat mendapatkan alamat';
    }
  }

  Future<void> saveLocation() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'User tidak ditemukan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'latitude': currentLocation.value.latitude,
        'longitude': currentLocation.value.longitude,
        'address': selectedAddress.value,
        'updated_at': DateTime.now().toIso8601String(),
      });

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Lokasi berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan lokasi: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
