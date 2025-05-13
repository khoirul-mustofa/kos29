import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/review_model.dart';
import 'package:kos29/app/data/models/review_with_user_model.dart';
import 'package:kos29/app/services/user_service.dart';

class ReviewManagementController extends GetxController {
  final reviews = <ReviewWithUserModel>[].obs;
  final filteredReviews = <ReviewWithUserModel>[].obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();
  final selectedFilter = 'all'.obs;
  final selectedRating = 0.obs; 
  final _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    isLoading.value = true;
    


final userId = FirebaseAuth.instance.currentUser!.uid;

final query = await FirebaseFirestore.instance
    .collection('reviews')
    .where('ownerId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .get();

    final reviewsList =
        query.docs.map((doc) => ReviewModel.fromDoc(doc)).toList();

    // Fetch user data for each review
    final reviewsWithUser = await Future.wait(
      reviewsList.map((review) async {
        final user = await _userService.getUserById(review.userId);
        if (user == null) throw Exception('User tidak ditemukan');
        return ReviewWithUserModel(review: review, user: user);
      }),
    );

    reviews.clear();
    reviews.addAll(reviewsWithUser);
    filterReviews();
    isLoading.value = false;
  }

  void searchReviews(String query) {
    if (query.isEmpty) {
      filterReviews();
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered =
        reviews.where((reviewWithUser) {
          final comment = reviewWithUser.review.comment.toLowerCase();
          final response =
              reviewWithUser.review.ownerResponse?.toLowerCase() ?? '';
          final userName = reviewWithUser.user.name.toLowerCase();

          return comment.contains(lowercaseQuery) ||
              response.contains(lowercaseQuery) ||
              userName.contains(lowercaseQuery);
        }).toList();

    filteredReviews.clear();
    filteredReviews.addAll(filtered);
  }

  void filterReviews() {
    var filtered = reviews.toList(); // Convert RxList to List for filtering

    // Apply status filter
    switch (selectedFilter.value) {
      case 'hidden':
        filtered = filtered.where((r) => r.review.hidden == true).toList();
        break;
      case 'responded':
        filtered =
            filtered
                .where(
                  (r) =>
                      r.review.ownerResponse != null &&
                      r.review.ownerResponse!.isNotEmpty,
                )
                .toList();
        break;
      case 'unresponded':
        filtered =
            filtered
                .where(
                  (r) =>
                      r.review.ownerResponse == null ||
                      r.review.ownerResponse!.isEmpty,
                )
                .toList();
        break;
    }

    // Apply rating filter
    if (selectedRating.value > 0) {
      filtered =
          filtered
              .where((r) => r.review.rating == selectedRating.value)
              .toList();
    }

    filteredReviews.clear();
    filteredReviews.addAll(filtered);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    filterReviews();
  }

  void setRatingFilter(int rating) {
    selectedRating.value = rating;
    filterReviews();
  }

  Future<void> setReviewHidden(String reviewId, bool hidden) async {
    await FirebaseFirestore.instance.collection('reviews').doc(reviewId).update(
      {'hidden': hidden},
    );
    fetchReviews();
  }

  Future<void> respondToReview(String reviewId, String response) async {
    await FirebaseFirestore.instance.collection('reviews').doc(reviewId).update(
      {'ownerResponse': response},
    );
    fetchReviews();
  }

  void showResponseDialog(ReviewWithUserModel reviewWithUser) {
    final controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Balas Ulasan'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Tulis balasan...'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await respondToReview(reviewWithUser.review.id!, controller.text);
              Get.back();
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
