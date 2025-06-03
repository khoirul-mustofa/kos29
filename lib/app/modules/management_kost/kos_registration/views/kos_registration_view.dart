import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kos_registration_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class KosRegistrationView extends GetView<KosRegistrationController> {
  const KosRegistrationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Kos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'all'),
                  _buildFilterChip('Pending', 'pending'),
                  _buildFilterChip('Disetujui', 'approved'),
                  _buildFilterChip('Ditolak', 'rejected'),
                ],
              ),
            ),
          ),

          // Registrations List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredRegistrations.isEmpty) {
                return const Center(
                  child: Text('Tidak ada data registrasi'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredRegistrations.length,
                itemBuilder: (context, index) {
                  final registration = controller.filteredRegistrations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      title: Text(registration.namaKos),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(registration.alamat),
                          const SizedBox(height: 4),
                          _buildStatusChip(registration.status),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kos Photos
                              if (registration.fotoKosUrls.isNotEmpty) ...[
                                const Text(
                                  'Foto Kos',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: registration.fotoKosUrls.length,
                                    itemBuilder: (context, photoIndex) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: CachedNetworkImage(
                                          imageUrl: registration.fotoKosUrls[photoIndex],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Basic Info
                              _buildInfoRow('Jenis Kos', registration.jenis.toUpperCase()),
                              _buildInfoRow('Harga per Bulan', 'Rp ${registration.harga}'),
                              if (registration.uangJaminan != null)
                                _buildInfoRow('Uang Jaminan', 'Rp ${registration.uangJaminan}'),
                              _buildInfoRow('Deskripsi', registration.deskripsi),
                              
                              // Facilities
                              const SizedBox(height: 8),
                              const Text(
                                'Fasilitas',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Wrap(
                                spacing: 8,
                                children: registration.fasilitas
                                    .map((f) => Chip(label: Text(f)))
                                    .toList(),
                              ),

                              // Owner Info
                              const SizedBox(height: 16),
                              const Text(
                                'Informasi Pemilik',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow('Nama', registration.namaPemilik),
                              _buildInfoRow('Nomor HP', registration.nomorHp),

                              // Documents
                              const SizedBox(height: 16),
                              const Text(
                                'Dokumen',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                title: const Text('KTP'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    // Show KTP image in dialog
                                    Get.dialog(
                                      Dialog(
                                        child: CachedNetworkImage(
                                          imageUrl: registration.ktpUrl,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text('Bukti Kepemilikan'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    // Show bukti kepemilikan image in dialog
                                    Get.dialog(
                                      Dialog(
                                        child: CachedNetworkImage(
                                          imageUrl: registration.buktiKepemilikanUrl,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Action Buttons
                              if (registration.status == 'pending') ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => controller.showRejectionDialog(registration.id!),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Tolak'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => controller.updateRegistrationStatus(
                                        registration.id!,
                                        'approved',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text('Setujui'),
                                    ),
                                  ],
                                ),
                              ],

                              // Show rejection reason if rejected
                              if (registration.status == 'rejected' &&
                                  registration.rejectionReason != null) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Alasan Penolakan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  registration.rejectionReason!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Obx(
        () => FilterChip(
          label: Text(label),
          selected: controller.selectedFilter.value == value,
          onSelected: (selected) {
            if (selected) {
              controller.setFilter(value);
            }
          },
          selectedColor: Colors.teal.withOpacity(0.2),
          checkmarkColor: Colors.teal,
          labelStyle: TextStyle(
            color: controller.selectedFilter.value == value
                ? Colors.teal
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'approved':
        color = Colors.green;
        label = 'Disetujui';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Ditolak';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 