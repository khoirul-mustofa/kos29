import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kos29/app/helper/formater_helper.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:kos29/app/style/app_colors.dart';
import 'package:kos29/app/style/theme/theme_controller.dart';

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
            controller.prfController.currentUser != null
                ? Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 5),
                    width: 40,
                    height: 40,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        '${controller.prfController.currentUser?.photoURL}',
                      ),
                    ),
                  ),
                )
                : null,
        title: Text(
          'IndiKos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
            fontFamily: 'Varela',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(Routes.NOTIFICATION_PAGE);
            },
            icon: Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () {
              controller.showLanguageDialog(context);
            },
            icon: Icon(Icons.language),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GetBuilder<ThemeController>(
              init: Get.find<ThemeController>(),
              builder:
                  (themeController) => IconButton(
                    onPressed: themeController.toggleTheme,
                    icon: Icon(
                      themeController.theme == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  ),
            ),
          ),
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
              child: GetBuilder<HomeController>(
                builder: (controller) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text(
                          'Hey ${controller.prfController.currentUser?.displayName ?? 'kamu'} 😎',
                          style: Get.textTheme.titleMedium!.copyWith(
                            color: Colors.teal,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '#Dapatkan Kemudahan',
                          style: Get.textTheme.titleMedium,
                        ),
                        Text(
                          'Cari dan Temukan Kos Terdekat!',
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
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search),
                                Text('Cari kos dimana?'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(4, (index) {
                              final List category = [
                                'Terdekat',
                                'Termurah',
                                'Termahal',
                                'Terbaik',
                              ];

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
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
                                      child: Center(child: Icon(Icons.home)),
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
                        _buildKunjunganTerakhir(controller),
                        SizedBox(height: 10),
                        Text(
                          'Rekomendasi Terdekat',
                          style: Get.textTheme.titleMedium,
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          child: Row(
                            children: List.generate(controller.rekomendasiKosts.length, (
                              index,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Material(
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          Get.toNamed(
                                            Routes.DETAIL_PAGE,
                                            arguments:
                                                controller
                                                    .rekomendasiKosts[index],
                                          );
                                        },
                                        child: Container(
                                          width: Get.width * 0.5,
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.appGreyAlpa50,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image: CachedNetworkImageProvider(
                                                      controller
                                                          .rekomendasiKosts[index]
                                                          .gambar,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Nama kost
                                                  Text(
                                                    controller
                                                        .rekomendasiKosts[index]
                                                        .nama,
                                                    style:
                                                        Get
                                                            .textTheme
                                                            .titleMedium,
                                                  ),

                                                  const SizedBox(height: 6),

                                                  // Harga dan jenis kos
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        FormatterHelper.formatHarga(
                                                          controller
                                                              .rekomendasiKosts[index]
                                                              .harga,
                                                        ),
                                                        style:
                                                            Get
                                                                .textTheme
                                                                .titleSmall,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Get
                                                              .theme
                                                              .colorScheme
                                                              .primary
                                                              .withValues(
                                                                alpha: 0.2,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          controller
                                                              .rekomendasiKosts[index]
                                                              .jenis,
                                                          style:
                                                              Get
                                                                  .textTheme
                                                                  .titleSmall,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 8),

                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.location_on,
                                                        size: 16,
                                                        color: Colors.red,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      RichText(
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,

                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  '${controller.rekomendasiKosts[index].distance.toStringAsFixed(2)} km',
                                                              style: Get
                                                                  .textTheme
                                                                  .labelSmall!
                                                                  .copyWith(
                                                                    color:
                                                                        Colors
                                                                            .teal,
                                                                  ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  ' dari lokasi Anda',
                                                              style:
                                                                  Get
                                                                      .textTheme
                                                                      .labelSmall,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 8.0,
                                                          top: 10,
                                                        ),
                                                    child: Text(
                                                      controller
                                                          .rekomendasiKosts[index]
                                                          .alamat,
                                                      style:
                                                          Get
                                                              .textTheme
                                                              .labelSmall,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKunjunganTerakhir(HomeController controller) {
    final kunjungan = controller.kunjunganTerakhir;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kunjungan Terakhir', style: Get.textTheme.titleMedium),
        const SizedBox(height: 10),
        if (kunjungan == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Anda belum pernah melakukan kunjungan kos dimanapun.',
                style: Get.textTheme.bodyMedium,
              ),
            ),
          )
        else
          buildKunjunganCard(kunjungan),
      ],
    );
  }
}

Widget buildKunjunganCard(kunjungan) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
    shadowColor: Colors.grey.withValues(alpha: 0.2),
    elevation: 4,
    child: InkWell(
      onTap: () {
        Get.toNamed(Routes.DETAIL_PAGE, arguments: kunjungan);
      },
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
              imageUrl: kunjungan.gambar,
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
                    kunjungan.nama,
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
                          FormatterHelper.formatHarga(
                            kunjungan.harga,
                          ).toString(),
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
