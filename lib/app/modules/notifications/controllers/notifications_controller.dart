import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../services/notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService = Get.find<NotificationService>();
  
  // Observable list of notifications
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Unread count
  final RxInt unreadCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    print('NotificationsController onInit');
    _loadNotifications();
    // _listenToUnreadCount();
  }
  
  // Load notifications
  void _loadNotifications() {
    print('Load notifications dipanggil');
    isLoading.value = true;
    _notificationService.getUserNotifications().listen((notificationsList) {
      final uniqueNotifications = <String, NotificationModel>{};
      for (var notif in notificationsList) {
        uniqueNotifications[notif.id] = notif;
      }
      notifications.value = uniqueNotifications.values.toList();
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load notifications');
    });
  }
  
  // Listen to unread count
  void _listenToUnreadCount() {
    _notificationService.getUnreadNotificationCount().listen((count) {
      unreadCount.value = count;
    });   
  }
  
  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markNotificationAsRead(notificationId);
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _notificationService.markAllNotificationsAsRead();
  }
  
  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
  }
  
  // Get notification type icon
  String getNotificationTypeIcon(String? type) {
    switch (type) {
      case 'kost_release':
        return 'assets/icons/home.png'; 
      case 'payment':
        return 'assets/icons/payment.png';
      case 'message':
        return 'assets/icons/message.png';
      default:
        return 'assets/icons/notification.png';
    }
  }
}
