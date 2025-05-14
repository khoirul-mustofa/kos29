import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/data/models/review_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kos29/app/data/models/review_with_user_model.dart';
import 'package:kos29/app/data/models/user_model.dart';
import 'package:kos29/app/modules/home/controllers/home_controller.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:kos29/app/services/review_service.dart';
import 'package:kos29/app/services/user_service.dart';
import 'package:kos29/app/services/visit_history_service.dart';
import 'package:kos29/app/services/favorite_service.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPageController extends GetxController {
  final _reviewService = ReviewService();
  final _userService = UserService();
  final _favoriteService = FavoriteService();
  final jumlahUlasan = 0.obs;
  final rataRating = 0.0.obs;
  final isLoading = false.obs;
  final isFavorite = false.obs;
  final KostModel dataKost = Get.arguments;
final Rxn<UserModel> owner = Rxn<UserModel>();
  var isFasilitasExpanded = false;
  var isDeskripsiExpanded = false;

  String ratingLabel(double rating) {
    switch (rating.round()) {
      case 1:
        return 'bad'.tr;
      case 2:
        return 'okay'.tr;
      case 3:
        return 'good'.tr;
      case 4:
        return 'very_good'.tr;
      case 5:
        return 'excellent'.tr;
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

  Future<void> calculateRating() async {
    final reviewsSnapshot =
        await FirebaseFirestore.instance
            .collection('reviews')
            .where('kostId', isEqualTo: dataKost.idKos)
            .get();

    final reviews = reviewsSnapshot.docs.map((doc) => doc.data()).toList();

    if (reviews.isEmpty) {
      jumlahUlasan.value = 0;
      rataRating.value = 0.0;
      return;
    }

    final totalRating = reviews.fold<double>(
      0.0,
      (jumlah, review) => jumlah + (review['rating'] as num).toDouble(),
    );

    jumlahUlasan.value = reviews.length;
    rataRating.value =
        jumlahUlasan.value == 0 ? 0.0 : totalRating / jumlahUlasan.value;
  }

  @override
  void onInit() {
    super.onInit();
    VisitHistoryService().saveVisit(dataKost.idKos);
    Get.find<HomeController>().refreshHomePage();
    getReviewsWithUser(dataKost.idKos);
    calculateRating();
    checkFavoriteStatus();
     _loadOwnerData();
  }

Future<void> _loadOwnerData() async {
    try {
      final ownerData = await _userService.getUserById(dataKost.uid);
      if (ownerData != null) {
        owner.value = ownerData;
      }
    } catch (e) {
      logger.e('Error loading owner data: $e');
    }
  }
  Future<void> checkFavoriteStatus() async {
    try {
      isFavorite.value = await _favoriteService.isFavorite(dataKost.idKos);
    } catch (e) {
      logger.e('Error checking favorite status: $e');
    }
  }

  Future<void> toggleFavorite() async {
    try {
      if (isFavorite.value) {
        await _favoriteService.removeFavorite(dataKost.idKos);
        isFavorite.value = false;
        Get.snackbar(
          'Success',
          'favorite_remove_success'.tr,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        await _favoriteService.addFavorite(dataKost.idKos);
        isFavorite.value = true;
        if (kDebugMode) {
          logger.i('Favorite added');
        }
      }
    } catch (e) {
      Get.snackbar(
        'favorite_error'.tr,
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
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
    return await _reviewService.getReviews(kostId);
  }

  Future<List<ReviewWithUserModel>> getReviewsWithUser(String kostId) async {
    final reviews = await _reviewService.getReviews(kostId);
    final usersFutures =
        reviews.map((r) => _userService.getUserById(r.userId)).toList();
    final users = await Future.wait(usersFutures);

    return List.generate(reviews.length, (i) {
      final user = users[i];
      if (user == null) throw Exception('User tidak ditemukan');
      return ReviewWithUserModel(review: reviews[i], user: user);
    });
  }

  Future<void> showReviewDialog(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser == null) {
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Belum Login'),
              content: const Text(
                'Silakan login terlebih dahulu untuk menuliskan review',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.offAllNamed(Routes.SIGN_IN),
                  child: const Text('Login'),
                ),
              ],
            ),
      );
      return;
    }

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
                  title: Text(
                    'write_review_kost_and_star'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            labelText: 'comment'.tr,
                            hintText: 'write_your_review'.tr,
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
                      child: Text(
                        'cancel'.tr,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: Text('send'.tr),
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
                            createdAt: DateTime.now(),
                            hidden: false,
                            ownerResponse: null,
                            ownerId: dataKost.uid
                          );
                          await _reviewService.submitReview(review);
                          update();
                          calculateRating();
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
    if (await launchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
      );
    }
  }
}
