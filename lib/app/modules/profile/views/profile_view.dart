import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:shimmer/shimmer.dart';

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
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child:
                                controller.userData?['photo_url'] != null &&
                                        controller.userData!['photo_url']
                                            .toString()
                                            .isNotEmpty
                                    ? CachedNetworkImage(
                                      imageUrl:
                                          controller.userData!['photo_url'],
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              color: Colors.white,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => const Icon(
                                            Icons.person,
                                            size: 45,
                                            color: Colors.grey,
                                          ),
                                    )
                                    : const Icon(
                                      Icons.person,
                                      size: 45,
                                      color: Colors.grey,
                                    ),
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
                  // const SizedBox(height: 24),

                  // _buildMenuItem(Icons.location_on_outlined, 'location'.tr, () {
                  //   Get.toNamed(Routes.CHANGE_LOCATION);
                  // }),
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
  
  Widget _buildMenuItemWithBadge(IconData icon, String title, int badgeCount, Function() onTap) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon),
          if (badgeCount > 0)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
