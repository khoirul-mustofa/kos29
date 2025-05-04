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

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Container(
                height: 200,
                width: Get.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(
                      kost['informasi_kost']['gambar'] ??
                          'https://via.placeholder.com/600x400',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text(
                "Nama: ${kost['informasi_kost']['nama']}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text("Alamat: ${kost['informasi_kost']['alamat']}"),
              const SizedBox(height: 8),
              Text("Harga: Rp ${kost['informasi_kost']['harga']} / bulan"),
              const SizedBox(height: 8),
              Text("Jenis: ${kost['informasi_kost']['jenis']}"),
              const SizedBox(height: 8),
              Text(
                "Fasilitas: ${kost['informasi_kost']['fasilitas'].join(', ')}",
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.deleteKost,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Hapus Kosan"),
              ),
            ],
          ),
        );
      }),
    );
  }
}
