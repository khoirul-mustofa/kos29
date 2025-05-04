import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:kos29/app/modules/auth/sign_in/controllers/sign_in_controller.dart';
import 'package:kos29/app/routes/app_pages.dart';

import 'package:lottie/lottie.dart';

class SignInView extends GetView<SignInController> {
  SignInView({super.key});
  @override
  final controller = Get.put(SignInController());

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

          // Login Card
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GetBuilder<SignInController>(
                builder: (_) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 700),
                    opacity: 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Lottie animation (optional)
                          Lottie.asset(
                            'assets/lottie/Animation-login.json',
                            height: 120,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Selamat Datang!',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Google Sign-In Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                User? user =
                                    await controller.signInWithGoogle();
                                if (user != null) {
                                  logger.i(
                                    'Login successful: ${user.displayName}',
                                  );
                                  Get.offAllNamed(Routes.BOTTOM_NAV);
                                }
                              },
                              icon: Image.asset(
                                'assets/icons/google.png',
                                width: 24,
                              ),
                              label: const Text(
                                'Login dengan Google',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
