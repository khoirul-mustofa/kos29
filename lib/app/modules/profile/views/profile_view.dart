import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<ProfileController>(
          builder: (controller) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: NetworkImage(
                            '${controller.userData!['photo_url']}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    controller.userData!['displayName'] ?? '---',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.userData!['email'] ?? '---',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(Routes.EDIT_PROFILE);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade50,
                      minimumSize: const Size(100, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'edit_profile'.tr,
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildMenuItem(Icons.location_on_outlined, 'location'.tr, () {
                    Get.toNamed(Routes.CHANGE_LOCATION);
                  }),
                  _buildMenuItem(
                    Icons.apartment_outlined,
                    'manage_kost'.tr,
                    () {
                      Get.toNamed(Routes.KOST_PAGE);
                    },
                  ),
                  _buildMenuItem(
                    Icons.rate_review_outlined,
                    'manage_review'.tr,
                    () {
                      Get.toNamed(Routes.REVIEW_MANAGEMENT);
                    },
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () =>
                        controller.isAdmin.value
                            ? _buildMenuItem(
                              Icons.person_outline,
                              'Manage User',
                              () {
                                Get.toNamed(Routes.AUTH_MANAGE_USER);
                              },
                            )
                            : const SizedBox.shrink(),
                  ),
                  const Divider(),
                  _buildMenuItem(Icons.history, 'clear_history'.tr, () {
                    controller.clearHistory();
                  }),
                  _buildMenuItem(Icons.logout, 'logout'.tr, () {
                    controller.signOut();
                  }),
                  const SizedBox(height: 16),
                  Text(
                    '${'app_version'.tr} ${controller.appVersion}',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
