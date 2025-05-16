import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kos29/app/data/models/kost_model.dart';
import 'package:kos29/app/routes/app_pages.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/notification_model.dart';
import '../controllers/notifications_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              controller.markAllAsRead();
              Get.snackbar(
                'Info',
                'Semua notifikasi telah ditandai sebagai dibaca',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Tandai semua sebagai dibaca',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer();
        }
        
        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildNotificationList();
      }),
    );
  }
  
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationList() {
    return ListView.builder(
      itemCount: controller.notifications.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final notification = controller.notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }
  
  Widget _buildNotificationCard(NotificationModel notification) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(notification.createdAt);
    
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        controller.deleteNotification(notification.id);
        Get.snackbar(
          'Info',
          'Notifikasi dihapus',
          snackPosition: SnackPosition.TOP,
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            controller.markAsRead(notification.id);
          }
          
          // Handle navigation based on notification type
          if (notification.payload != null && notification.payload!.isNotEmpty) {
            Get.toNamed(notification.payload!);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationTypeIcon(notification.type),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 163, 155, 155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (notification.type == 'kost_release' && notification.relatedId != null)
                      _buildKostReleaseActions(notification.relatedId!),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotificationTypeIcon(String? type) {
    IconData iconData;
    Color iconColor;
    
    switch (type) {
      case 'kost_release':
        iconData = Icons.home;
        iconColor = Colors.green;
        break;
      case 'payment':
        iconData = Icons.payment;
        iconColor = Colors.blue;
        break;
      case 'message':
        iconData = Icons.message;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
  
  Widget _buildKostReleaseActions(String kostId) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () async {
              // Fetch kost data first
              final kostDoc = await FirebaseFirestore.instance
                  .collection('kosts')
                  .doc(kostId)
                  .get();
              
              if (kostDoc.exists) {
                final kostModel = KostModel.fromMap({
                  'idKos': kostDoc.id,
                  ...kostDoc.data()!
                });
                // Navigate to kost detail with the model
                Get.toNamed(Routes.DETAIL_PAGE, arguments: kostModel);
              } else {
                Get.snackbar(
                  'Error',
                  'Data kos tidak ditemukan',
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Lihat Kos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () async {
              // Fetch kost data first
              final kostDoc = await FirebaseFirestore.instance
                  .collection('kosts')
                  .doc(kostId)
                  .get();
              
              if (kostDoc.exists) {
                final kostModel = KostModel.fromMap({
                  'idKos': kostDoc.id,
                  ...kostDoc.data()!
                });
                
                // Create share text
                final shareText = '''
🏠 ${kostModel.nama}
💰 Rp ${NumberFormat('#,###', 'id_ID').format(kostModel.harga)}/bulan
📍 ${kostModel.alamat}
🏢 Tipe: ${kostModel.jenis}
🛏️ Kamar tersedia: ${kostModel.kamarTersedia}

Lihat detail kos ini di aplikasi Kos29!
''';
                
                // Share using the new SharePlus API
                try {
                  final result = await SharePlus.instance.share(
                    ShareParams(
                      text: shareText,
                      subject: 'Info Kos: ${kostModel.nama}'
                    )
                  );

                  if (result.status == ShareResultStatus.success) {
                    Get.snackbar(
                      'Sukses',
                      'Informasi kos berhasil dibagikan',
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Gagal membagikan informasi kos',
                    snackPosition: SnackPosition.TOP,
                  );
                }
              } else {
                Get.snackbar(
                  'Error',
                  'Data kos tidak ditemukan',
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Bagikan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
