import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/formater_helper.dart';
import 'package:kos29/app/helper/timeago_helper.dart';
import 'package:kos29/app/routes/app_pages.dart';
import '../controllers/history_search_controller.dart';

class HistorySearchView extends GetView<HistorySearchController> {
  HistorySearchView({super.key});
  final controller = Get.put(HistorySearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Kunjungan',
          style: Get.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.kostData.isEmpty) {
          return const Center(child: Text('Belum ada riwayat kunjungan'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          controller: controller.scrollController,
          itemCount:
              controller.kostData.length + (controller.hasMore.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= controller.kostData.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final kost = controller.kostData[index];
            return InkWell(
              onTap: () {
                Get.toNamed(Routes.DETAIL_PAGE, arguments: kost);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.grey[900]! : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Get.isDarkMode
                              ? Colors.white.withAlpha(24)
                              : Colors.black.withAlpha(24),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Gambar thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        kost.gambar,
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 100,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kost.nama,
                            style: Get.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kost.alamat,
                            style: Get.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
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
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${FormatterHelper.formatHarga(kost.harga)} / bulan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dikunjungi ${timeAgoHelper(kost.visitedAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
