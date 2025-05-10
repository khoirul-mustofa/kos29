import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/auth_reset_password_controller.dart';

class AuthResetPasswordView extends GetView<AuthResetPasswordController> {
  const AuthResetPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF009688)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Reset Password Card
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GetBuilder<AuthResetPasswordController>(
                  builder: (_) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 700),
                      opacity: 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Lottie animation with error handling
                            SizedBox(
                              height: 120,
                              child: Lottie.asset(
                                'assets/lottie/Animation-reset-password.json',
                                fit: BoxFit.contain,
                                repeat: true,
                                animate: true,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('Lottie error: $error');
                                  return const Icon(
                                    Icons.lock_reset,
                                    size: 80,
                                    color: Colors.teal,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Reset Password',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[800],
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'Masukkan email Anda dan kami akan mengirimkan link untuk reset password.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),

                            // Email Field
                            TextFormField(
                              controller: controller.emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 24),

                            // Reset Password Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Obx(
                                () => ElevatedButton(
                                  onPressed:
                                      controller.isLoading.value
                                          ? null
                                          : () => controller.resetPassword(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child:
                                      controller.isLoading.value
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : const Text(
                                            'Kirim Link Reset',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Ingat password Anda?"),
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Login'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
