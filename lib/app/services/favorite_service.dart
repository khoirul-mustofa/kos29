import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kos29/app/data/models/favorite_model.dart';
import 'package:kos29/app/helper/logger_app.dart';

class FavoriteService {
  final _favoriteCollection = FirebaseFirestore.instance.collection(
    'favorites',
  );
  final _auth = FirebaseAuth.instance;

  Future<void> addFavorite(String kostId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Check if already favorited
      final existingFavorite =
          await _favoriteCollection
              .where('kost_id', isEqualTo: kostId)
              .where('uid', isEqualTo: userId)
              .get();

      if (existingFavorite.docs.isNotEmpty) {
        throw Exception('Kost already in favorites');
      }

      await _favoriteCollection.add(
        FavoriteModel(
          kostId: kostId,
          uid: userId,
          createdAt: DateTime.now(),
        ).toJson(),
      );
    } catch (e) {
      logger.e('Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String kostId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final favoriteDoc =
          await _favoriteCollection
              .where('kost_id', isEqualTo: kostId)
              .where('uid', isEqualTo: userId)
              .get();

      if (favoriteDoc.docs.isEmpty) {
        throw Exception('Favorite not found');
      }

      await favoriteDoc.docs.first.reference.delete();
    } catch (e) {
      logger.e('Error removing favorite: $e');
      rethrow;
    }
  }

  Future<bool> isFavorite(String kostId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final favoriteDoc =
          await _favoriteCollection
              .where('kost_id', isEqualTo: kostId)
              .where('uid', isEqualTo: userId)
              .get();

      return favoriteDoc.docs.isNotEmpty;
    } catch (e) {
      logger.e('Error checking favorite status: $e');
      return false;
    }
  }

  Future<List<FavoriteModel>> getUserFavorites() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot =
          await _favoriteCollection
              .where('uid', isEqualTo: userId)
              .orderBy('created_at', descending: true)
              .get();

      return snapshot.docs.map((doc) => FavoriteModel.fromDoc(doc)).toList();
    } catch (e) {
      logger.e('Error getting user favorites: $e');
      return [];
    }
  }
}
