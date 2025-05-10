import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageUserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredUsers =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'all'.obs;
  final RxString selectedUserRole = 'user'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      users.value =
          snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              })
              .where((user) => user['id'] != currentUser.uid)
              .toList();
      filterUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil data pengguna',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      filterUsers();
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    filteredUsers.value =
        users.where((user) {
          final name = user['displayName']?.toString().toLowerCase() ?? '';
          final email = user['email']?.toString().toLowerCase() ?? '';
          return name.contains(lowercaseQuery) ||
              email.contains(lowercaseQuery);
        }).toList();
  }

  void filterByRole(String role) {
    selectedRole.value = role;
    filterUsers();
  }

  void filterUsers() {
    if (selectedRole.value == 'all') {
      filteredUsers.value = users;
    } else {
      filteredUsers.value =
          users.where((user) => user['role'] == selectedRole.value).toList();
    }
  }

  Future<void> addUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedUserRole.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.back(); // Close dialog
      Get.snackbar(
        'Berhasil',
        'Pengguna berhasil ditambahkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear form
      nameController.clear();
      emailController.clear();
      passwordController.clear();

      // Refresh user list
      fetchUsers();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah';
          break;
        default:
          message = 'Terjadi kesalahan. Silakan coba lagi';
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    try {
      isLoading.value = true;

      await _firestore.collection('users').doc(user['id']).update({
        'name': nameController.text.trim(),
        'role': selectedUserRole.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.back(); // Close dialog
      Get.snackbar(
        'Berhasil',
        'Data pengguna berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear form
      nameController.clear();
      emailController.clear();

      // Refresh user list
      fetchUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui data pengguna',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;

      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();

      Get.snackbar(
        'Berhasil',
        'Pengguna berhasil dihapus',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      fetchUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus pengguna',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showAddUserDialog() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    selectedUserRole.value = 'user';

    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Pengguna'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedUserRole.value,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                ],
                onChanged: (value) {
                  if (value != null) selectedUserRole.value = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(onPressed: addUser, child: const Text('Tambah')),
        ],
      ),
    );
  }

  void editUser(Map<String, dynamic> user) {
    nameController.text = user['name'] ?? '';
    emailController.text = user['email'] ?? '';
    selectedUserRole.value = user['role'] ?? 'user';

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Pengguna'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Email cannot be changed
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedUserRole.value,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                ],
                onChanged: (value) {
                  if (value != null) selectedUserRole.value = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => updateUser(user),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      isLoading.value = true;
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Berhasil',
        'Role pengguna berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      fetchUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui role pengguna',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showRoleUpdateDialog(Map<String, dynamic> user) {
    selectedUserRole.value = user['role'] ?? 'user';

    Get.dialog(
      AlertDialog(
        title: const Text('Update Role Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update role untuk ${user['displayName']}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedUserRole.value,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'user', child: Text('User')),
              ],
              onChanged: (value) {
                if (value != null) selectedUserRole.value = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              updateUserRole(user['id'], selectedUserRole.value);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmationDialog(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengguna ${user['displayName']}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteUser(user['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
