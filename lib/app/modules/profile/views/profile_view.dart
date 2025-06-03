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
                  Obx(() {
                    if (controller.currentUser.value != null) {
                      return Center(
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
                                    controller.userData.value?['photo_url'] !=
                                                null &&
                                            controller
                                                .userData
                                                .value!['photo_url']
                                                .toString()
                                                .isNotEmpty
                                        ? CachedNetworkImage(
                                          imageUrl:
                                              controller
                                                  .userData
                                                  .value!['photo_url'],
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) =>
                                                  Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  const Icon(
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
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),

                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.currentUser.value != null) {
                      return Text(
                        controller.userData.value?['displayName'] ?? '---',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  const SizedBox(height: 4),
                  Obx(() {
                    if (controller.currentUser.value != null) {
                      return Text(
                        controller.userData.value?['email'] ?? '---',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),

                  const SizedBox(height: 8),

                  Obx(() {
                    if (controller.currentUser.value != null) {
                      return ElevatedButton(
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
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (controller.userRole.value == 'admin' ||
                        controller.userRole.value == 'user') {
                      return Column(
                        children: [
                          if (controller.userRole.value == 'admin')
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
                          if (controller.userRole.value == 'admin')
                            _buildMenuItem(
                              Icons.verified_outlined,
                              'Verifikasi Kos',
                              () {
                                Get.toNamed(Routes.KOS_REGISTRATION);
                              },
                              trailing: Obx(() {
                                if (controller
                                        .pendingKosRegistrationsCount
                                        .value >
                                    0) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      controller
                                          .pendingKosRegistrationsCount
                                          .value
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const Icon(Icons.chevron_right);
                              }),
                            ),
                          if (controller.userRole.value == 'admin')
                            _buildMenuItem(
                              Icons.update_outlined,
                              'Tinjau Pengajuan Perubahan',
                              () {
                                Get.toNamed(Routes.ADMIN_KOST_UPDATE_REQUESTS);
                              },
                              trailing: Obx(() {
                                if (controller
                                        .pendingUpdateRequestsCount
                                        .value >
                                    0) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      controller
                                          .pendingUpdateRequestsCount
                                          .value
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const Icon(Icons.chevron_right);
                              }),
                            ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),

                  Obx(() {
                    if (controller.userRole.value == "admin" ||
                        controller.userRole.value == "owner") {
                      return _buildMenuItem(
                        Icons.person_outline,
                        'Manage User',
                        () {
                          Get.toNamed(Routes.AUTH_MANAGE_USER);
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),

                  Obx(() {
                    if (controller.currentUser.value != null &&
                        controller.userRole.value != "admin") {
                      return ListTile(
                        title: Text('Daftarkan kosmu disini'),
                        leading: const Icon(Icons.add_business),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Get.toNamed(Routes.REGISTER_KOS);
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),

                  Obx(() {
                    if (controller.currentUser.value != null) {
                      return _buildMenuItem(
                        Icons.rate_review,
                        'my_reviews'.tr,
                        () {
                          Get.toNamed(Routes.MY_REVIEWS);
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),

                  _buildMenuItem(Icons.history, 'clear_history'.tr, () {
                    controller.clearHistory();
                  }),

                  const Divider(),
                  _buildMenuItem(Icons.info, 'about_app'.tr, () {
                    Get.toNamed(Routes.ABOUT_APP);
                  }),

                  Obx(() {
                    if (controller.userRole.value != "admin" &&
                        controller.currentUser.value != null) {
                      return ListTile(
                        leading: const Icon(Icons.edit_document),
                        title: const Text('Pengajuan Perubahan Kost'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Pilih Kost'),
                                  content: const Text(
                                    'Silakan pilih kost yang ingin diubah datanya',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        Get.toNamed(
                                          Routes.KOST_PAGE,
                                          arguments: {
                                            'isForUpdateRequest': true,
                                          },
                                        );
                                      },
                                      child: const Text('Pilih Kost'),
                                    ),
                                  ],
                                ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),

                  Obx(() {
                    if (controller.currentUser.value != null) {
                      return _buildMenuItem(Icons.logout, 'logout'.tr, () {
                        controller.signOut();
                      });
                    } else {
                      return _buildMenuItem(Icons.login, 'login'.tr, () {
                        Get.toNamed(Routes.SIGN_IN);
                      });
                    }
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Function() onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
