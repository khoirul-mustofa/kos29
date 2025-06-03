import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/data/models/review_model.dart';
import 'package:kos29/app/data/models/review_with_user_model.dart';
import 'package:kos29/app/services/user_service.dart';

class MyReviewsController extends GetxController {
  final _userService = UserService();
  final reviewsByKost = <String, List<ReviewWithUserModel>>{}.obs;
  final kostData = <String, KostModel>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyReviews();
  }

  Future<void> fetchMyReviews() async {
    try {
      isLoading.value = true;
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch all reviews by the user
      final reviewsQuery = await FirebaseFirestore.instance
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final reviewsList = reviewsQuery.docs.map((doc) => ReviewModel.fromDoc(doc)).toList();

      // Group reviews by kostId
      final groupedReviews = <String, List<ReviewModel>>{};
      for (var review in reviewsList) {
        if (!groupedReviews.containsKey(review.kostId)) {
          groupedReviews[review.kostId] = [];
        }
        groupedReviews[review.kostId]!.add(review);
      }

      // Fetch kost data for each kostId
      for (var kostId in groupedReviews.keys) {
        final kostDoc = await FirebaseFirestore.instance
            .collection('kosts')
            .doc(kostId)
            .get();
        
        if (kostDoc.exists) {
          kostData[kostId] = KostModel.fromMap({
            'idKos': kostDoc.id,
            ...kostDoc.data()!
          });
        }
      }

      // Fetch user data for each review and create ReviewWithUserModel
      final reviewsByKostTemp = <String, List<ReviewWithUserModel>>{};
      for (var entry in groupedReviews.entries) {
        final kostId = entry.key;
        final reviews = entry.value;
        
        final reviewsWithUser = <ReviewWithUserModel>[];
        for (var review in reviews) {
          final user = await _userService.getUserById(review.userId);
          if (user != null) {
            reviewsWithUser.add(ReviewWithUserModel(review: review, user: user));
          }
        }
        
        if (reviewsWithUser.isNotEmpty) {
          reviewsByKostTemp[kostId] = reviewsWithUser;
        }
      }

      reviewsByKost.value = reviewsByKostTemp;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load reviews: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 