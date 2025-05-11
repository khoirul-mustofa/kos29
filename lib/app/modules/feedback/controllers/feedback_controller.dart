import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kos29/app/helper/logger_app.dart';

class FeedbackController extends GetxController {
  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final feedbackController = TextEditingController();

  // Observable variables
  final rating = 0.obs;
  final selectedCategory = ''.obs;
  final isLoading = false.obs;

  // Methods to update state
  void setRating(int value) {
    rating.value = value;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  // Form validation
  bool validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showError('please_enter_name'.tr);
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _showError('please_enter_email'.tr);
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showError('please_enter_valid_email'.tr);
      return false;
    }

    if (rating.value == 0) {
      _showError('please_select_rating'.tr);
      return false;
    }

    if (selectedCategory.value.isEmpty) {
      _showError('please_select_category'.tr);
      return false;
    }

    if (feedbackController.text.trim().isEmpty) {
      _showError('please_enter_feedback'.tr);
      return false;
    }

    return true;
  }

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      borderRadius: 12,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      icon: const Icon(Icons.error, color: Colors.white),
      animationDuration: const Duration(milliseconds: 500),
    );
  }

  // Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'success'.tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Reset form
  void _resetForm() {
    nameController.clear();
    emailController.clear();
    feedbackController.clear();
    rating.value = 0;
    selectedCategory.value = '';
  }

  // Submit feedback
  Future<void> submitFeedback() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      await FirebaseFirestore.instance.collection('feedbacks').add({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'rating': rating.value,
        'category': selectedCategory.value,
        'message': feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccess('feedback_submitted'.tr);
      _resetForm();
    } catch (e) {
      _showError('failed_to_submit_feedback'.tr);
      logger.e('Error submitting feedback: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get rating text based on value
  String getRatingText() {
    switch (rating.value) {
      case 1:
        return 'bad'.tr;
      case 2:
        return 'okay'.tr;
      case 3:
        return 'good'.tr;
      case 4:
      case 5:
        return 'excellent'.tr;
      default:
        return '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    feedbackController.dispose();
    super.onClose();
  }
}
