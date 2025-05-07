import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class ManagementKostEditKostController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final fasilitasController = TextEditingController();

  final kosTersedia = true.obs;

  final jenis = 'Putra'.obs;
  final currentPosition = Rxn<LatLng>();

  final idKost = Get.arguments['id'];
  String? imageUrl;

  @override
  void onInit() {
    super.onInit();
    loadKost();
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

  void loadKost() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('kosts').doc(idKost).get();

    final data = snapshot.data();
    if (data == null) {
      Get.snackbar('Error', 'Data kosan tidak ditemukan');
      return;
    }
    namaController.text = data['nama'];
    alamatController.text = data['alamat'];
    hargaController.text = data['harga'].toString();
    deskripsiController.text = data['deskripsi'];
    fasilitasController.text = data['fasilitas'].join(', ');
    kosTersedia.value = data['tersedia'];
    jenis.value = data['jenis'];
    imageUrl = data['gambar'];
    currentPosition.value = LatLng(data['latitude'], data['longitude']);
    update();
    await _updateAlamatFromLatLng(currentPosition.value!);
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

  void saveKost() async {
    if (formKey.currentState!.validate()) {
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
        'updated_at': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('kosts')
            .doc(idKost)
            .update(data);

        final kostPageController = Get.find<KostPageController>();
        kostPageController.loadKos(firstLoad: true);
        Get.offNamed(Routes.KOST_PAGE);

        Get.snackbar('Berhasil', 'Kosan berhasil diperbarui');
      } catch (e) {
        Get.snackbar('Error', 'Gagal memperbarui data: $e');
      }
    }
  }

  String generateUniqueFileName(String fileName) {
    return 'uploads/$fileName';
  }

  String? localImagePath;
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      Get.snackbar("Info", "Tidak ada gambar dipilih");
      return;
    }

    localImagePath = pickedFile.path; // preview gambar lokal
    update(); // trigger rebuild widget GetBuilder

    final file = File(pickedFile.path);
    final fileName = basename(file.path);
    final fileBytes = await file.readAsBytes();
    final contentType = lookupMimeType(file.path);

    final bucket = Supabase.instance.client.storage.from('media');

    try {
      await bucket.remove([fileName]);
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
}
