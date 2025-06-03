import 'dart:developer';

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
    log(' is dark mode${Get.isDarkMode.toString()}');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // if (didPop) return;
        // final shouldExit = await Get.dialog<bool>(
        //   AlertDialog(
        //     title: Text('exit_app_title'.tr),
        //     content: Text('exit_app_content'.tr),
        //     actions: [
        //       TextButton(
        //         onPressed: () => Get.back(result: false),
        //         child: Text('exit_app_no'.tr),
        //       ),
        //       TextButton(
        //         onPressed: () => Get.back(result: true),
        //         child: Text(
        //           'exit_app_yes'.tr,
        //           style: TextStyle(color: Colors.red),
        //         ),
        //       ),
        //     ],
        //   ),
        // );
        // if (shouldExit == true) {
        //   Future.delayed(const Duration(milliseconds: 200), () {
        //     Get.close(1);
        //   });
        // }
      },
      child: Scaffold(
        backgroundColor:
            Get.isDarkMode ? Colors.grey[800] : Colors.teal.shade100,
        body: PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: [HomeView(), HistorySearchView(), ProfileView()],
        ),

        bottomNavigationBar: Obx(() {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: 1.0,
                    child: BottomNavigationBar(
                      currentIndex: controller.selectedIndex.value,
                      onTap: controller.changeTabIndexWithAnimation,
                      selectedItemColor: Colors.teal,
                      unselectedItemColor:
                          Get.isDarkMode ? Colors.grey : Colors.black,
                      backgroundColor:
                          Get.isDarkMode
                              ? Colors.grey[800]
                              : Colors.teal.shade100,
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
                      elevation: 0,
                      items: [
                        BottomNavigationBarItem(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              Icons.home_rounded,
                              key: ValueKey(
                                controller.selectedIndex.value == 0,
                              ),
                            ),
                          ),
                          label: 'bottom_nav_home'.tr,
                        ),
                        BottomNavigationBarItem(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              Icons.history,
                              key: ValueKey(
                                controller.selectedIndex.value == 1,
                              ),
                            ),
                          ),
                          label: 'bottom_nav_history'.tr,
                        ),
                        BottomNavigationBarItem(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              Icons.person,
                              key: ValueKey(
                                controller.selectedIndex.value == 2,
                              ),
                            ),
                          ),
                          label: 'bottom_nav_profile'.tr,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
