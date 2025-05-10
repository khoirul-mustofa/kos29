import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/review_management_controller.dart';

class ReviewManagementView extends GetView<ReviewManagementController> {
  const ReviewManagementView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Ulasan')),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari ulasan atau nama pengguna...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchReviews('');
                      },
                    ),
                  ),
                  onChanged: controller.searchReviews,
                ),
                const SizedBox(height: 12),
                // Rating Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRatingChip('Semua Rating', 0),
                      _buildRatingChip('⭐ 1', 1),
                      _buildRatingChip('⭐⭐ 2', 2),
                      _buildRatingChip('⭐⭐⭐ 3', 3),
                      _buildRatingChip('⭐⭐⭐⭐ 4', 4),
                      _buildRatingChip('⭐⭐⭐⭐⭐ 5', 5),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Status Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'all'),
                      _buildFilterChip('Tersembunyi', 'hidden'),
                      _buildFilterChip('Sudah Dibalas', 'responded'),
                      _buildFilterChip('Belum Dibalas', 'unresponded'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reviews List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredReviews.isEmpty) {
                return const Center(
                  child: Text('Tidak ada ulasan yang ditemukan.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredReviews.length,
                itemBuilder: (context, index) {
                  final reviewWithUser = controller.filteredReviews[index];
                  return Card(
                    color:
                        reviewWithUser.review.hidden
                            ? Colors.grey[200]
                            : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    reviewWithUser.user.photoUrl != null
                                        ? NetworkImage(
                                          reviewWithUser.user.photoUrl!,
                                        )
                                        : null,
                                child:
                                    reviewWithUser.user.photoUrl == null
                                        ? const Icon(Icons.person)
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reviewWithUser.user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${'⭐' * reviewWithUser.review.rating.toInt()} (${reviewWithUser.review.rating})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(reviewWithUser.review.comment),
                          if (reviewWithUser.review.ownerResponse != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Balasan: ${reviewWithUser.review.ownerResponse!}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!reviewWithUser.review.hidden)
                                TextButton.icon(
                                  icon: const Icon(Icons.visibility_off),
                                  onPressed:
                                      () => controller.setReviewHidden(
                                        reviewWithUser.review.id!,
                                        true,
                                      ),
                                  label: const Text('Sembunyikan'),
                                ),
                              if (reviewWithUser.review.hidden)
                                TextButton.icon(
                                  icon: const Icon(Icons.visibility),
                                  onPressed:
                                      () => controller.setReviewHidden(
                                        reviewWithUser.review.id!,
                                        false,
                                      ),
                                  label: const Text('Tampilkan'),
                                ),
                              TextButton.icon(
                                icon: const Icon(Icons.reply),
                                onPressed:
                                    () => controller.showResponseDialog(
                                      reviewWithUser,
                                    ),
                                label: const Text('Balas'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Obx(
        () => FilterChip(
          label: Text(label),
          selected: controller.selectedFilter.value == value,
          onSelected: (selected) {
            if (selected) {
              controller.setFilter(value);
            }
          },
          selectedColor: Colors.teal.withOpacity(0.2),
          checkmarkColor: Colors.teal,
          labelStyle: TextStyle(
            color:
                controller.selectedFilter.value == value
                    ? Colors.teal
                    : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingChip(String label, int rating) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Obx(
        () => FilterChip(
          label: Text(label),
          selected: controller.selectedRating.value == rating,
          onSelected: (selected) {
            if (selected) {
              controller.setRatingFilter(rating);
            }
          },
          selectedColor: Colors.teal.withOpacity(0.2),
          checkmarkColor: Colors.teal,
          labelStyle: TextStyle(
            color:
                controller.selectedRating.value == rating
                    ? Colors.teal
                    : Colors.black87,
          ),
        ),
      ),
    );
  }
}
