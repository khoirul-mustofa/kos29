import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kost_page_controller.dart';

class KostPageView extends GetView<KostPageController> {
  const KostPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Kosan'), centerTitle: true),
      body: Obx(() {
        final kostList = controller.kosanList;
        if (kostList.isEmpty) {
          return const Center(child: Text('Belum ada kosan.'));
        }
        return RefreshIndicator(
          onRefresh: controller.loadKos,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kostList.length,
            itemBuilder: (context, index) {
              final kost = kostList[index];
              return Card(
                child: ListTile(
                  title: Text(kost['nama']),
                  subtitle: Text(kost['alamat']),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    controller.goToDetail(kost['id']);
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToAddKost,
        child: const Icon(Icons.add),
      ),
    );
  }
}
