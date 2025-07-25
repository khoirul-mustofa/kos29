import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/formater_helper.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:kos29/app/services/haversine_service.dart';

import 'package:kos29/app/style/app_colors.dart';
import 'package:kos29/app/services/notification_service.dart';

import 'package:shimmer/shimmer.dart';
import 'package:kos29/app/data/models/kost_model.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  @override
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading:
            controller.prfController.currentUser.value != null
                ? Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 5),
                    width: 40,
                    height: 40,
                    child: CircleAvatar(
                      radius: 30,
                      child: CachedNetworkImage(
                        imageUrl:
                            '${controller.prfController.currentUser.value?.photoURL}',
                        imageBuilder:
                            (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        placeholder:
                            (context, url) =>
                                const CircularProgressIndicator(strokeWidth: 2),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.person),
                      ),
                    ),
                  ),
                )
                : null,
        title: Text(
          'Kos29',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
                icon: Icon(Icons.notifications_outlined),
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
              // Obx(() {
              //   final unreadCount = Get.find<NotificationService>().unreadCount.value;
              //   if (unreadCount == 0) return const SizedBox.shrink();
              //   return Positioned(
              //     right: 0,
              //     top: 0,
              //     child: Container(
              //       padding: const EdgeInsets.all(4),
              //       decoration: BoxDecoration(
              //         color: Colors.red,
              //         shape: BoxShape.circle,
              //       ),
              //       constraints: const BoxConstraints(
              //         minWidth: 16,
              //         minHeight: 16,
              //       ),
              //       child: Text(
              //         unreadCount > 9 ? '9+' : unreadCount.toString(),
              //         style: const TextStyle(
              //           color: Colors.white,
              //           fontSize: 10,
              //           fontWeight: FontWeight.bold,
              //         ),
              //         textAlign: TextAlign.center,
              //       ),
              //     ),
              //   );
              // }),
            ],
          ),
          IconButton(
            onPressed: () {
              controller.showLanguageDialog(context);
            },
            icon: Icon(Icons.language),
            constraints: BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),

          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshHomePage();
          },
          child: SingleChildScrollView(
            controller: ScrollController(),
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    '${'hello'.tr} ${controller.prfController.currentUser.value?.displayName ?? ''} ${'home_welcome'.tr} 😎',
                    style: Get.textTheme.titleMedium!.copyWith(
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'home_search_title'.tr,
                    style: Get.textTheme.titleMedium,
                  ),
                  Text(
                    'home_search_sub'.tr,
                    textAlign: TextAlign.left,
                    style: Get.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.SEARCH_PAGE),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Get.theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Get.theme.iconTheme.color),
                          Text('home_search'.tr),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('home_categories'.tr, style: Get.textTheme.titleMedium),
                  SizedBox(height: 10),
                  // Kategori
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(4, (index) {
                        final List category = [
                          'home_nearby'.tr,
                          'home_cheapest'.tr,
                          'home_expensive'.tr,
                          'home_best'.tr,
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap:
                                    () => Get.toNamed(
                                      Routes.CATEGORY_PAGE,
                                      arguments: category[index],
                                    ),
                                child: Container(
                                  height: 64,
                                  width: 74,
                                  decoration: BoxDecoration(
                                    color:
                                        index == 0
                                            ? Colors.blue.shade50
                                            : index == 1
                                            ? Colors.green.shade50
                                            : index == 2
                                            ? Colors.red.shade50
                                            : Colors.yellow.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child:
                                        index == 0
                                            ? Icon(Icons.map_outlined)
                                            : index == 1
                                            ? Icon(
                                              Icons.arrow_downward_outlined,
                                            )
                                            : index == 2
                                            ? Icon(Icons.arrow_upward_outlined)
                                            : Icon(Icons.percent),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                category[index],
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildKunjunganTerakhir(),
                  SizedBox(height: 10),
                  Text('home_recommended'.tr, style: Get.textTheme.titleMedium),
                  SizedBox(height: 10),
                  _buildRekomendasiList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKunjunganTerakhir() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('home_last_visit'.tr, style: Get.textTheme.titleMedium),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.isLoading.value) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
          final kunjungan = controller.kunjunganTerakhir.value;
          if (kunjungan == null) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Anda belum pernah melakukan kunjungan kos dimanapun.',
                  style: Get.textTheme.bodyMedium,
                ),
              ),
            );
          }
          return buildKunjunganCard(kunjungan);
        }),
      ],
    );
  }

  Widget _buildRekomendasiList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      if (controller.rekomendasiKosts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Tidak ada rekomendasi kost terdekat.',
              style: Get.textTheme.bodyMedium,
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.rekomendasiKosts.length,
        itemBuilder: (context, index) {
          final kost = controller.rekomendasiKosts[index];
          return buildKostCard(kost);
        },
      );
    });
  }
}

Widget buildKunjunganCard(KostModel kunjungan) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
    shadowColor: Colors.grey.withValues(alpha: 0.2),
    elevation: 4,
    child: InkWell(
      onTap: () => Get.toNamed(Routes.DETAIL_PAGE, arguments: kunjungan),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          SizedBox(width: 5),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: CachedNetworkImage(
              imageUrl:
                  kunjungan.fotoKosUrls.isNotEmpty
                      ? kunjungan.fotoKosUrls[0]
                      : '',
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    width: 100,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    width: 100,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kunjungan.namaKos,
                    style: Get.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          kunjungan.alamat,
                          style: Get.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.money, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          FormatterHelper.formatHarga(kunjungan.harga),
                          style: Get.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

Widget buildKostCard(KostModel kost) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Material(
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Get.toNamed(Routes.DETAIL_PAGE, arguments: kost),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.appGreyAlpa50),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  kost.fotoKosUrls.isNotEmpty ? kost.fotoKosUrls[0] : '',
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kost.namaKos, style: Get.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        FormatterHelper.formatHarga(kost.harga),
                        style: Get.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          kost.jenis,
                          style: Get.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<double?>(
                    future: calculateDistanceFromCurrentLocation(
                      kost.latitude!,
                      kost.longitude!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 20,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final distance = snapshot.data;
                      if (distance == null) {
                        return Row(
                          children: [
                            const Icon(
                              Icons.location_off,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lokasi tidak tersedia',
                              style: Get.textTheme.bodyMedium!.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(2)} km',
                            style: Get.textTheme.bodyMedium!.copyWith(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'distance_from_your_location'.tr,
                            style: Get.textTheme.bodyMedium,
                          ),
                        ],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 10),
                    child: Text(
                      kost.alamat,
                      style: Get.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
