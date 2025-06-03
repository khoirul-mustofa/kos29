import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/review_with_user_model.dart';
import 'package:kos29/app/helper/formater_helper.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../controllers/detail_page_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailPageView extends GetView<DetailPageController> {
  DetailPageView({super.key});
  final controller = Get.put(DetailPageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () => controller.showReviewDialog(context),
            icon: const Icon(Icons.rate_review),
            label: const Text('Beri Ulasan'),
            heroTag: 'review',
          ),
        ],
      ),
      body: GetBuilder<DetailPageController>(
        builder: (controller) {
          return Obx(() {
            if (controller.isLoading.value) {
              return _buildShimmerLoading();
            }
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeaderImage(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleSection(),
                          const SizedBox(height: 12),
                          _buildLocationSection(context),
                          const SizedBox(height: 8),
                          _buildDistanceInfo(),
                          const SizedBox(height: 12),
                          _buildRatingAndAvailability(),
                          const SizedBox(height: 12),
                          _buildPriceSection(),
                          const SizedBox(height: 16),
                          Obx(
                            () =>
                                controller.owner.value != null
                                    ? ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      tileColor: Colors.grey[100],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            controller.owner.value?.photoUrl !=
                                                    null
                                                ? NetworkImage(
                                                  controller
                                                      .owner
                                                      .value!
                                                      .photoUrl!,
                                                )
                                                : null,
                                        child:
                                            controller.owner.value?.photoUrl ==
                                                    null
                                                ? const Icon(Icons.person)
                                                : null,
                                      ),
                                      title: Text(
                                        controller.owner.value?.name ??
                                            'Unknown',
                                      ),
                                      subtitle: Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(controller.dataKost.nomorHp),
                                        ],
                                      ),
                                      trailing: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            onTap: controller.launchWhatsApp,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.chat,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'chat'.tr,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 16),
                          _buildExpandableSection(
                            'fasilitas'.tr,
                            'fasilitas',
                            controller.dataKost.fasilitas,
                          ),
                          _buildExpandableSection('deskripsi'.tr, 'deskripsi', [
                            controller.dataKost.deskripsi,
                          ]),
                          const SizedBox(height: 24),
                          _buildReviewSection(context),
                          // Add extra padding at the bottom to account for the FAB
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Header Image Shimmer
          Container(height: 250, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Shimmer
                Container(
                  width: double.infinity,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                // Location Section Shimmer
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                // Distance Info Shimmer
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                // Rating and Availability Shimmer
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 120,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Price Section Shimmer
                Container(
                  width: 150,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                // Fasilitas Section Shimmer
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                // Deskripsi Section Shimmer
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 24),
                // Review Section Shimmer
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  '${initialIndex + 1}/${images.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              body: CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1.0,
                  initialPage: initialIndex,
                  enableInfiniteScroll: images.length > 1,
                  onPageChanged: (index, reason) {
                    // Update the app bar title with current image number
                    Navigator.of(context).pop();
                    _showFullScreenImage(context, images, index);
                  },
                ),
                items:
                    images.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Center(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Failed to load image',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
            ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    // Create a list of images, using the main gambar if fotoKosUrls is empty
    final List<String> images =
        controller.dataKost.fotoKosUrls.isNotEmpty
            ? controller.dataKost.fotoKosUrls
            : [controller.dataKost.gambar];

    // Filter out any empty or null image URLs
    final validImages = images.where((url) => url.isNotEmpty).toList();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 250,
              viewportFraction: 1.0,
              enableInfiniteScroll: validImages.length > 1,
              autoPlay: validImages.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: (index, reason) {
                controller.currentImageIndex.value = index;
              },
            ),
            items:
                validImages.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap:
                            () => _showFullScreenImage(
                              context,
                              validImages,
                              controller.currentImageIndex.value,
                            ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder:
                              (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(color: Colors.white),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                        ),
                      );
                    },
                  );
                }).toList(),
          ),
        ),
        if (validImages.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Obx(
                () => Text(
                  '${controller.currentImageIndex.value + 1}/${validImages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 16,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        if (FirebaseAuth.instance.currentUser != null)
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: Obx(
                () => IconButton(
                  icon: Icon(
                    controller.isFavorite.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        controller.isFavorite.value ? Colors.red : Colors.white,
                  ),
                  onPressed: controller.toggleFavorite,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Text(
      controller.dataKost.nama,
      style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              controller.launchMapOnAndroid(
                context,
                controller.dataKost.latitude ?? 0,
                controller.dataKost.longitude ?? 0,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      controller.dataKost.alamat,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'tap_alamat_for_visit'.tr,
          style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDistanceInfo() {
    return Row(
      children: [
        Text(
          '${controller.dataKost.distance.toStringAsFixed(2)} km',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'distance_from_your_location'.tr,
          style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRatingAndAvailability() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                Get.isDarkMode ? Colors.grey.shade800 : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(() {
            return Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${controller.rataRating.value.toStringAsFixed(1)} | ${controller.jumlahUlasan.value} ulasan',
                ),
              ],
            );
          }),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.check_circle, color: Colors.green, size: 18),
        const SizedBox(width: 4),
        Text('room_available'.tr),
      ],
    );
  }

  Widget _buildPriceSection() {
    return RichText(
      text: TextSpan(
        text: FormatterHelper.formatHarga(controller.dataKost.harga),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.green,
          fontFamily: 'NotoSans',
        ),
        children: [
          TextSpan(
            text: ' /${'month'.tr}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String title, String key, List<String> items) {
    final isExpanded =
        key == 'fasilitas'
            ? controller.isFasilitasExpanded
            : controller.isDeskripsiExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DottedLine(
                dashColor: Colors.teal.shade700,
                lineThickness: 1.5,
                dashLength: 6,
                dashGapLength: 4,
              ),
            ),

            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: () => controller.toggleiExpanded(key),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? 'sembunyikan'.tr : 'lihat_semua'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.teal.shade800,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
        ...items
            .take(isExpanded ? items.length : 3)
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (key == 'fasilitas') ...[
                      Container(
                        margin: const EdgeInsets.only(top: 8, right: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade800,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        e,
                        style: Get.textTheme.bodyMedium,
                        maxLines: isExpanded ? null : 1,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ulasan'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.reviews.isEmpty) {
            return Text("no_review".tr, style: Get.textTheme.bodySmall);
          }

          return Column(
            children:
                controller.reviews.map((rwu) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    rwu.user.photoUrl != null
                                        ? NetworkImage(rwu.user.photoUrl!)
                                        : null,
                                child:
                                    rwu.user.photoUrl == null
                                        ? const Icon(Icons.person, size: 20)
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            rwu.user.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${rwu.review.rating} ★',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      FormatterHelper.formatDate(
                                        rwu.review.createdAt,
                                      ),
                                      style: Get.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rwu.review.comment,
                            style: Get.textTheme.bodyMedium,
                          ),
                          if (rwu.review.ownerResponse != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "owner_response".tr,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    rwu.review.ownerResponse!,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
          );
        }),
        const SizedBox(height: 80), // Extra padding for FAB
      ],
    );
  }
}
