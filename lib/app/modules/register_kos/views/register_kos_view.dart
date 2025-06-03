import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/register_kos_controller.dart';
import 'package:shimmer/shimmer.dart';

class RegisterKosView extends GetView<RegisterKosController> {
  const RegisterKosView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kos'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A. Informasi Kos
                const Text(
                  'Informasi Kos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Nama Kos
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Kos',
                    border: OutlineInputBorder(),
                    helperText: 'Minimal 3 karakter',
                  ),
                  validator:
                      (value) =>
                          (value?.isEmpty ?? true)
                              ? 'Nama kos harus diisi'
                              : (value!.length < 3)
                              ? 'Nama kos minimal 3 karakter'
                              : null,
                  onChanged: (value) => controller.namaKos.value = value,
                ),
                const SizedBox(height: 16),

                // Jenis Kos
                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kos',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.jenis.value,
                    items:
                        ['putra', 'putri', 'campur']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toUpperCase()),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) controller.jenis.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Alamat
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Alamat Lengkap',
                    border: OutlineInputBorder(),
                    helperText: 'Minimal 10 karakter',
                  ),
                  maxLines: 3,
                  validator:
                      (value) =>
                          (value?.isEmpty ?? true)
                              ? 'Alamat harus diisi'
                              : (value!.length < 10)
                              ? 'Alamat minimal 10 karakter'
                              : null,
                  onChanged: (value) => controller.alamat.value = value,
                ),
                const SizedBox(height: 16),

                // Map Section
                const Text(
                  'Lokasi Kos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Search Box
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Cari Lokasi',
                    hintText: 'Masukkan alamat atau nama tempat',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Obx(
                      () =>
                          controller.isSearching.value
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : IconButton(
                                icon: const Icon(Icons.my_location),
                                onPressed: controller.getCurrentLocation,
                              ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => controller.searchQuery.value = value,
                  onSubmitted: (_) => controller.searchLocation(),
                ),
                const SizedBox(height: 16),

                // Map
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
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: pos,
                              initialZoom: controller.currentZoom.value,
                              onTap:
                                  (tapPos, point) =>
                                      controller.updateMarker(point),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.kos29.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  if (controller.selectedLocation.value != null)
                                    Marker(
                                      point: controller.selectedLocation.value!,
                                      width: 40,
                                      height: 40,
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
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              onPressed: controller.getCurrentLocation,
                              child: const Icon(Icons.my_location),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Selected Location Info
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.selectedLocation.value == null) {
                    return const Text(
                      'Pilih lokasi pada peta atau gunakan pencarian',
                      style: TextStyle(color: Colors.grey),
                    );
                  }
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi Terpilih:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(controller.alamat.value),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${controller.latitude.value?.toStringAsFixed(6)}, '
                            'Lng: ${controller.longitude.value?.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Deskripsi
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Kos',
                    border: OutlineInputBorder(),
                    helperText: 'Minimal 20 karakter',
                  ),
                  maxLines: 3,
                  validator:
                      (value) =>
                          (value?.isEmpty ?? true)
                              ? 'Deskripsi harus diisi'
                              : (value!.length < 20)
                              ? 'Deskripsi minimal 20 karakter'
                              : null,
                  onChanged: (value) => controller.deskripsi.value = value,
                ),
                const SizedBox(height: 24),

                // B. Fasilitas
                const Text(
                  'Fasilitas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        controller.availableFasilitas
                            .map(
                              (fasilitas) => FilterChip(
                                label: Text(fasilitas),
                                selected: controller.fasilitas.contains(
                                  fasilitas,
                                ),
                                onSelected:
                                    (_) =>
                                        controller.toggleFasilitas(fasilitas),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // C. Harga
                const Text(
                  'Harga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Harga per Bulan',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                    helperText: 'Masukkan angka lebih dari 0',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Harga harus diisi';
                    final price = int.tryParse(value!);
                    if (price == null) return 'Harga harus berupa angka';
                    if (price <= 0) return 'Harga harus lebih dari 0';
                    return null;
                  },
                  onChanged:
                      (value) =>
                          controller.harga.value = int.tryParse(value) ?? 0,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Uang Jaminan (Opsional)',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isNotEmpty ?? false) {
                      if (int.tryParse(value!) == null) {
                        return 'Harga harus berupa angka';
                      }
                    }
                    return null;
                  },
                  onChanged:
                      (value) =>
                          controller.uangJaminan.value =
                              value.isNotEmpty ? int.tryParse(value) : null,
                ),
                const SizedBox(height: 24),

                // D. Foto Kos
                const Text(
                  'Foto Kos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: controller.pickFotoKos,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Upload Foto Kos'),
                      ),
                      if (controller.fotoKos.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.fotoKos.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    Image.file(
                                      File(controller.fotoKos[index].path),
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => controller.fotoKos.removeAt(
                                              index,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // E. Dokumen Verifikasi
                const Text(
                  'Dokumen Verifikasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Column(
                    children: [
                      ListTile(
                        title: const Text('KTP Pemilik'),
                        subtitle: Text(
                          controller.ktpFile.value?.name ??
                              'Belum ada file dipilih',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.upload_file),
                          onPressed:
                              () => controller.pickImage(
                                ImageSource.gallery,
                                controller.ktpFile,
                              ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Bukti Kepemilikan'),
                        subtitle: Text(
                          controller.buktiKepemilikanFile.value?.name ??
                              'Belum ada file dipilih',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.upload_file),
                          onPressed:
                              () => controller.pickImage(
                                ImageSource.gallery,
                                controller.buktiKepemilikanFile,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // F. Kontak Pemilik
                const Text(
                  'Kontak Pemilik',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap Pemilik',
                    border: OutlineInputBorder(),
                    helperText: 'Minimal 3 karakter',
                  ),
                  validator:
                      (value) =>
                          (value?.isEmpty ?? true)
                              ? 'Nama pemilik harus diisi'
                              : (value!.length < 3)
                              ? 'Nama pemilik minimal 3 karakter'
                              : null,
                  onChanged: (value) => controller.namaPemilik.value = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP/WA',
                    border: OutlineInputBorder(),
                    helperText: 'Minimal 10 digit',
                  ),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          (value?.isEmpty ?? true)
                              ? 'Nomor HP harus diisi'
                              : (value!.length < 10)
                              ? 'Nomor HP minimal 10 digit'
                              : null,
                  onChanged: (value) => controller.nomorHp.value = value,
                ),
                const SizedBox(height: 32),

                // G. Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Daftar Kos',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }
}
