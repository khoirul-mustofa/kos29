import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthResetPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  void resetPassword() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());

      // Show success dialog with instructions
      Get.dialog(
        AlertDialog(
          title: const Text('Link Reset Password Terkirim'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kami telah mengirimkan link reset password ke email Anda. Silakan:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildInstructionItem('1. Buka email Anda'),
              _buildInstructionItem('2. Cari email dari Kos29'),
              _buildInstructionItem(
                '3. Klik link reset password yang diberikan',
              ),
              _buildInstructionItem('4. Buat password baru Anda'),
              const SizedBox(height: 16),
              const Text(
                'Jika email tidak ditemukan, periksa folder spam atau junk mail.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Return to login page
              },
              child: const Text('OK'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        default:
          message = 'Terjadi kesalahan. Silakan coba lagi';
      }

      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
