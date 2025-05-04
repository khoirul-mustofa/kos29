import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../controllers/management_kost_add_kost_controller.dart';

class ManagementKostAddKostView
    extends GetView<ManagementKostAddKostController> {
  const ManagementKostAddKostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Kosan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              // Gambar
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
                icon: const Icon(Icons.my_location),
                label: const Text("Gunakan Lokasi Saya"),
                onPressed: controller.getCurrentLocation,
              ),
              const SizedBox(height: 12),

              Obx(() {
                final pos = controller.currentPosition.value;
                if (pos == null) {
                  return const Center(child: CircularProgressIndicator());
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
                              width: 40,
                              height: 40,
                              point: pos,
                              child: const Icon(
                                Icons.location_pin,
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
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: Get.width,
        child: FilledButton.icon(
          icon: const Icon(Icons.save),
          label: const Text("Simpan"),
          onPressed: controller.saveKost,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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
