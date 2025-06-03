import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/routes/app_pages.dart';
import '../controllers/kost_page_controller.dart';

class KostPageView extends StatefulWidget {
  const KostPageView({super.key});

  @override
  State<KostPageView> createState() => _KostPageViewState();
}

class _KostPageViewState extends State<KostPageView> {
  final controller = Get.find<KostPageController>();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 300 &&
          !controller.isLoadingMore.value &&
          controller.hasMore.value) {
        controller.loadKos();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKostCard(KostModel kost) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.home, size: 36, color: Colors.teal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kost.namaKos, style: Get.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(kost.alamat, style: Get.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  'Rp ${kost.harga.toStringAsFixed(0)}/bulan',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kosan'),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: controller.goToAddKost,
        //   ),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.kosanList.isEmpty) {
          return _buildShimmerLoading();
        }

        final kostList = controller.kosanList;
        if (kostList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Belum ada data kosan'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadKos(firstLoad: true),
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: kostList.length + (controller.hasMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index >= kostList.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final kost = kostList[index];
              return GestureDetector(
                onTap:
                    () =>
                        kost.id != null
                            ? controller.goToDetail(kost.id!)
                            : null,
                child: Card(
                  child: ListTile(
                    title: Text(kost.namaKos),
                    subtitle: Text(kost.alamat),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_document),
                          onPressed: () {
                            Get.toNamed(
                              Routes.KOST_UPDATE_REQUEST,
                              arguments: kost,
                            );
                          },
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
