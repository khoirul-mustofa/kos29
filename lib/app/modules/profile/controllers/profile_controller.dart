import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/history_search/controllers/history_search_controller.dart';
import 'package:kos29/app/modules/home/controllers/home_controller.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:kos29/app/services/visit_history_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileController extends GetxController {
  User? currentUser;
  Map<String, dynamic>? userData;
  var appVersion = '';
  var isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
    loadAppVersion();
  }

  void loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion = '${info.version} (${info.buildNumber})';
    update();
  }

  getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      getUserData();
    }
  }

  Future<void> getUserData() async {
    try {
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .get();
        if (userDoc.exists) {
          userData = userDoc.data() as Map<String, dynamic>;
          // Check if user is admin
          isAdmin.value = userData?['role'] == 'admin';
          update();
        }
        update();
      }
    } catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      Get.offAllNamed(Routes.BOTTOM_NAV);
    } catch (e) {
      logger.e(e.toString());
      Get.snackbar('Error', 'Failed to log out: $e');
    }
  }

  void clearHistory() {
    Get.defaultDialog(
      title: 'Hapus Riwayat',
      middleText: 'Apakah kamu yakin ingin menghapus semua riwayat Kunjungan?',
      textCancel: 'Tidak',
      textConfirm: 'Ya',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();

        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        final stopwatch = Stopwatch()..start();

        try {
          VisitHistoryService().clearHistory();

          final controllerHome = Get.find<HomeController>();
          controllerHome.refreshHomePage();

          final controllerHistorySearch = Get.find<HistorySearchController>();
          controllerHistorySearch.getHistorySearch();
        } catch (e) {
          Get.back();
          Get.snackbar('Error', 'Terjadi kesalahan saat menghapus riwayat');
          return;
        }

        final elapsed = stopwatch.elapsedMilliseconds;
        if (elapsed < 500) {
          await Future.delayed(Duration(milliseconds: 500 - elapsed));
        }

        Get.back();
        Get.snackbar('Success', 'Riwayat berhasil dihapus');
      },
    );
  }
}
