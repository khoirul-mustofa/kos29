import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/kos_registration.dart';
import '../../../services/firebase_service.dart';

class RegisterKosController extends GetxController {
  final _firebaseService = FirebaseService();
  final formKey = GlobalKey<FormState>();

  // Form fields
  final namaKos = ''.obs;
  final jenis = 'putra'.obs;
  final alamat = ''.obs;
  final latitude = Rx<double?>(null);
  final longitude = Rx<double?>(null);
  final deskripsi = ''.obs;
  final fasilitas = <String>[].obs;
  final harga = 0.obs;
  final uangJaminan = Rx<int?>(null);
  final fotoKos = <XFile>[].obs;
  final ktpFile = Rx<XFile?>(null);
  final buktiKepemilikanFile = Rx<XFile?>(null);
  final namaPemilik = ''.obs;
  final nomorHp = ''.obs;

  // Map related
  final searchQuery = ''.obs;
  final isSearching = false.obs;
  final currentZoom = 15.0.obs;
  final currentPosition = Rxn<LatLng>();
  final selectedLocation = Rx<LatLng?>(null);

  // Available facilities
  final availableFasilitas = [
    'WiFi',
    'Kamar mandi dalam',
    'AC',
    'Parkir',
    'Dapur',
    'TV',
    'Kasur',
    'Lemari',
    'Meja belajar',
    'Kipas angin',
  ];

  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestPermission = await Geolocator.requestPermission();
        if (requestPermission == LocationPermission.denied) {
          Get.snackbar(
            'Error',
            'Izin lokasi diperlukan untuk menggunakan fitur ini',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Error',
          'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      currentPosition.value = latLng;
      selectedLocation.value = latLng;
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      await getAddressFromLatLng(latLng);
    } catch (e) {
      logger.e('getCurrentLocation: $e');
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi saat ini',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get address from coordinates
  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          if (place.street?.isNotEmpty ?? false) place.street,
          if (place.subLocality?.isNotEmpty ?? false) place.subLocality,
          if (place.locality?.isNotEmpty ?? false) place.locality,
          if (place.subAdministrativeArea?.isNotEmpty ?? false)
            place.subAdministrativeArea,
          if (place.administrativeArea?.isNotEmpty ?? false)
            place.administrativeArea,
          if (place.postalCode?.isNotEmpty ?? false) place.postalCode,
        ].where((e) => e != null).join(', ');

        alamat.value = address;
      }
    } catch (e) {
      logger.e('getAddressFromLatLng: $e');
    }
  }

  // Update marker position
  void updateMarker(LatLng point) {
    selectedLocation.value = point;
    latitude.value = point.latitude;
    longitude.value = point.longitude;
    getAddressFromLatLng(point);
  }

  // Search location
  Future<void> searchLocation() async {
    if (searchQuery.value.isEmpty) return;

    try {
      isSearching.value = true;
      final locations = await locationFromAddress(searchQuery.value);

      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);

        // Update map center and selected location
        currentPosition.value = latLng;
        selectedLocation.value = latLng;
        latitude.value = location.latitude;
        longitude.value = location.longitude;
        currentZoom.value = 15.0;

        // Get address for the selected location
        await getAddressFromLatLng(latLng);
      } else {
        Get.snackbar(
          'Error',
          'Lokasi tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      logger.e('searchLocation: $e');
      Get.snackbar(
        'Error',
        'Gagal mencari lokasi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSearching.value = false;
    }
  }

  // Pick multiple images for kos photos
  Future<void> pickFotoKos() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      fotoKos.addAll(images);
    }
  }

  // Pick single image for KTP or bukti kepemilikan
  Future<void> pickImage(ImageSource source, Rx<XFile?> target) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      target.value = image;
    }
  }

  // Toggle facility selection
  void toggleFasilitas(String fasilitas) {
    if (this.fasilitas.contains(fasilitas)) {
      this.fasilitas.remove(fasilitas);
    } else {
      this.fasilitas.add(fasilitas);
    }
  }

  // Validate form
  bool validateForm() {
    if (!formKey.currentState!.validate()) return false;

    // Validate nama kos (minimal 3 karakter)
    if (namaKos.value.trim().length < 3) {
      Get.snackbar(
        'Error',
        'Nama kos minimal 3 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate alamat (minimal 10 karakter)
    if (alamat.value.trim().length < 10) {
      Get.snackbar(
        'Error',
        'Alamat minimal 10 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate deskripsi (minimal 20 karakter)
    if (deskripsi.value.trim().length < 20) {
      Get.snackbar(
        'Error',
        'Deskripsi minimal 20 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate harga per bulan (harus lebih dari 0)
    if (harga.value <= 0) {
      Get.snackbar(
        'Error',
        'Harga per bulan harus lebih dari 0',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate fasilitas (minimal 1)
    if (fasilitas.isEmpty) {
      Get.snackbar(
        'Error',
        'Pilih minimal 1 fasilitas',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate foto kos (minimal 1 foto)
    if (fotoKos.isEmpty) {
      Get.snackbar(
        'Error',
        'Upload minimal 1 foto kos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate KTP
    if (ktpFile.value == null) {
      Get.snackbar(
        'Error',
        'Upload KTP pemilik',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate bukti kepemilikan
    if (buktiKepemilikanFile.value == null) {
      Get.snackbar(
        'Error',
        'Upload bukti kepemilikan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate nama pemilik (minimal 3 karakter)
    if (namaPemilik.value.trim().length < 3) {
      Get.snackbar(
        'Error',
        'Nama pemilik minimal 3 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate nomor HP (minimal 10 digit)
    if (nomorHp.value.trim().length < 10) {
      Get.snackbar(
        'Error',
        'Nomor HP minimal 10 digit',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate lokasi
    if (latitude.value == null || longitude.value == null) {
      Get.snackbar(
        'Error',
        'Pilih lokasi kos pada peta',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Submit form
  Future<void> submitForm() async {
    log('submitForm');
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      // Upload files to Firebase Storage
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create document ID using standardized format
      final documentId = 'KOS${timestamp}_${userId.substring(0, 8)}';

      // Upload kos photos
      final fotoKosUrls = await _firebaseService.uploadFiles(
        fotoKos,
        'kos_ photos/$userId/$timestamp',
      );

      // Upload KTP
      final ktpUrl = await _firebaseService.uploadFile(
        ktpFile.value!,
        'documents/$userId/ktp_$timestamp.jpg',
      );

      // Upload bukti kepemilikan
      final buktiUrl = await _firebaseService.uploadFile(
        buktiKepemilikanFile.value!,
        'documents/$userId/bukti_$timestamp.jpg',
      );

      // Create registration object
      final registration = KosRegistration(
        id: documentId,
        ownerId: userId.toString(),
        namaKos: namaKos.value,
        jenis: jenis.value,
        alamat: alamat.value,
        latitude: latitude.value,
        longitude: longitude.value,
        deskripsi: deskripsi.value,
        fasilitas: fasilitas,
        harga: harga.value,
        uangJaminan: uangJaminan.value,
        fotoKosUrls: fotoKosUrls,
        ktpUrl: ktpUrl,
        buktiKepemilikanUrl: buktiUrl,
        namaPemilik: namaPemilik.value,
        nomorHp: nomorHp.value,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firebaseService.saveKosRegistration(registration);

      Get.dialog(
        AlertDialog(
          title: const Text('Sukses'),
          content: const Text(
            'Berhasil dikirim. Kos kamu akan diverifikasi dalam 1x24 jam.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Return to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      logger.e('submitForm: $e');

      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
