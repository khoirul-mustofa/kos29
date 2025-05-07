import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kos29/app/modules/home/controllers/home_controller.dart';

import '../controllers/detail_page_controller.dart';

class DetailPageView extends GetView<DetailPageController> {
  const DetailPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Get.find<HomeController>().ambilKunjunganTerakhir();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            children: [
              // Gambar Kost
              Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1726066012645-959fc63f61b4?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxfHx8ZW58MHx8fHx8',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ],
              ),

              // Informasi Kost
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kost Aisyah Plaju, Palembang',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 18),
                        const SizedBox(width: 4),
                        Text('Plaju, Palembang'),
                        Spacer(),
                        Text(
                          'Rp 1.000.000 /Perbulan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text('4.5/5 (100 reviewers)'),
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        const SizedBox(width: 4),
                        Text('3 Tersedia'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fasilitas',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: Get.width,
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        children: List.generate(
                          4,
                          (index) => _facilityIcon(Icons.tv, 'TV'),
                        ),
                      ),
                    ),
                    // Fasilitas

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     _facilityIcon(Icons.tv, 'TV'),
                    //     _facilityIcon(Icons.wifi, 'WiFi'),
                    //     _facilityIcon(Icons.bed, 'Tempat Tidur'),
                    //     _facilityIcon(Icons.ac_unit, 'AC'),
                    //     _facilityIcon(Icons.ac_unit, 'AC'),
                    //     _facilityIcon(Icons.bed, 'Tempat Tidur'),
                    //   ],
                    // ),
                    const SizedBox(height: 16),

                    // Kebijakan Properti
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kebijakan Properti',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Lihat semua',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Seluruh fasilitas kost hanya diperuntukkan bagi penyewa kamar.\n'
                      '2. Tidak menerima tamu di kamar kost.\n'
                      '3. Tidak diperkenankan merokok di dalam kamar.',
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi Properti
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deskripsi Properti',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Lihat semua',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Kost nyaman dan aman dengan CCTV 24 jam.'),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: ElevatedButton(
        //     onPressed: () {},
        //     style: ElevatedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //       // backgroundColor: Colors.blueAccent,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //     child: Text('Pesan Kost'),
        //   ),
        // ),
      ),
    );
  }

  Widget _facilityIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
