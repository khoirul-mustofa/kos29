import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../helper/logger_app.dart';

class SignInController extends GetxController {
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      log(userCredential.user.toString());

      if (userCredential.user != null) {
        final DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'displayName': userCredential.user!.displayName,
                'email': userCredential.user!.email,
                'photo_url': userCredential.user!.photoURL,
                'role': 'user',
                'created_at': DateTime.now(),
                'updated_at': DateTime.now(),
              });
        }
      }
      return userCredential.user;
    } catch (e) {
      logger.e(e.toString());
      Get.snackbar('Login Failed', 'Error: $e');
    }
    return null;
  }
}
