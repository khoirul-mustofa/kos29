import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/review_model.dart';

class ReviewManagementController extends GetxController {
  final reviews = <ReviewModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    isLoading.value = true;
    final query =
        await FirebaseFirestore.instance
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .get();

    reviews.value = query.docs.map((doc) => ReviewModel.fromDoc(doc)).toList();
    isLoading.value = false;
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

  void showResponseDialog(ReviewModel review) {
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
              await respondToReview(review.id!, controller.text);
              Get.back();
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }
}
