import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kos29/app/data/models/review_model.dart';

class ReviewService {
  final _reviewCollection = FirebaseFirestore.instance.collection('reviews');

  /// Submit ulasan
  Future<void> submitReview(ReviewModel review) async {
    await _reviewCollection.add(review.toJson());
  }

  Future<List<ReviewModel>> getReviews(String kostId) async {
    final snapshot =
        await _reviewCollection
            .where('kostId', isEqualTo: kostId)
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromJson(doc.data()))
        .toList();
  }
}
