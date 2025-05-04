import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController.value,
                itemCount: controller.images.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(controller.images[index]),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Kenapa harus kami?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Memberikan anda informasi seputar harga kost dari yang termurah dan tertinggi',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed(Routes.BOTTOM_NAV); // Lewati onboarding
                    },
                    child: const Text(
                      'Lewatkan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      controller.images.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.pageController.page ==
                          controller.images.length - 1) {
                        Get.offAllNamed(
                          Routes.BOTTOM_NAV,
                        ); // Selesai onboarding
                      } else {
                        controller.pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    child: Row(
                      children: const [
                        Text('Lanjut'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Rx<PageController> {
  get page => null;

  void nextPage({required Duration duration, required Cubic curve}) {}
}
