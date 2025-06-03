import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kos29/app/modules/profile/controllers/profile_controller.dart';
import '../controllers/management_kost_detail_kost_controller.dart';

class ManagementKostDetailKostView
    extends GetView<ManagementKostDetailKostController> {
  const ManagementKostDetailKostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kost'),
        actions: [
          Obx(() {
            final profileController = Get.find<ProfileController>();
            if (profileController.userRole.value == 'admin') {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: controller.goToEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => controller.showDeleteConfirmation(),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        final kost = controller.kost.value;
        if (kost == null) {
          return const Center(child: Text('Data kosan tidak ditemukan'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel
              if (controller.imageUrls.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: controller.imageUrls[index],
                            width: 300,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 300,
                                    height: 200,
                                    color: Colors.white,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  width: 300,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_not_supported, size: 64),
                ),

              const SizedBox(height: 24),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: controller
                      .getStatusColor(kost.status)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.getStatusColor(kost.status),
                  ),
                ),
                child: Text(
                  controller.getStatusText(kost.status),
                  style: TextStyle(
                    color: controller.getStatusColor(kost.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Kost Information
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
                      subtitle: Text(kost.namaKos),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.place),
                      title: const Text('Alamat'),
                      subtitle: Text(kost.alamat),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: const Text('Harga per Bulan'),
                      subtitle: Text(controller.getFormattedPrice(kost.harga)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.wc),
                      title: const Text('Jenis'),
                      subtitle: Text(kost.jenis),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: const Text('Fasilitas'),
                      subtitle: Text(
                        kost.fasilitas.isEmpty
                            ? '-'
                            : kost.fasilitas.join(', '),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Deskripsi'),
                      subtitle: Text(kost.deskripsi),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.policy),
                      title: const Text('Kebijakan'),
                      subtitle: Text(
                        kost.kebijakan.isEmpty
                            ? '-'
                            : kost.kebijakan.join(', '),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.bed),
                      title: const Text('Kamar Tersedia'),
                      subtitle: Text('${kost.kamarTersedia} kamar'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Kontak Pemilik'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(kost.namaPemilik), Text(kost.nomorHp)],
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Tanggal Dibuat'),
                      subtitle: Text(
                        controller.getFormattedDate(kost.createdAt),
                      ),
                    ),
                    if (kost.updatedAt != null) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.update),
                        title: const Text('Terakhir Diperbarui'),
                        subtitle: Text(
                          controller.getFormattedDate(kost.updatedAt!),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final profileController = Get.find<ProfileController>();
        if (profileController.userRole.value != 'admin' ||
            controller.isLoading.value ||
            controller.kost.value == null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed:
                  controller.isDeleting.value ? null : controller.deleteKost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon:
                  controller.isDeleting.value
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.delete),
              label: Text(
                controller.isDeleting.value ? 'Menghapus...' : 'Hapus Kosan',
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image shimmer
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
              // Status shimmer
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 24),
              // Card shimmer
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
