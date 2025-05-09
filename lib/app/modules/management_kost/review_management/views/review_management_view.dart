import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kos29/app/widgets/review_card_widget.dart';

import '../controllers/review_management_controller.dart';

class ReviewManagementView extends GetView<ReviewManagementController> {
  const ReviewManagementView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Ulasan')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reviews.isEmpty) {
          return const Center(child: Text('Belum ada ulasan.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.reviews.length,
          itemBuilder: (context, index) {
            final review = controller.reviews[index];
            return ReviewCard(
              review: review,
              onHide: () => controller.setReviewHidden(review.id!, true),
              onShow: () => controller.setReviewHidden(review.id!, false),
              onRespond: () => controller.showResponseDialog(review),
            );
          },
        );
      }),
    );
  }
}
