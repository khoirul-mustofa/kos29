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
  final isLoading = false.obs;
  final isUploadingImage = false.obs;

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
    // Add listeners to all controllers
    namaController.addListener(_updateFormState);
    alamatController.addListener(_updateFormState);
    hargaController.addListener(_updateFormState);
    deskripsiController.addListener(_updateFormState);
    fasilitasController.addListener(_updateFormState);
    kamarTersediaController.addListener(_updateFormState);
  }

  @override
  void onClose() {
    // Remove listeners
    namaController.removeListener(_updateFormState);
    alamatController.removeListener(_updateFormState);
    hargaController.removeListener(_updateFormState);
    deskripsiController.removeListener(_updateFormState);
    fasilitasController.removeListener(_updateFormState);
    kamarTersediaController.removeListener(_updateFormState);

    namaController.dispose();
    alamatController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    fasilitasController.dispose();
    super.onClose();
  }

  void _updateFormState() {
    update(); // This will trigger a rebuild of the view
  }

  bool get isFormValid {
    // Validasi nama (minimal 3 karakter)
    final namaValid = namaController.text.trim().length >= 3;

    // Validasi alamat (minimal 10 karakter)
    final alamatValid = alamatController.text.trim().length >= 10;

    // Validasi harga (harus angka dan lebih dari 0)
    final hargaValid =
        int.tryParse(hargaController.text.trim()) != null &&
        int.parse(hargaController.text.trim()) > 0;

    // Validasi deskripsi (minimal 20 karakter)
    final deskripsiValid = deskripsiController.text.trim().length >= 20;

    // Validasi fasilitas (minimal 1 item, dipisahkan koma)
    final fasilitasValid =
        fasilitasController.text.trim().isNotEmpty &&
        fasilitasController.text.trim().contains(',');

    // Validasi kamar tersedia (harus angka dan lebih dari 0)
    final kamarValid =
        int.tryParse(kamarTersediaController.text.trim()) != null &&
        int.parse(kamarTersediaController.text.trim()) > 0;

    // Validasi lokasi
    final lokasiValid = currentPosition.value != null;

    // Validasi gambar
    final gambarValid = imageUrl != null;

    if (kDebugMode) {
      print('Form Validation Status:');
      print(
        'Nama (min 3 karakter): $namaValid - "${namaController.text.trim()}"',
      );
      print(
        'Alamat (min 10 karakter): $alamatValid - "${alamatController.text.trim()}"',
      );
      print(
        'Harga (harus > 0): $hargaValid - "${hargaController.text.trim()}"',
      );
      print(
        'Deskripsi (min 20 karakter): $deskripsiValid - "${deskripsiController.text.trim()}"',
      );
      print(
        'Fasilitas (min 1 item): $fasilitasValid - "${fasilitasController.text.trim()}"',
      );
      print(
        'Kamar (harus > 0): $kamarValid - "${kamarTersediaController.text.trim()}"',
      );
      print('Lokasi: $lokasiValid');
      print('Gambar: $gambarValid');
    }

    return namaValid &&
        alamatValid &&
        hargaValid &&
        deskripsiValid &&
        fasilitasValid &&
        kamarValid &&
        lokasiValid &&
        gambarValid;
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
      return;
    }

    isUploadingImage.value = true;
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
    } finally {
      isUploadingImage.value = false;
    }
  }

  void saveKost() async {
    // Validasi nama (minimal 3 karakter)
    if (namaController.text.trim().length < 3) {
      Get.snackbar(
        'Error',
        'Nama kosan minimal 3 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi alamat (minimal 10 karakter)
    if (alamatController.text.trim().length < 10) {
      Get.snackbar(
        'Error',
        'Alamat minimal 10 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi harga (harus angka dan lebih dari 0)
    if (int.tryParse(hargaController.text.trim()) == null ||
        int.parse(hargaController.text.trim()) <= 0) {
      Get.snackbar(
        'Error',
        'Harga harus lebih dari 0',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi deskripsi (minimal 20 karakter)
    if (deskripsiController.text.trim().length < 20) {
      Get.snackbar(
        'Error',
        'Deskripsi minimal 20 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi fasilitas (minimal 1 item, dipisahkan koma)
    if (!fasilitasController.text.trim().contains(',')) {
      Get.snackbar(
        'Error',
        'Fasilitas harus dipisahkan dengan koma (contoh: WiFi, AC, Kamar Mandi)',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi kamar tersedia (harus angka dan lebih dari 0)
    if (int.tryParse(kamarTersediaController.text.trim()) == null ||
        int.parse(kamarTersediaController.text.trim()) <= 0) {
      Get.snackbar(
        'Error',
        'Jumlah kamar harus lebih dari 0',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi lokasi
    if (currentPosition.value == null) {
      Get.snackbar(
        'Error',
        'Lokasi belum dipilih',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi gambar
    if (imageUrl == null) {
      Get.snackbar(
        'Error',
        'Gambar belum diupload',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
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

      await FirebaseFirestore.instance.collection('kosts').doc(idKos).set(data);

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
    } finally {
      isLoading.value = false;
    }
  }
}
