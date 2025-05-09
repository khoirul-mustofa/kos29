import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Kosan'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value && controller.kosanList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final kostList = controller.kosanList;
        if (kostList.isEmpty) {
          return const Center(child: Text('Belum ada data kosan.'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadKos(firstLoad: true),
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                kostList.length +
                (controller.hasMore.value ? 1 : 0), // +1 untuk loader
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index < kostList.length) {
                final kost = kostList[index];
                return GestureDetector(
                  onTap: () => controller.goToDetail(kost['id']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
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
                              Text(
                                kost['nama'],
                                style: Get.theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                kost['alamat'],
                                style: Get.theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      ],
                    ),
                  ),
                );
              } else {
                // Loader bawah
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToAddKost,
        backgroundColor: Get.isDarkMode ? Colors.grey[800] : Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
