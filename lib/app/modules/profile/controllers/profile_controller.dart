import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kos29/app/modules/history_search/controllers/history_search_controller.dart';
import 'package:kos29/app/modules/home/controllers/home_controller.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:kos29/app/services/visit_history_service.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/services/kost_update_request_service.dart';

class ProfileController extends GetxController {
  final currentUser = Rx<User?>(null);
  final userData = Rxn<Map<String, dynamic>>();
  final userRole = ''.obs;
  final pendingUpdateRequestsCount = 0.obs;
  final pendingKosRegistrationsCount = 0.obs;
  final _requestService = KostUpdateRequestService();
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _pendingRequestsSubscription;
  StreamSubscription? _pendingRegistrationsSubscription;

  // For notification badge
  final RxInt unreadNotificationCount = 0.obs;
  StreamSubscription<int>? _notificationSubscription;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = FirebaseAuth.instance.currentUser;
    if (currentUser.value != null) {
      loadUserData();
    }
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    _pendingRequestsSubscription?.cancel();
    _pendingRegistrationsSubscription?.cancel();
    super.onClose();
  }

  void startListeningToPendingRequests() {
    if (userRole.value == 'admin') {
      // Listen to update requests
      _pendingRequestsSubscription?.cancel();
      _pendingRequestsSubscription = _requestService
          .getPendingUpdateRequests()
          .listen(
            (requests) {
              pendingUpdateRequestsCount.value = requests.length;
            },
            onError: (error) {
              logger.e('Error listening to pending requests: $error');
            },
          );

      // Listen to kos registrations
      _pendingRegistrationsSubscription?.cancel();
      _pendingRegistrationsSubscription = _firestore
          .collection('kos_registrations')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen(
            (snapshot) {
              pendingKosRegistrationsCount.value = snapshot.docs.length;
            },
            onError: (error) {
              logger.e('Error listening to pending registrations: $error');
            },
          );
    }
  }

  Future<void> loadUserData() async {
    try {
      if (currentUser.value != null) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.value?.uid)
                .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          userData.value = data;
          userRole.value = data['role'] ?? 'user';

          // Start listening to pending requests if user is admin
          if (userRole.value == 'admin') {
            startListeningToPendingRequests();
          }

          update();
        }
      }
    } catch (e) {
      logger.e('Error loading user data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data pengguna',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signOut() async {
    try {
      _pendingRequestsSubscription?.cancel();
      _notificationSubscription?.cancel();
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      Get.offAllNamed(Routes.BOTTOM_NAV);
    } catch (e) {
      logger.e('Error signing out: $e');
      Get.snackbar(
        'Error',
        'Gagal keluar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
          await VisitHistoryService().clearHistory();

          final controllerHome = Get.find<HomeController>();
          controllerHome.refreshHomePage();

          final controllerHistorySearch = Get.find<HistorySearchController>();
          controllerHistorySearch.getHistorySearch();
        } catch (e) {
          Get.back();
          Get.snackbar(
            'Error',
            'Terjadi kesalahan saat menghapus riwayat',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final elapsed = stopwatch.elapsedMilliseconds;
        if (elapsed < 500) {
          await Future.delayed(Duration(milliseconds: 500 - elapsed));
        }

        Get.back();
        Get.snackbar(
          'Success',
          'Riwayat berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
