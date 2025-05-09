import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Profile Image
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Obx(() {
                          if (controller.localImagePath != null) {
                            return Image.file(
                              File(controller.localImagePath!),
                              fit: BoxFit.cover,
                            );
                          }
                          if (controller.profileImageUrl.value.isNotEmpty) {
                            return CachedNetworkImage(
                              imageUrl: controller.profileImageUrl.value,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(color: Colors.white),
                                  ),
                              errorWidget:
                                  (context, url, error) => const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                            );
                          }
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          );
                        }),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Obx(() {
                            return controller.isUploadingImage.value
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                );
                          }),
                          onPressed:
                              controller.isUploadingImage.value
                                  ? null
                                  : controller.pickAndUploadImage,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Form Fields
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        buildTextInput(
                          controller: controller.nameController,
                          label: "Nama Lengkap",
                          icon: Icons.person,
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),
                        buildTextInput(
                          controller: controller.usernameController,
                          label: "Username",
                          icon: Icons.alternate_email,
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),
                        buildTextInput(
                          controller: controller.emailController,
                          label: "Email",
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        buildTextInput(
                          controller: controller.phoneController,
                          label: "Nomor HP",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),
                        // Gender Dropdown
                        DropdownButtonFormField<String>(
                          value: controller.gender.value,
                          decoration: InputDecoration(
                            labelText: "Jenis Kelamin",
                            prefixIcon: const Icon(Icons.people),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items:
                              controller.genderOptions
                                  .map(
                                    (gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.gender.value = value;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        buildTextInput(
                          controller: controller.birthDateController,
                          label: "Tanggal Lahir",
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              controller.birthDateController.text =
                                  '${date.day}/${date.month}/${date.year}';
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        buildTextInput(
                          controller: controller.occupationController,
                          label: "Pekerjaan",
                          icon: Icons.work,
                        ),
                        const SizedBox(height: 16),
                        buildTextInput(
                          controller: controller.addressController,
                          label: "Alamat",
                          icon: Icons.location_on,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        buildTextInput(
                          controller: controller.bioController,
                          label: "Bio",
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: controller.updateProfile,
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan Perubahan"),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Image Shimmer
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 32),
            // Form Fields Shimmer
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: List.generate(
                    9, // Updated to match number of fields
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Save Button Shimmer
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildTextInput({
  required TextEditingController controller,
  required String label,
  IconData? icon,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  int maxLines = 1,
  bool readOnly = false,
  VoidCallback? onTap,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    readOnly: readOnly,
    onTap: onTap,
    maxLines: maxLines,
    decoration: InputDecoration(
      prefixIcon: icon != null ? Icon(icon) : null,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
  );
}
