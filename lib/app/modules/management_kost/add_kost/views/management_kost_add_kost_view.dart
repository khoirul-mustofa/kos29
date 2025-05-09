import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/management_kost_add_kost_controller.dart';

class ManagementKostAddKostView
    extends GetView<ManagementKostAddKostController> {
  const ManagementKostAddKostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Kosan")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: controller.formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                GetBuilder<ManagementKostAddKostController>(
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
                Obx(() {
                  final isUploading = controller.isUploadingImage.value;
                  return OutlinedButton.icon(
                    onPressed:
                        isUploading ? null : controller.pickAndUploadImage,
                    icon:
                        isUploading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.upload_file),
                    label: Text(
                      isUploading ? "Mengupload..." : "Pilih & Upload Gambar",
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
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
                TextFormField(
                  controller: controller.deskripsiController,
                  decoration: InputDecoration(
                    labelText: "Deskripsi Kosan",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                  icon: const Icon(Icons.my_location),
                  label: const Text("Gunakan Lokasi Saya"),
                  onPressed: controller.getCurrentLocation,
                ),
                const SizedBox(height: 12),

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

                SizedBox(height: Get.height * 0.2),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        width: Get.width,
        child: Obx(() {
          final isUploading = controller.isUploadingImage.value;
          final isSaving = controller.isLoading.value;

          return FilledButton.icon(
            icon:
                isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.save),
            label: Text(isSaving ? "Menyimpan..." : "Simpan"),
            onPressed: isUploading || isSaving ? null : controller.saveKost,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }),
      ),
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

Widget buildTextInput({
  required TextEditingController controller,
  required String label,
  IconData? icon,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  int maxLines = 1,
  bool readOnly = false,
  VoidCallback? onTap,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    readOnly: readOnly,
    onTap: onTap,
    maxLines: maxLines,
    decoration: InputDecoration(
      prefixIcon: icon != null ? Icon(icon) : null,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
  );
}
