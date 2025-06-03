import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? payload;

  final DateTime createdAt;
  final bool isRead;
  final String? type;
  final String? relatedId; // ID of related item (e.g., kost ID)

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.payload,

    required this.createdAt,
    this.isRead = false,
    this.type,
    this.relatedId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,

      'createdAt': createdAt,
      'isRead': isRead,
      'type': type,
      'relatedId': relatedId,
    };
  }

  // Create from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      payload: data['payload'],

      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      type: data['type'],
      relatedId: data['relatedId'],
    );
  }

  // Create a copy with modifications
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? payload,

    DateTime? createdAt,
    bool? isRead,
    String? type,
    String? relatedId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,

      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}
