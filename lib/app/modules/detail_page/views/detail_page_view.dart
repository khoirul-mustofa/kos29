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
                        controller.dataKost.gambar,
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${controller.dataKost.distance.toStringAsFixed(2)} km',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            TextSpan(
                              text: ' dari lokasi Anda',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
                            fontFamily: 'NotoSans',
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

                      // Fasilitas
                      _sectionTitleWithLink('Fasilitas', 'fasilitas'),
                      SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            controller.isFasilitasExpanded
                                ? controller.dataKost.fasilitas.length
                                : controller.dataKost.fasilitas.length.clamp(
                                  0,
                                  3,
                                ),
                            (index) {
                              return SizedBox(
                                width: Get.width,
                                child: Text(
                                  '${index + 1}. ${controller.dataKost.fasilitas[index]}',
                                  style: TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines:
                                      controller.isFasilitasExpanded ? null : 1,
                                  textAlign: TextAlign.left,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Kebijakan Properti
                      _sectionTitleWithLink('Kebijakan Properti', 'kebijakan'),
                      if (controller.isKebijakanExpanded)
                        ...List.generate(10, (index) {
                          return _bulletText(
                            'Seluruh fasilitas kost hanya diperuntukkan bagi penyewa kamar.',
                          );
                        })
                      else
                        _bulletText(
                          'Seluruh fasilitas kost hanya diperuntukkan bagi penyewa kamar.',
                        ),

                      // Deskripsi Properti
                      _sectionTitleWithLink('Deskripsi Properti', 'deskripsi'),
                      Text(
                        controller.dataKost.deskripsi,
                        style: TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: controller.isDeskripsiExpanded ? null : 3,
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

  Widget _sectionTitleWithLink(String title, String key) {
    bool isExpanded = false;

    if (key == 'fasilitas') {
      isExpanded = controller.isFasilitasExpanded;
    } else if (key == 'deskripsi') {
      isExpanded = controller.isDeskripsiExpanded;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () {
            controller.toggleiExpanded(key);
          },
          child: Text(
            isExpanded ? 'Sembunyikan' : 'Lihat semua',
            style: TextStyle(color: Colors.blue, fontSize: 13),
          ),
        ),
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
