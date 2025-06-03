import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/data/models/kost_update_request_model.dart';
import 'package:kos29/app/data/services/kost_update_request_service.dart';

class KostUpdateRequestController extends GetxController {
  final KostModel kost;
  final _requestService = KostUpdateRequestService();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final requests = <KostUpdateRequestModel>[].obs;

  // Form controllers
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final fasilitasController = TextEditingController();
  final kamarTersediaController = TextEditingController();
  final namaPemilikController = TextEditingController();
  final nomorHpController = TextEditingController();
  final uangJaminanController = TextEditingController();
  final kebijakanController = TextEditingController();
  final alasanController = TextEditingController();

  // Original data
  late final Map<String, dynamic> originalData;

  KostUpdateRequestController({required this.kost}) {
    // Store original data
    originalData = {
      'nama': kost.nama,
      'alamat': kost.alamat,
      'harga': kost.harga.toString(),
      'deskripsi': kost.deskripsi,
      'fasilitas': kost.fasilitas.join(', '),
      'kamarTersedia': kost.kamarTersedia.toString(),
      'namaPemilik': kost.namaPemilik,
      'nomorHp': kost.nomorHp,
      'uangJaminan': kost.uangJaminan?.toString() ?? '',
      'kebijakan': kost.kebijakan.join(', '),
    };

    // Initialize form fields with current values
    namaController.text = kost.nama;
    alamatController.text = kost.alamat;
    hargaController.text = kost.harga.toString();
    deskripsiController.text = kost.deskripsi;
    fasilitasController.text = kost.fasilitas.join(', ');
    kamarTersediaController.text = kost.kamarTersedia.toString();
    namaPemilikController.text = kost.namaPemilik;
    nomorHpController.text = kost.nomorHp;
    uangJaminanController.text = kost.uangJaminan?.toString() ?? '';
    kebijakanController.text = kost.kebijakan.join(', ');
  }

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  @override
  void onClose() {
    namaController.dispose();
    alamatController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    fasilitasController.dispose();
    kamarTersediaController.dispose();
    namaPemilikController.dispose();
    nomorHpController.dispose();
    uangJaminanController.dispose();
    kebijakanController.dispose();
    alasanController.dispose();
    super.onClose();
  }

  Future<void> loadRequests() async {
    if (kost.id == null) return;
    try {
      final requestsList = await _requestService.getRequestsByKostId(kost.id!);
      requests.assignAll(requestsList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat riwayat pengajuan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Map<String, dynamic> _getChangedFields() {
    final changes = <String, dynamic>{};
    final currentData = {
      'nama': namaController.text,
      'alamat': alamatController.text,
      'harga': hargaController.text,
      'deskripsi': deskripsiController.text,
      'fasilitas': fasilitasController.text,
      'kamarTersedia': kamarTersediaController.text,
      'namaPemilik': namaPemilikController.text,
      'nomorHp': nomorHpController.text,
      'uangJaminan': uangJaminanController.text,
      'kebijakan': kebijakanController.text,
    };

    currentData.forEach((key, value) {
      if (value != originalData[key]) {
        changes[key] = value;
      }
    });

    return changes;
  }

  Future<void> submitRequest() async {
    if (kost.id == null) return;
    if (!formKey.currentState!.validate()) {
      return;
    }

    final changes = _getChangedFields();
    if (changes.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Tidak ada perubahan yang diajukan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _requestService.submitRequest(
        kostId: kost.id!,
        requestedChanges: changes,
        reason: alasanController.text,
      );

      // Reset form fields to original values
      namaController.text = originalData['nama'];
      alamatController.text = originalData['alamat'];
      hargaController.text = originalData['harga'];
      deskripsiController.text = originalData['deskripsi'];
      fasilitasController.text = originalData['fasilitas'];
      kamarTersediaController.text = originalData['kamarTersedia'];
      namaPemilikController.text = originalData['namaPemilik'];
      nomorHpController.text = originalData['nomorHp'];
      uangJaminanController.text = originalData['uangJaminan'];
      kebijakanController.text = originalData['kebijakan'];
      alasanController.clear();

      Get.snackbar(
        'Sukses',
        'Pengajuan perubahan berhasil dikirim',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadRequests();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim pengajuan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      isLoading.value = true;
      await _requestService.cancelRequest(requestId);
      Get.snackbar(
        'Sukses',
        'Pengajuan berhasil dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadRequests();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membatalkan pengajuan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
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
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
