import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kos_registration.dart';


class KostSubmissionListPage extends StatefulWidget {
  const KostSubmissionListPage({Key? key}) : super(key: key);

  @override
  State<KostSubmissionListPage> createState() => _KostSubmissionListPageState();
}

class _KostSubmissionListPageState extends State<KostSubmissionListPage> {
  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengajuan Kost'),
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
                  color: Colors.black.withValues(alpha: 0.1),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kos_registrations')
                  .orderBy('createdAt', descending: true)
                  .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada data registrasi'));
                }
                final registrations = snapshot.data!.docs
                    .map((doc) => KosRegistration.fromJson(doc.data() as Map<String, dynamic>))
                    .toList();
                final filteredRegistrations = selectedFilter == 'all'
                    ? registrations
                    : registrations.where((reg) => reg.status == selectedFilter).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRegistrations.length,
                  itemBuilder: (context, index) {
                    final registration = filteredRegistrations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(registration.namaKos),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(registration.alamat),
                            const SizedBox(height: 4),
                            _buildStatusChip(registration.status ?? 'unknown'),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            selectedFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
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