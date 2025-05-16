import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> saveFcmTokenNoAuth() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    // Simpan token ke koleksi  
    await FirebaseFirestore.instance.collection('tokens').doc(fcmToken).set({
      'token': fcmToken,
      'createdAt': DateTime.now(),
    });
  }
}