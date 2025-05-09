import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kos29/app/data/models/review_model.dart';
import 'package:kos29/app/helper/logger_app.dart';

class ReviewService {
  final _reviewCollection = FirebaseFirestore.instance.collection('reviews');

  /// Submit ulasan
  Future<void> submitReview(ReviewModel review) async {
    await _reviewCollection.add(review.toJson());
  }

  Future<List<ReviewModel>> getReviews(String kostId) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('reviews')
              .where('kostId', isEqualTo: kostId)
              .where('hidden', isEqualTo: false)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => ReviewModel.fromDoc(doc)).toList();
    } catch (e) {
      logger.e('Gagal memuat ulasan: $e');
      return [];
    }
  }
}
