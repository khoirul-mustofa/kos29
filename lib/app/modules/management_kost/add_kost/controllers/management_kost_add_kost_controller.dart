import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class ManagementKostAddKostController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final fasilitasController = TextEditingController();

  final kosTersedia = true.obs;

  final jenis = 'Putra'.obs;
  final currentPosition = Rxn<LatLng>();

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  @override
  void onClose() {
    namaController.dispose();
    alamatController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    fasilitasController.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Akses Ditolak', 'Izin lokasi tidak diberikan');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      currentPosition.value = latLng;
      await _updateAlamatFromLatLng(latLng);
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal mendapatkan lokasi: $e');
    }
  }

  Future<void> updateMarker(LatLng point) async {
    currentPosition.value = point;
    await _updateAlamatFromLatLng(point);
  }

  Future<void> _updateAlamatFromLatLng(LatLng point) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        alamatController.text =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
      } else {
        alamatController.text =
            'Lat: ${point.latitude}, Lng: ${point.longitude}';
      }
    } catch (e) {
      alamatController.text = 'Lat: ${point.latitude}, Lng: ${point.longitude}';
    }
  }

  final uid = FirebaseAuth.instance.currentUser?.uid;

  void saveKost() async {
    if (formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        Get.snackbar('Error', 'User belum login');
        return;
      }

      final data = {
        'nama': namaController.text,
        'alamat': alamatController.text,
        'harga': int.tryParse(hargaController.text) ?? 0,
        'jenis': jenis.value,
        'deskripsi': deskripsiController.text,
        'fasilitas':
            fasilitasController.text.split(',').map((e) => e.trim()).toList(),
        'tersedia': kosTersedia.value,
        'latitude': currentPosition.value?.latitude,
        'longitude': currentPosition.value?.longitude,
        'created_at': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('kostan')
            .doc(uid)
            .collection('kost')
            .add({'informasi_kost': data});

        Get.back();
        Get.snackbar('Berhasil', 'Kosan berhasil disimpan');
      } catch (e) {
        Get.snackbar('Error', 'Gagal menyimpan data: $e');
      }
    }
  }
}
