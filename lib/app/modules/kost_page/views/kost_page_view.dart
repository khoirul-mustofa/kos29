import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kost_page_controller.dart';

class KostPageView extends GetView<KostPageController> {
  const KostPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Kosan'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final kostList = controller.kosanList;
        if (kostList.isEmpty) {
          return const Center(child: Text('Belum ada data kosan.'));
        }

        return RefreshIndicator(
          onRefresh: controller.loadKos,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: kostList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final kost = kostList[index];
              return GestureDetector(
                onTap: () => controller.goToDetail(kost['id']),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kost['alamat'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToAddKost,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
