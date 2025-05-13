import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/profile/controllers/profile_controller.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  final addressController = TextEditingController();
  final usernameController = TextEditingController();
  final genderController = TextEditingController();
  final birthDateController = TextEditingController();
  final occupationController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;
  RxBool isUploadingImage = false.obs;
  RxString profileImageUrl = ''.obs;
  RxString gender = 'Laki-laki'.obs;
  String? localImagePath;



  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      isLoading.value = true;
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

      // Get data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      // Get data from Firebase Auth
      final authData = {
        'email': user.email,
        'displayName': user.displayName,
        'phoneNumber': user.phoneNumber,
        'photoURL': user.photoURL,
      };

      // Update controllers with data
      nameController.text =
          data?['displayName'] ?? authData['displayName'] ?? '';
      phoneController.text = data?['phone'] ?? authData['phoneNumber'] ?? '';
      emailController.text = authData['email'] ?? '';
      bioController.text = data?['bio'] ?? '';
      addressController.text = data?['address'] ?? '';
      usernameController.text = data?['username'] ?? '';
      genderController.text = data?['gender'] ?? 'Laki-laki';
      birthDateController.text = data?['birthDate'] ?? '';
      occupationController.text = data?['occupation'] ?? '';
      profileImageUrl.value = data?['photoURL'] ?? authData['photoURL'] ?? '';
      gender.value = data?['gender'] ?? 'Laki-laki';

      if (kDebugMode) {
        print('User Data from Auth: $authData');
        print('User Data from Firestore: $data');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil data profil: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      logger.e('Error fetching user data: $e');
    } finally {
      isLoading.value = false;
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

      profileImageUrl.value = bucket.getPublicUrl(fileName);
      update();

      // Get.snackbar("Sukses", "Gambar berhasil diupload");
    } catch (e) {
      Get.snackbar("Error", e.toString());
      logger.e(e);
    } finally {
      isUploadingImage.value = false;
    }
  }


  void updateProfile() async {
    try {
      if (nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Nama tidak boleh kosong',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;
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

      // Update Firebase Auth profile
      await user.updateDisplayName(nameController.text.trim());
      if (profileImageUrl.value.isNotEmpty) {
        await user.updatePhotoURL(profileImageUrl.value);
      }

      // Update Firestore data
      final data = {
        'displayName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'bio': bioController.text.trim(),
        'address': addressController.text.trim(),
        'photoURL': profileImageUrl.value,
        'username': usernameController.text.trim(),
        'gender': gender.value,
        'birthDate': birthDateController.text.trim(),
        'occupation': occupationController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(user.uid).update(data);

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      logger.e('Error updating profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    bioController.dispose();
    addressController.dispose();
    usernameController.dispose();
    genderController.dispose();
    birthDateController.dispose();
    occupationController.dispose();
    final controllerProfile = Get.find<ProfileController>();
    controllerProfile.getCurrentUser();
    super.onClose();
  }
}
