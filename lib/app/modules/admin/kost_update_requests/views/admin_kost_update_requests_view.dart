import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kos29/app/modules/admin/kost_update_requests/controllers/admin_kost_update_requests_controller.dart';

class AdminKostUpdateRequestsView
    extends GetView<AdminKostUpdateRequestsController> {
  const AdminKostUpdateRequestsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tinjau Pengajuan Perubahan')),
      body: Obx(() {
        if (controller.requests.isEmpty) {
          return const Center(
            child: Text('Tidak ada pengajuan yang perlu ditinjau'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.requests.length,
          itemBuilder: (context, index) {
            final request = controller.requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => controller.showReviewDialog(request),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pengajuan #${request.id.substring(0, 8)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: controller
                                  .getStatusColor(request.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.getStatusText(request.status),
                              style: TextStyle(
                                color: controller.getStatusColor(
                                  request.status,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Diajukan pada: ${request.createdAt.toLocal().toString().split('.')[0]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Perubahan yang diajukan:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...request.requestedChanges.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: Text(
                            '• ${entry.key}: ${entry.value}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      if (request.requestedChanges.containsKey('alasan')) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Alasan perubahan:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.requestedChanges['alasan'] as String,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                () => controller.showReviewDialog(request),
                            child: const Text('Tinjau'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
