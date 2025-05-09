import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kos29/app/modules/management_kost/add_kost/views/management_kost_add_kost_view.dart';
import '../controllers/management_kost_edit_kost_controller.dart';

class ManagementKostEditKostView
    extends GetView<ManagementKostEditKostController> {
  ManagementKostEditKostView({super.key});
  @override
  final controller = Get.put(ManagementKostEditKostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Kosan"),
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: ListView(
              children: [
                // Gambar
                GetBuilder<ManagementKostEditKostController>(
                  builder: (controller) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 200,
                        width: Get.width,
                        color: Colors.grey[200],
                        child:
                            controller.localImagePath != null
                                ? Image.file(
                                  File(controller.localImagePath!),
                                  fit: BoxFit.cover,
                                )
                                : controller.imageUrl != null
                                ? CachedNetworkImage(
                                  imageUrl: controller.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(color: Colors.white),
                                      ),
                                  errorWidget:
                                      (context, url, error) => const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                )
                                : const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.pickAndUploadImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Pilih & Upload Gambar"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                buildTextInput(
                  controller: controller.namaController,
                  label: "Nama Kosan",
                  icon: Icons.home,
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 12),
                buildTextInput(
                  controller: controller.hargaController,
                  label: "Harga / bulan",
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: controller.jenis.value,
                  decoration: InputDecoration(
                    labelText: "Jenis Kosan",
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Putra', child: Text('Putra')),
                    DropdownMenuItem(value: 'Putri', child: Text('Putri')),
                    DropdownMenuItem(value: 'Campur', child: Text('Campur')),
                  ],
                  onChanged: (val) => controller.jenis.value = val!,
                ),
                const SizedBox(height: 12),
                buildTextInput(
                  controller: controller.kamarTersediaController,
                  label: "Kamar Tersedia",
                  icon: Icons.bed,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 12),
                buildTextInput(
                  controller: controller.deskripsiController,
                  label: "Deskripsi Kosan",
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                buildTextInput(
                  controller: controller.fasilitasController,
                  label: "Fasilitas (pisahkan dengan koma)",
                  icon: Icons.checklist_rtl,
                ),
                const SizedBox(height: 12),

                Obx(
                  () => CheckboxListTile(
                    title: const Text('Kos Tersedia'),
                    value: controller.kosTersedia.value,
                    onChanged:
                        (val) => controller.kosTersedia.value = val ?? true,
                  ),
                ),
                const SizedBox(height: 12),

                buildTextInput(
                  controller: controller.alamatController,
                  label: "Alamat",
                  icon: Icons.location_on,
                  readOnly: true,
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                  onTap: controller.getCurrentLocation,
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: controller.getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text("Gunakan Lokasi Saya"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                const SizedBox(height: 16),
                Obx(() {
                  final pos = controller.currentPosition.value;
                  if (pos == null) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 250,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: pos,
                          initialZoom: 16,
                          onTap:
                              (tapPos, point) => controller.updateMarker(point),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.kos29',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: pos,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: controller.saveKost,
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan Perubahan"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
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
          const SizedBox(height: 12),
          // Upload button shimmer
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          // Form fields shimmer
          ...List.generate(
            7,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Checkbox shimmer
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          // Location button shimmer
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // Map shimmer
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          // Save button shimmer
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
