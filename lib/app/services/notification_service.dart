import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../data/models/notification_model.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final logger = Logger();
  final Uuid _uuid = const Uuid();
  
  // Topic for new boarding house notifications
  static const String NEW_KOST_TOPIC = 'new_kost_notifications';
  
  // Observable for unread notifications count
  final RxInt unreadCount = 0.obs;

  Future<NotificationService> init() async {
    // Request permission for notifications
    await _requestPermission();
    
    // Initialize local notifications
    await _initLocalNotifications();
    
    // Subscribe to new kost notifications topic
    await subscribeToTopic(NEW_KOST_TOPIC);
    
    // Handle FCM messages
    _setupFirebaseMessaging();
    
    // Start listening to unread count
    _listenToUnreadCount();
    
    return this;
  }

  void _listenToUnreadCount() {
    getUnreadNotificationCount().listen((count) {
      unreadCount.value = count;
    });
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      logger.d('User granted permission: ${settings.authorizationStatus}');
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (kDebugMode) {
          logger.d('Notification tapped: ${response.payload}');
        }
      },
    );
  }

  void _setupFirebaseMessaging() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        logger.d('Got a message whilst in the foreground!');
        logger.d('Message data: ${message.data}');
      }

      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Handle when app is opened from a notification when the app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        logger.d('Notification opened app: ${message.data}');
      }
      // Handle navigation if needed based on message data
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // Show local notification
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'kos29_channel',
            'Kos29 Notifications',
            channelDescription: 'Notification channel for Kos29 app',
            importance: Importance.max,
            priority: Priority.high,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['route'],
      );
      
      // Save notification to Firestore
      await _saveNotificationToFirestore(
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: message.data['route'],
        type: message.data['type'],
        relatedId: message.data['relatedId'],
      );
    }
  }

  // Method to show a local notification without FCM
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? type,
    String? relatedId,
  }) async {
    // Show local notification
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'kos29_channel',
          'Kos29 Notifications',
          channelDescription: 'Notification channel for Kos29 app',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
    
    // Save notification to Firestore
    await _saveNotificationToFirestore(
      title: title,
      body: body,
      payload: payload,
      type: type,
      relatedId: relatedId,
    );
  }

  // Get FCM token for the device
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
  
  // Save notification to Firestore
  Future<void> _saveNotificationToFirestore({
    required String title,
    required String body,
    String? payload,
    String? type,
    String? relatedId,
  }) async {
    try {
      // Get current user ID
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        logger.w('Cannot save notification: No user logged in');
        return;
      }
      
      final String notificationId = _uuid.v4();
      final NotificationModel notification = NotificationModel(
        id: notificationId,
        title: title,
        body: body,
        payload: payload,

        createdAt: DateTime.now(),
        isRead: false,
        type: type ?? 'general',
        relatedId: relatedId,
      );
      
      // Save to Firestore
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toMap());
      
      if (kDebugMode) {
        logger.d('Notification saved to Firestore: $notificationId');
      }
    } catch (e) {
      logger.e('Error saving notification to Firestore: $e');
    }
  }
  
  // Get user notifications from Firestore
  Stream<List<NotificationModel>> getUserNotifications() {
    // final User? currentUser = _auth.currentUser;
    // if (currentUser == null) {
    //   return Stream.value([]);
    // }
    
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      logger.e('Error marking notification as read: $e');
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();
      
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      logger.e('Error marking all notifications as read: $e');
    }
  }
  
  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      logger.e('Error deleting notification: $e');
    }
  }
  
  // Get unread notification count
  Stream<int> getUnreadNotificationCount() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0);
    }
    
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Method to broadcast a notification to all users about a new boarding house
  Future<void> broadcastNewKostNotification({
    required String kostId,
    required String kostName,
    required String route,
  }) async {
    try {
      // Get all user documents from Firestore
      // final userDocs = await _firestore.collection('users').get();
      
      // Create a batch write
      final batch = _firestore.batch();
      final notificationId = _uuid.v4();
        final notification = NotificationModel(
          id: notificationId,
          title: 'Kos Baru Tersedia',
          body: 'Kos baru $kostName telah ditambahkan! Ayo kunjungi sekarang!',
          payload: route,

          createdAt: DateTime.now(),
          isRead: false,
          type: 'kost_release',
          relatedId: kostId,
        );
        
        // Add notification to batch
        batch.set(
          _firestore.collection('notifications').doc(notificationId),
          notification.toMap(),
        );
   
      
      // Commit the batch
      await batch.commit();
      
      if (kDebugMode) {
        logger.d('Broadcast notification sent successfully');
      }
    } catch (e) {
      logger.e('Error broadcasting notification: $e');
    }
  }
}


