import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/about_app_controller.dart';

class AboutAppView extends GetView<AboutAppController> {
  const AboutAppView({super.key});
  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Gagal membuka tautan', 'Tidak dapat membuka $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo dan Nama Aplikasi
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(
                  'assets/logo/logo-kos29.png',
                ), // ganti dengan logomu
              ),
              const SizedBox(height: 12),
              const Text(
                'Kos29',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() {
                return Text(
                  '${'app_version'.tr} ${controller.appVersion.value}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                );
              }),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // _launchUrl('https://forms.gle/2f1jV4F6T4Qs4kD57');
                  Get.toNamed(Routes.FEEDBACK);
                },
                child: const Text('Berikan Feedback'),
              ),

              const SizedBox(height: 10),
            ],
          ),

          const Divider(),

          // Deskripsi Aplikasi
          const Text(
            'Kos29 adalah aplikasi pencarian kost berbasis lokasi yang memudahkan pengguna menemukan kost terbaik dengan rekomendasi cerdas berdasarkan jarak dan preferensi.',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),

          const Text(
            'Fitur Utama:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.search),
            title: Text('Pencarian kost berdasarkan lokasi pengguna'),
          ),
          const ListTile(
            leading: Icon(Icons.map),
            title: Text(
              'Menggunakan algoritma Haversine untuk menghitung jarak',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.recommend),
            title: Text(
              'Rekomendasi kost dengan metode K-Nearest Neighbors (KNN)',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.rate_review),
            title: Text('Tersedia fitur ulasan dan penilaian dari pengguna'),
          ),

          const Divider(height: 32),

          const Text(
            'Informasi Pengembang:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Khoirul Mustofa'),
            subtitle: const Text('Developer Aplikasi'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('khoirulmustofa102@gmail.com'),
            onTap: () => _launchUrl('mailto:khoirulmustofa102@gmail.com'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('GitHub - Kos29'),
            onTap: () => _launchUrl('https://github.com/khoirul-mustofa/kos29'),
          ),
        ],
      ),
    );
  }
}
