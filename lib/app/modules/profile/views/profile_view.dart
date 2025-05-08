import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});
  @override
  final controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(
                          '${controller.currentUser?.photoURL}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Name and Email
                Text(
                  controller.currentUser?.displayName ?? '---',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.currentUser?.email ?? '---',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // Edit Profile Button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade50,
                    minimumSize: const Size(100, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                const SizedBox(height: 24),

                const Divider(),
                _buildMenuItem(Icons.language, 'Languages', () {}),
                _buildMenuItem(Icons.location_on_outlined, 'Location', () {}),
                _buildMenuItem(Icons.apartment_outlined, 'Your Kos', () {
                  Get.toNamed(Routes.KOST_PAGE);
                }),
                const Divider(),
                _buildMenuItem(Icons.delete_outline, 'Clear Cache', () {}),
                _buildMenuItem(Icons.history, 'Clear History', () {
                  controller.clearHistory();
                }),
                _buildMenuItem(Icons.logout, 'Log Out', () {
                  controller.signOut();
                }),
                const SizedBox(height: 16),
                // App Version
                const Text(
                  'App Version 0.0.1',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
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
