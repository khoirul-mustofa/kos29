import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  User? currentUser;
  Map<String, dynamic>? userData;

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
  }

  getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      getUserData();
    }
  }

  // Method to get user data from Firestore
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
}
