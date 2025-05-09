import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  void fetchUserData() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['displayName'] ?? '';
      phoneController.text = data['phone'] ?? '';
    }
  }

  void updateProfile() async {
    try {
      isLoading.value = true;
      final uid = _auth.currentUser!.uid;

      await _firestore.collection('users').doc(uid).update({
        'displayName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      isLoading.value = false;

      Get.back();
      Get.snackbar('Berhasil', 'Profil berhasil diperbarui');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Gagal', 'Gagal memperbarui profil');
      if (kDebugMode) {
        logger.e('error $e');
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
    nameController.clear();
    phoneController.clear();
    nameController.dispose();
    phoneController.dispose();
    final controllerProfile = Get.find<ProfileController>();
    controllerProfile.getCurrentUser();
  }
}
