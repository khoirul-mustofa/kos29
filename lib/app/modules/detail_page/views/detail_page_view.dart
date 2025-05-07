import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kos29/app/helper/formater_helper.dart';

import '../controllers/detail_page_controller.dart';

class DetailPageView extends GetView<DetailPageController> {
  const DetailPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<DetailPageController>(
        builder: (controller) {
          return SafeArea(
            child: ListView(
              children: [
                // Gambar Kost dengan radius
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1726066012645-959fc63f61b4?w=500&auto=format&fit=crop&q=60',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.dataKost.nama,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Material(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            controller.launchMapOnAndroid(
                              context,
                              controller.dataKost.latitude,
                              controller.dataKost.longitude,
                            );
                          },
                          child: Container(
                            width: Get.width,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    controller.dataKost.alamat,
                                    style: TextStyle(color: Colors.grey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '  ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${controller.dataKost.jarak.round()} km',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text('4.5 | 100 ulasan'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text('3 Kamar Tersedia'),
                          const SizedBox(width: 4),
                        ],
                      ),
                      SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          text: FormatterHelper.formatHarga(
                            controller.dataKost.harga,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                            fontFamily:
                                'NotoSans', // pastikan font ini sudah di-setup
                          ),
                          children: [
                            TextSpan(
                              text: ' /bulan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Fasilitas
                      _sectionTitle('Fasilitas'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          children: [
                            _facilityIcon(Icons.tv, 'TV'),
                            _facilityIcon(Icons.wifi, 'WiFi'),
                            _facilityIcon(Icons.bed, 'Tempat Tidur'),
                            _facilityIcon(Icons.ac_unit, 'AC'),
                            _facilityIcon(Icons.kitchen, 'Dapur'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Kebijakan Properti
                      _sectionTitleWithLink('Kebijakan Properti'),
                      const SizedBox(height: 8),
                      _bulletText(
                        'Seluruh fasilitas kost hanya diperuntukkan bagi penyewa kamar.',
                      ),
                      _bulletText('Tidak menerima tamu di kamar kost.'),
                      _bulletText(
                        'Tidak diperkenankan merokok di dalam kamar.',
                      ),

                      const SizedBox(height: 24),
                      // Deskripsi Properti
                      _sectionTitleWithLink('Deskripsi Properti'),
                      const SizedBox(height: 8),
                      Text(
                        controller.dataKost.deskripsi,
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _facilityIcon(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _sectionTitleWithLink(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle(title),
        Text('Lihat semua', style: TextStyle(color: Colors.blue, fontSize: 13)),
      ],
    );
  }

  Widget _bulletText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
