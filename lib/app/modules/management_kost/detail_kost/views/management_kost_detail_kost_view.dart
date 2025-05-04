import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          return const Center(child: CircularProgressIndicator());
        }

        final info = kost['informasi_kost'];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: info['gambar'] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
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
                    subtitle: Text(info['nama']),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.place),
                    title: const Text('Alamat'),
                    subtitle: Text(info['alamat']),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Harga per Bulan'),
                    subtitle: Text('Rp ${info['harga']}'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.wc),
                    title: const Text('Jenis'),
                    subtitle: Text(info['jenis']),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: const Text('Fasilitas'),
                    subtitle: Text(info['fasilitas'].join(', ')),
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
}
