import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/change_location_controller.dart';

class ChangeLocationView extends GetView<ChangeLocationController> {
  const ChangeLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Lokasi'), centerTitle: true),
      body: Stack(
        children: [
          // Map View
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: controller.currentLocation.value,
              initialZoom: 15,
              onTap: controller.onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kos29',
              ),
              MarkerLayer(markers: controller.markers),
            ],
          ),

          // Location Info Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lokasi Terpilih',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.selectedAddress.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.textController,
                      decoration: const InputDecoration(
                        labelText: 'Koordinat',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Buttons
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Lokasi Saya'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.saveLocation,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
