import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/data/models/review_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kos29/app/services/review_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPageController extends GetxController {
  final KostModel dataKost = Get.arguments;
  final _reviewService = ReviewService(); // Service untuk mengelola ulasan

  var isFasilitasExpanded = false;
  var isDeskripsiExpanded = false;
  String ratingLabel(double rating) {
    switch (rating.round()) {
      case 1:
        return 'Buruk';
      case 2:
        return 'Lumayan';
      case 3:
        return 'Bagus';
      case 4:
        return 'Sangat Bagus';
      case 5:
        return 'Luar Biasa';
      default:
        return '';
    }
  }

  String ratingEmoji(double rating) {
    switch (rating.round()) {
      case 1:
        return '😠';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😍';
      default:
        return '';
    }
  }

  void toggleiExpanded(String section) {
    if (section == 'fasilitas') {
      isFasilitasExpanded = !isFasilitasExpanded;
    } else if (section == 'deskripsi') {
      isDeskripsiExpanded = !isDeskripsiExpanded;
    }
    update();
  }

  Future<List<ReviewModel>> getReviews(String kostId) async {
    log('getReviews $kostId');
    return await _reviewService.getReviews(kostId);
  }

  Future<void> showReviewDialog(BuildContext context) async {
    final TextEditingController commentController = TextEditingController();
    double selectedRating = 5;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: const Text(
                    'Tulis Ulasan Kost & Bintang',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            labelText: 'Komentar',
                            hintText: 'Tulis ulasan Anda...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),
                        RatingBar.builder(
                          initialRating: selectedRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                          ),
                          itemBuilder:
                              (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              selectedRating = rating;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (child, animation) => FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                          child: Text(
                            '${ratingLabel(selectedRating)} ${ratingEmoji(selectedRating)}',
                            key: ValueKey(selectedRating),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Kirim'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final review = ReviewModel(
                            userId: user.uid,
                            kostId: dataKost.idKos,
                            comment: commentController.text,
                            rating: selectedRating,
                            timestamp: DateTime.now(),
                            hidden: false,
                            ownerResponse: null,
                          );
                          await _reviewService.submitReview(review);
                          update();
                        }
                        Get.back();
                      },
                    ),
                  ],
                ),
          ),
    );
  }

  void launchMapOnAndroid(BuildContext context, double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka Maps')));
    }
  }
}
