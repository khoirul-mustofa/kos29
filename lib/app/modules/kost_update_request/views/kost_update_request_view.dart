import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/modules/kost_update_request/controllers/kost_update_request_controller.dart';
import 'package:kos29/app/widgets/custom_text_field.dart';

class KostUpdateRequestView extends GetView<KostUpdateRequestController> {
  const KostUpdateRequestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Perubahan Data Kost'),
        actions: [
          Obx(
            () =>
                controller.isLoading.value
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                    : TextButton(
                      onPressed: controller.submitRequest,
                      child: const Text('Kirim'),
                    ),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Form Perubahan Data Kost',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Isi form di bawah ini untuk mengajukan perubahan data kost. '
              'Hanya isi field yang ingin diubah.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: controller.namaController,
              label: 'Nama Kost',
              hint: 'Masukkan nama kost',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama kost harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.alamatController,
              label: 'Alamat',
              hint: 'Masukkan alamat kost',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.hargaController,
              label: 'Harga Sewa (Rp)',
              hint: 'Masukkan harga sewa',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga sewa harus diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Harga sewa harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.deskripsiController,
              label: 'Deskripsi',
              hint: 'Masukkan deskripsi kost',
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.fasilitasController,
              label: 'Fasilitas',
              hint: 'Masukkan fasilitas (pisahkan dengan koma)',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Fasilitas harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.kamarTersediaController,
              label: 'Jumlah Kamar Tersedia',
              hint: 'Masukkan jumlah kamar tersedia',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah kamar tersedia harus diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Jumlah kamar tersedia harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.namaPemilikController,
              label: 'Nama Pemilik',
              hint: 'Masukkan nama pemilik kost',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama pemilik harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.nomorHpController,
              label: 'Nomor HP',
              hint: 'Masukkan nomor HP pemilik',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor HP harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.uangJaminanController,
              label: 'Uang Jaminan (Rp)',
              hint: 'Masukkan uang jaminan (opsional)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.kebijakanController,
              label: 'Kebijakan',
              hint: 'Masukkan kebijakan kost (pisahkan dengan koma)',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kebijakan harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: controller.alasanController,
              label: 'Alasan Perubahan',
              hint: 'Jelaskan alasan mengapa data perlu diubah',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alasan perubahan harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Riwayat Pengajuan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.requests.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Belum ada pengajuan perubahan'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.requests.length,
                itemBuilder: (context, index) {
                  final request = controller.requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pengajuan #${request.id.substring(0, 8)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: controller
                                      .getStatusColor(request.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  controller.getStatusText(request.status),
                                  style: TextStyle(
                                    color: controller.getStatusColor(
                                      request.status,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Diajukan pada: ${request.createdAt.toLocal().toString().split('.')[0]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Perubahan yang diajukan:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ...request.requestedChanges.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                bottom: 4,
                              ),
                              child: Text(
                                '• ${entry.key}: ${entry.value}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          if (request.adminNote != null) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Catatan Admin:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              request.adminNote!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          if (request.status == 'pending') ...[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed:
                                    () => controller.cancelRequest(request.id),
                                child: const Text('Batalkan Pengajuan'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      ),
    );
  }
}
