import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/helper/formater_helper.dart';
import 'package:kos29/app/modules/search_page/controllers/search_page_controller.dart';

class CardKost extends StatelessWidget {
  final KostModel kost;
  const CardKost({Key? key, required this.kost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchPageController());

    return GestureDetector(
      onTap: () => controller.gotoDetailPage(kost),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar kos
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child:
                  kost.gambar.isNotEmpty
                      ? Image.network(
                        kost.gambar,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                      )
                      : Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.home, size: 48)),
                      ),
            ),

            // Informasi utama
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama kost
                  Text(
                    kost.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Harga dan jenis kos
                  Row(
                    children: [
                      Text(
                        FormatterHelper.formatHarga(kost.harga),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          kost.jenis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Jarak (opsional)
                  if (kost.distance > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${kost.distance.toStringAsFixed(2)} km dari kamu",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
