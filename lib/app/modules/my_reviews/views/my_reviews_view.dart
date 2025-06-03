import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/modules/my_reviews/controllers/my_reviews_controller.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:intl/intl.dart';

class MyReviewsView extends GetView<MyReviewsController> {
  const MyReviewsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Reviews'.tr),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reviewsByKost.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined, 
                  size: 64, 
                  color: Colors.grey[400]
                ),
                const SizedBox(height: 16),
                Text(
                  'No reviews yet'.tr,
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyReviews,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.reviewsByKost.length,
            itemBuilder: (context, index) {
              final kostId = controller.reviewsByKost.keys.elementAt(index);
              final reviews = controller.reviewsByKost[kostId]!;
              final kost = controller.kostData[kostId];

              if (kost == null) return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kost header
                    ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        kost.nama,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        kost.alamat,
                        style: Get.textTheme.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: () => Get.toNamed(
                          Routes.DETAIL_PAGE,
                          arguments: kost,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Reviews list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, reviewIndex) {
                        final review = reviews[reviewIndex];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: review.user.photoUrl != null
                                        ? NetworkImage(review.user.photoUrl!)
                                        : null,
                                    child: review.user.photoUrl == null
                                        ? Text(
                                            review.user.name[0].toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.user.name,
                                          style: Get.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy, HH:mm')
                                              .format(review.review.createdAt),
                                          style: Get.textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        review.review.rating.toString(),
                                        style: Get.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (review.review.comment.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  review.review.comment,
                                  style: Get.textTheme.bodyMedium,
                                ),
                              ],
                              if (review.review.ownerResponse != null &&
                                  review.review.ownerResponse!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Owner Response'.tr,
                                        style: Get.textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        review.review.ownerResponse!,
                                        style: Get.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (reviewIndex < reviews.length - 1)
                                const Divider(height: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
} 