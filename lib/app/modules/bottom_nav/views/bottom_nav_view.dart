import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/modules/auth/sign_in/views/sign_in_view.dart';
import 'package:kos29/app/modules/history_search/views/history_search_view.dart';
import 'package:kos29/app/modules/home/views/home_view.dart';
import 'package:kos29/app/modules/profile/views/profile_view.dart';

import '../controllers/bottom_nav_controller.dart';

class BottomNavView extends GetView<BottomNavController> {
  const BottomNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Keluar Aplikasi'),
            content: const Text('Anda yakin ingin keluar aplikasi?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Ya', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          Future.delayed(const Duration(milliseconds: 200), () {
            Get.close(1);
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: [
            HomeView(),
            HistorySearchView(),
            controller.isAuth ? ProfileView() : SignInView(),
          ],
        ),

        bottomNavigationBar: Material(
          elevation: 10,
          child: Obx(() {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BottomNavigationBar(
                  currentIndex: controller.selectedIndex.value,
                  onTap: controller.changeTabIndexWithAnimation,
                  selectedItemColor: Colors.teal,
                  unselectedItemColor: Colors.black,
                  backgroundColor: Colors.teal.shade100,
                  selectedIconTheme: const IconThemeData(size: 30),
                  selectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  type: BottomNavigationBarType.fixed,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded),
                      label: 'Beranda',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.history),
                      label: 'Riwayat',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        controller.isAuth ? Icons.person : Icons.login_rounded,
                      ),
                      label: controller.isAuth ? 'Profil' : 'Masuk',
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
