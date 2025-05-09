import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/management_kost_detail_kost_controller.dart';

class ManagementKostDetailKostView
    extends GetView<ManagementKostDetailKostController> {
  const ManagementKostDetailKostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kosan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: controller.goToEdit,
          ),
        ],
      ),
      body: Obx(() {
        final kost = controller.kostData;
        if (kost.isEmpty) {
          return _buildShimmerLoading();
        }

        final fasilitas = (kost['fasilitas'] as List?)?.join(', ') ?? '-';
        final imageUrl = controller.imageUrl;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            imageUrl != null && imageUrl.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(height: 200, color: Colors.white),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                  ),
                )
                : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.house),
                    title: const Text('Nama Kosan'),
                    subtitle: Text(kost['nama'] ?? '-'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.place),
                    title: const Text('Alamat'),
                    subtitle: Text(kost['alamat'] ?? '-'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Harga per Bulan'),
                    subtitle: Text('Rp ${kost['harga'] ?? 0}'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.wc),
                    title: const Text('Jenis'),
                    subtitle: Text(kost['jenis'] ?? '-'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: const Text('Fasilitas'),
                    subtitle: Text(fasilitas),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: controller.deleteKost,
              label: const Text("Hapus Kosan"),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image shimmer
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 20),
          // Card shimmer
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icon shimmer
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title shimmer
                            Container(
                              width: 100,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtitle shimmer
                            Container(
                              width: double.infinity,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Button shimmer
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
