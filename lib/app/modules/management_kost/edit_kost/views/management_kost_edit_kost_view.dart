import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../controllers/management_kost_edit_kost_controller.dart';

class ManagementKostEditKostView
    extends GetView<ManagementKostEditKostController> {
  const ManagementKostEditKostView({super.key});

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
              TextFormField(
                controller: controller.namaController,
                decoration: const InputDecoration(labelText: 'Nama Kosan'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga / bulan'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: controller.jenis.value,
                items: const [
                  DropdownMenuItem(value: 'Putra', child: Text('Putra')),
                  DropdownMenuItem(value: 'Putri', child: Text('Putri')),
                  DropdownMenuItem(value: 'Campur', child: Text('Campur')),
                ],
                onChanged: (val) => controller.jenis.value = val!,
                decoration: const InputDecoration(labelText: 'Jenis Kosan'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi Kosan'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.fasilitasController,
                decoration: const InputDecoration(
                  labelText: 'Fasilitas (pisahkan dengan koma)',
                ),
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
              TextFormField(
                controller: controller.alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                readOnly: true,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.my_location),
                label: const Text("Gunakan Lokasi Saya"),
                onPressed: controller.getCurrentLocation,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: Obx(() {
                  final pos = controller.currentPosition.value;
                  if (pos == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return FlutterMap(
                    options: MapOptions(
                      initialCenter: pos,
                      initialZoom: 16,
                      onTap:
                          (tapPosition, point) =>
                              controller.updateMarker(point),
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
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Gambar → Ganti Obx menjadi GetBuilder
              GetBuilder<ManagementKostEditKostController>(
                builder: (_) {
                  if (controller.localImagePath != null) {
                    return Image.file(
                      File(controller.localImagePath!),
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  } else if (controller.imageUrl != null) {
                    return Image.network(
                      controller.imageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return const Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey,
                    );
                  }
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.pickAndUploadImage,
                child: const Text("Pilih & Upload Gambar"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.saveKost,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
