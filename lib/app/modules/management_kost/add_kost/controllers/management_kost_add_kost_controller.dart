import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/kost_page/controllers/kost_page_controller.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ManagementKostAddKostController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final fasilitasController = TextEditingController();
  final kebijakanController = TextEditingController();
  final kamarTersediaController = TextEditingController();

  final kosTersedia = true.obs;
  final jenis = 'Putra'.obs;
  final currentPosition = Rxn<LatLng>();

  String? imageUrl;
  String? localImagePath;

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

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      // Get.snackbar("Info", "Tidak ada gambar dipilih");
      return;
    }

    localImagePath = pickedFile.path;
    update();

    final file = File(pickedFile.path);
    final fileName = basename(file.path);
    final fileBytes = await file.readAsBytes();
    final contentType = lookupMimeType(file.path);

    final bucket = Supabase.instance.client.storage.from('media');

    try {
      await bucket.remove([fileName]); // opsional
      final result = await bucket.uploadBinary(
        fileName,
        fileBytes,
        fileOptions: FileOptions(contentType: contentType),
      );

      if (result.isEmpty) throw Exception("Upload gagal");

      imageUrl = bucket.getPublicUrl(fileName);
      update();

      Get.snackbar("Sukses", "Gambar berhasil diupload");
    } catch (e) {
      Get.snackbar("Error", e.toString());
      logger.e(e);
    }
  }

  void saveKost() async {
    if (formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        Get.snackbar('Error', 'User belum login');
        return;
      }
      final idKos = Uuid().v1();
      final data = {
        'nama': namaController.text,
        'gambar': imageUrl,
        'alamat': alamatController.text,
        'harga': int.tryParse(hargaController.text) ?? 0,
        'jenis': jenis.value,
        'deskripsi': deskripsiController.text,
        'fasilitas':
            fasilitasController.text.split(',').map((e) => e.trim()).toList(),
        'tersedia': kosTersedia.value,
        'latitude': currentPosition.value?.latitude,
        'longitude': currentPosition.value?.longitude,
        'uid': uid,
        'id_kos': idKos,
        'kebijakan':
            kebijakanController.text.split(',').map((e) => e.trim()).toList(),
        'kamar_tersedia': int.tryParse(kamarTersediaController.text) ?? 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('kosts')
            .doc(idKos)
            .set(data);
        final listController = Get.find<KostPageController>();
        listController.loadKos(firstLoad: true);
        Get.snackbar('Berhasil', 'Kosan berhasil disimpan');
        Get.offNamed(Routes.KOST_PAGE);

        if (kDebugMode) {
          logger.d('Kosan berhasil disimpan');
        }
      } catch (e) {
        Get.snackbar('Error', 'Gagal menyimpan data: $e');
        if (kDebugMode) {
          logger.e('Gagal menyimpan data: $e');
        }
      }
    }
  }
}
