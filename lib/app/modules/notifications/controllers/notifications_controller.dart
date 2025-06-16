import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';


class NotificationsController extends GetxController {

  
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
   
  }
  
  // Listen to unread count
  void _listenToUnreadCount() {
   
  }
  
  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    
  }
  
  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
   
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
}
