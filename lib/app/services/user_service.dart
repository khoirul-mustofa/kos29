import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kos29/app/data/models/user_model.dart';
import 'package:kos29/app/helper/logger_app.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
    } catch (e) {
      logger.e('Gagal mengambil user: $e');
    }
    return null;
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final firestoreData = doc.data()!;

        return UserModel(
          uid: user.uid,
          name: firestoreData['displayName'] ?? user.displayName ?? 'Pengguna',
          email: user.email ?? firestoreData['email'] ?? '',
          photoUrl: firestoreData['photo_url'] ?? user.photoURL,
        );
      }
    } catch (e) {
      logger.e('Gagal mengambil user login: $e');
    }

    return UserModel(
      uid: user.uid,
      name: user.displayName ?? 'Pengguna',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }
}
