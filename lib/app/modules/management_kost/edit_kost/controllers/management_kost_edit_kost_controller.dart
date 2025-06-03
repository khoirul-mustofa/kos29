import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/kost_page/controllers/kost_page_controller.dart';
import 'package:kos29/app/modules/management_kost/detail_kost/controllers/management_kost_detail_kost_controller.dart';
import 'package:kos29/app/services/firebase_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManagementKostEditKostController extends GetxController {
  final _firebaseService = FirebaseService();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final fasilitasController = TextEditingController();
  final kamarTersediaController = TextEditingController();
  final namaPemilikController = TextEditingController();
  final nomorHpController = TextEditingController();
  final uangJaminanController = TextEditingController();
  final kebijakanController = TextEditingController();
  final kosTersedia = true.obs;
  final jenis = 'putra'.obs;
  final currentPosition = Rxn<LatLng>();
  final idKost = Get.arguments['id'];
  final imageUrls = <String>[].obs;
  final uploadedImages = <String>[].obs;
  final fotoKos = <XFile>[].obs;

  final kost = Rxn<KostModel>();

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
    kamarTersediaController.dispose();
    namaPemilikController.dispose();
    nomorHpController.dispose();
    uangJaminanController.dispose();
    kebijakanController.dispose();
    super.onClose();
  }

  void loadKost() async {
    isLoading.value = true;
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('kosts')
              .doc(idKost)
              .get();

      final data = snapshot.data();
      if (data == null) {
        logger.e('Data kosan tidak ditemukan');
        return;
      }

      kost.value = KostModel.fromJson({...data, 'id': idKost});

      // Update form controllers with model data
      namaController.text = kost.value!.nama;
      alamatController.text = kost.value!.alamat;
      hargaController.text = kost.value!.harga.toString();
      deskripsiController.text = kost.value!.deskripsi;
      fasilitasController.text = kost.value!.fasilitas.join(', ');
      kosTersedia.value = kost.value!.status == 'active';
      jenis.value = kost.value!.jenis.toLowerCase();
      imageUrls.value = kost.value!.fotoKosUrls;
      uploadedImages.value = kost.value!.fotoKosUrls;
      kamarTersediaController.text = kost.value!.kamarTersedia.toString();
      namaPemilikController.text = kost.value!.namaPemilik;
      nomorHpController.text = kost.value!.nomorHp;
      uangJaminanController.text = kost.value?.uangJaminan?.toString() ?? '';
      kebijakanController.text = kost.value?.kebijakan.join(', ') ?? '';
      currentPosition.value = LatLng(
        kost.value!.latitude ?? 0,
        kost.value!.longitude ?? 0,
      );
      update();
      await _updateAlamatFromLatLng(currentPosition.value!);
    } finally {
      isLoading.value = false;
    }
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
      try {
        if (kost.value == null || kost.value!.id == null) {
          Get.snackbar('Error', 'Data kos tidak valid');
          return;
        }

        final originalId =
            kost.value!.id!; // We know it's not null from the check above

        // Create updated kost model using existing data and new values
        final updatedKost = KostModel(
          id: originalId,
          namaKos: namaController.text,
          jenis: jenis.value,
          alamat: alamatController.text,
          latitude: currentPosition.value?.latitude,
          longitude: currentPosition.value?.longitude,
          deskripsi: deskripsiController.text,
          fasilitas:
              fasilitasController.text.split(',').map((e) => e.trim()).toList(),
          harga: int.tryParse(hargaController.text) ?? 0,
          fotoKosUrls: uploadedImages,
          namaPemilik: namaPemilikController.text,
          nomorHp: nomorHpController.text,
          status: kosTersedia.value ? 'active' : 'inactive',
          ownerId: kost.value!.ownerId,
          kamarTersedia: int.tryParse(kamarTersediaController.text) ?? 0,
          createdAt: kost.value!.createdAt,
          updatedAt: DateTime.now(),
          uangJaminan: int.tryParse(uangJaminanController.text),
          kebijakan:
              kebijakanController.text.split(',').map((e) => e.trim()).toList(),
        );

        // Convert model to JSON and update Firestore
        await FirebaseFirestore.instance
            .collection('kosts')
            .doc(originalId)
            .update(updatedKost.toJson());

        final kostPageController = Get.find<KostPageController>();
        kostPageController.loadKos(firstLoad: true);
        final detailKosController =
            Get.find<ManagementKostDetailKostController>();
        detailKosController.loadKost(originalId);

        Get.back(result: true);
        Get.snackbar('Berhasil', 'Kosan berhasil diperbarui');
      } catch (e) {
        Get.snackbar('Gagal', 'Gagal memperbarui data');
        logger.e('Gagal memperbarui data: $e');
      }
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final List<XFile> newImages = await picker.pickMultiImage();
    if (newImages.isEmpty) {
      Get.snackbar("Info", "Tidak ada gambar dipilih");
      return;
    }

    isLoading.value = true;
    try {
      // Use a consistent folder path based on kost ID instead of timestamp
      final userId = kost.value?.ownerId ?? '';
      final kostId = kost.value?.id ?? '';

      // Upload new images
      final newFotoKosUrls = await _firebaseService.uploadFiles(
        newImages,
        'kos_photos/$userId/$kostId',
      );

      // Create a Set to track unique URLs
      final Set<String> uniqueUrls = Set<String>.from(uploadedImages);

      // Add only new unique URLs
      for (final url in newFotoKosUrls) {
        if (!uniqueUrls.contains(url)) {
          uniqueUrls.add(url);
        }
      }

      // Update both lists with unique URLs
      final uniqueUrlsList = uniqueUrls.toList();
      uploadedImages.value = uniqueUrlsList;
      imageUrls.value = uniqueUrlsList;

      update();

      Get.snackbar(
        "Sukses",
        "Gambar berhasil diupload${newFotoKosUrls.length > 1 ? ' (${newFotoKosUrls.length} gambar)' : ''}",
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal upload gambar: ${e.toString()}");
      logger.e(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new method to safely remove images
  void removeImageAtIndex(int index) async {
    if (index < 0 || index >= imageUrls.length) {
      logger.e(
        'Invalid index for image removal: $index (total images: ${imageUrls.length})',
      );
      Get.snackbar('Error', 'Gagal menghapus gambar: index tidak valid');
      return;
    }

    try {
      // Get the image URL to be removed
      final imageUrlToRemove = imageUrls[index];

      // Delete the image from Firebase Storage
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrlToRemove);
        await ref.delete();
      } catch (e) {
        logger.e('Error deleting image from storage: $e');
        // Continue with UI update even if storage deletion fails
      }

      // Create new lists without the removed image
      final newImageUrls = List<String>.from(imageUrls)..removeAt(index);

      // Update both lists atomically to maintain consistency
      uploadedImages.value = newImageUrls;
      imageUrls.value = newImageUrls;

      update();
      Get.snackbar('Sukses', 'Gambar berhasil dihapus');
    } catch (e) {
      logger.e('Error removing image: $e');
      Get.snackbar('Error', 'Gagal menghapus gambar');
    }
  }

  // Update the existing removeImage method to use the new safe method
  void removeImage(int index) {
    removeImageAtIndex(index);
  }
}
