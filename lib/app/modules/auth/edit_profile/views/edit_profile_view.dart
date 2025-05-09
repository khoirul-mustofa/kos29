import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kos29/app/modules/management_kost/add_kost/views/management_kost_add_kost_view.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  EditProfileView({super.key});
  final controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Builder(
        builder:
            (context) => Obx(() {
              return controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      spacing: 16,
                      children: [
                        buildTextInput(
                          controller: controller.nameController,
                          label: "Nama",
                          icon: Icons.person,
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                        buildTextInput(
                          controller: controller.phoneController,
                          icon: Icons.phone,
                          label: "Nomor HP",
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: controller.updateProfile,
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  );
            }),
      ),
    );
  }
}
