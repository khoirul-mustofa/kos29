import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/manage_user_controller.dart';

class ManageUserView extends GetView<ManageUserController> {
  const ManageUserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari pengguna...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchUsers('');
                      },
                    ),
                  ),
                  onChanged: controller.searchUsers,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'all'),
                      _buildFilterChip('Admin', 'admin'),
                      _buildFilterChip('User', 'user'),
                      // _buildFilterChip('Owner', 'owner'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/Animation-empty.json',
                        height: 200,
                        repeat: true,
                        animate: true,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.people_outline,
                            size: 100,
                            color: Colors.grey,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada pengguna ditemukan',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(user['role']),
                        child:
                            user['photoURL'] != null
                                ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user['photoURL'],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Text(
                                          user['displayName']?[0]
                                                  .toUpperCase() ??
                                              '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                  ),
                                )
                                : Text(
                                  user['displayName']?[0].toUpperCase() ?? '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                      ),
                      title: Text(
                        user['displayName'] ?? 'Nama tidak tersedia',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        user['email'] ?? 'Email tidak tersedia',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'edit_role',
                                child: Row(
                                  children: [
                                    Icon(Icons.admin_panel_settings, size: 20),
                                    SizedBox(width: 8),
                                    Text('Ubah Role'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        onSelected: (value) {
                          if (value == 'edit_role') {
                            controller.showRoleUpdateDialog(user);
                          } else if (value == 'delete') {
                            controller.showDeleteConfirmationDialog(user);
                          }
                        },
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                'Role',
                                _getRoleLabel(user['role']),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Tanggal Dibuat',
                                _formatTimestamp(user['created_at']),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Terakhir Diperbarui',
                                _formatTimestamp(user['updatedAt']),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'ID',
                                user['id'] ?? 'Tidak tersedia',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddUserDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Tidak tersedia';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    }
    return 'Tidak tersedia';
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.amber;
      case 'user':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'user':
        return 'Pengguna';
      default:
        return 'Tidak diketahui';
    }
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Obx(
        () => FilterChip(
          label: Text(label),
          selected: controller.selectedRole.value == value,
          onSelected: (selected) {
            if (selected) {
              controller.filterByRole(value);
            }
          },
          selectedColor: Colors.teal.withOpacity(0.2),
          checkmarkColor: Colors.teal,
          labelStyle: TextStyle(
            color:
                controller.selectedRole.value == value
                    ? Colors.teal
                    : Colors.black87,
          ),
        ),
      ),
    );
  }
}
