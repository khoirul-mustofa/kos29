import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kos29/app/helper/logger_app.dart';
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

  final idKost = Get.arguments['id'] as String;
  String? imageUrl;

  @override
  void onInit() {
    super.onInit();
    logger.i('id kost: $idKost');
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
    final user = FirebaseAuth.instance.currentUser;
    logger.i('user: ${user?.uid}');
    if (user == null) {
      Get.snackbar('Error', 'Pengguna belum login');
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('kostan')
            .doc(user.uid)
            .collection('kost')
            .doc(idKost)
            .get();

    final data = snapshot.data();
    logger.i('data: $data');
    logger.i(snapshot.data());
    if (data == null) {
      Get.snackbar('Error', 'Data kosan tidak ditemukan');
      return;
    }
    namaController.text = data['informasi_kost']['nama'];
    alamatController.text = data['informasi_kost']['alamat'];
    hargaController.text = data['informasi_kost']['harga'].toString();
    deskripsiController.text = data['informasi_kost']['deskripsi'];
    fasilitasController.text = data['informasi_kost']['fasilitas'].join(', ');
    kosTersedia.value = data['informasi_kost']['tersedia'];
    jenis.value = data['informasi_kost']['jenis'];
    currentPosition.value = LatLng(
      data['informasi_kost']['latitude'],
      data['informasi_kost']['longitude'],
    );
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
        'updated_at':
            FieldValue.serverTimestamp(), // Gunakan field updated_at untuk menandakan waktu pembaruan
      };

      try {
        // Menggunakan update untuk memperbarui data yang sudah ada
        await FirebaseFirestore.instance
            .collection('kostan')
            .doc(uid)
            .collection('kost')
            .doc(idKost) // Menentukan dokumen berdasarkan idKost
            .update({'informasi_kost': data});

        Get.back();
        Get.snackbar('Berhasil', 'Kosan berhasil diperbarui');
      } catch (e) {
        Get.snackbar('Error', 'Gagal memperbarui data: $e');
      }
    }
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      Get.snackbar("Info", "Tidak ada gambar dipilih");
      return;
    }

    final file = File(pickedFile.path);
    final fileName = basename(file.path);
    final fileBytes = await file.readAsBytes();
    final contentType = lookupMimeType(file.path);

    final bucket = Supabase.instance.client.storage.from('media');

    try {
      await bucket.remove(['uploads/$fileName']); // Optional: hapus duplikat
      final result = await bucket.uploadBinary(
        'uploads/$fileName',
        fileBytes,
        fileOptions: FileOptions(contentType: contentType),
      );

      if (result.isEmpty) throw Exception("Upload gagal");

      final url = bucket.getPublicUrl('uploads/$fileName');
      imageUrl = url;
      update(); // penting untuk GetBuilder

      Get.snackbar("Sukses", "Gambar berhasil diupload");
    } catch (e) {
      Get.snackbar("Error", e.toString());
      logger.e(e);
    }
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
      await bucket.remove(['uploads/$fileName']); // opsional
      final result = await bucket.uploadBinary(
        'uploads/$fileName',
        fileBytes,
        fileOptions: FileOptions(contentType: contentType),
      );

      if (result.isEmpty) throw Exception("Upload gagal");

      imageUrl = bucket.getPublicUrl('uploads/$fileName');
      update(); // update UI

      Get.snackbar("Sukses", "Gambar berhasil diupload");
    } catch (e) {
      Get.snackbar("Error", e.toString());
      logger.e(e);
    }
  }
}
