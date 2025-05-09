import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/formater_helper.dart';
import '../controllers/detail_page_controller.dart';

class DetailPageView extends GetView<DetailPageController> {
  const DetailPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton.icon(
        icon: const Icon(Icons.rate_review),
        label: const Text("Tulis Ulasan"),
        onPressed: () => controller.showReviewDialog(context),
      ),
      body: GetBuilder<DetailPageController>(
        builder: (_) {
          return SafeArea(
            child: ListView(
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
                      _buildExpandableSection(
                        'Fasilitas',
                        'fasilitas',
                        controller.dataKost.fasilitas,
                      ),
                      _buildExpandableSection('Deskripsi', 'deskripsi', [
                        controller.dataKost.deskripsi,
                      ]),
                      const SizedBox(height: 24),
                      _buildReviewSection(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          child: Image.network(
            controller.dataKost.gambar,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
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
                controller.dataKost.latitude,
                controller.dataKost.longitude,
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
          'Tap alamat untuk mengunjungi kos',
          style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDistanceInfo() {
    return RichText(
      text: TextSpan(
        text: '${controller.dataKost.distance.toStringAsFixed(2)} km',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.teal,
          fontSize: 12,
        ),
        children: const [
          TextSpan(
            text: ' dari lokasi Anda',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
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
          child: Row(
            children: const [
              Icon(Icons.star, size: 16, color: Colors.orange),
              SizedBox(width: 4),
              Text('4.5 | 100 ulasan'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.check_circle, color: Colors.green, size: 18),
        const SizedBox(width: 4),
        const Text('3 Kamar Tersedia'),
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
            text: ' /bulan',
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
            TextButton(
              onPressed: () => controller.toggleiExpanded(key),
              child: Text(
                isExpanded ? 'Sembunyikan' : 'Lihat semua',
                style: Get.textTheme.bodySmall?.copyWith(color: Colors.blue),
              ),
            ),
          ],
        ),
        ...items
            .take(isExpanded ? items.length : 3)
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  e,
                  style: Get.textTheme.bodySmall,
                  maxLines: isExpanded ? null : 1,
                  overflow: TextOverflow.ellipsis,
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
          'Ulasan',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder(
          future: controller.getReviews(controller.dataKost.idKos),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text("Belum ada ulasan.", style: Get.textTheme.bodySmall);
            }

            final reviews = snapshot.data!;
            return Column(
              children:
                  reviews.map((review) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 24,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${review.rating} ★',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  review.comment,
                                  style: Get.textTheme.bodySmall,
                                ),
                                Text(
                                  FormatterHelper.formatDate(review.timestamp),
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
                    );
                  }).toList(),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
