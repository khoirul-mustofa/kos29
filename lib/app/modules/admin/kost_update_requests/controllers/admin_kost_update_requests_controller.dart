import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_update_request_model.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/services/kost_update_request_service.dart';

class AdminKostUpdateRequestsController extends GetxController {
  final _requestService = KostUpdateRequestService();
  final isLoading = false.obs;
  final requests = <KostUpdateRequestModel>[].obs;
  final selectedStatus = 'pending'.obs;
  final adminNoteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  @override
  void onClose() {
    adminNoteController.dispose();
    super.onClose();
  }

  void loadRequests() {
    _requestService.getPendingUpdateRequests().listen(
      (updatedRequests) {
        requests.value = updatedRequests;
      },
      onError: (error) {
        logger.e('Error loading requests: $error');
        Get.snackbar(
          'Error',
          'Gagal memuat daftar pengajuan',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    if (status == 'rejected' && adminNoteController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Catatan harus diisi untuk menolak pengajuan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _requestService.updateRequestStatus(
        requestId: requestId,
        status: status,
        adminNote:
            status == 'rejected' ? adminNoteController.text.trim() : null,
      );

      Get.back(); // Close dialog
      Get.snackbar(
        'Sukses',
        'Status pengajuan berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      logger.e('Error updating request status: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      adminNoteController.clear();
    }
  }

  void showReviewDialog(KostUpdateRequestModel request) {
    Get.dialog(
      AlertDialog(
        title: const Text('Tinjau Pengajuan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengajuan #${request.id.substring(0, 8)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Diajukan pada: ${request.createdAt.toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Perubahan yang diajukan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...request.requestedChanges.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(
                    '• ${entry.key}: ${entry.value}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              if (request.requestedChanges.containsKey('alasan')) ...[
                const SizedBox(height: 16),
                const Text(
                  'Alasan perubahan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  request.requestedChanges['alasan'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: adminNoteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (wajib diisi jika menolak)',
                  hintText: 'Masukkan catatan untuk pengajuan ini',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              adminNoteController.clear();
              Get.back();
            },
            child: const Text('Batal'),
          ),
          Obx(
            () =>
                isLoading.value
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed:
                              () => updateRequestStatus(request.id, 'rejected'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Tolak'),
                        ),
                        TextButton(
                          onPressed:
                              () => updateRequestStatus(request.id, 'approved'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                          child: const Text('Setujui'),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
