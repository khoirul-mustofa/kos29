import 'package:cloud_firestore/cloud_firestore.dart';

class KostUpdateRequestModel {
  final String id;
  final String kostId;
  final String userId;
  final Map<String, dynamic> requestedChanges;
  final String reason;
  final String status;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  KostUpdateRequestModel({
    required this.id,
    required this.kostId,
    required this.userId,
    required this.requestedChanges,
    required this.reason,
    required this.status,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KostUpdateRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KostUpdateRequestModel(
      id: doc.id,
      kostId: data['kostId'] as String,
      userId: data['userId'] as String,
      requestedChanges: Map<String, dynamic>.from(
        data['requestedChanges'] as Map,
      ),
      reason: data['reason'] as String,
      status: data['status'] as String,
      adminNote: data['adminNote'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kostId': kostId,
      'userId': userId,
      'requestedChanges': requestedChanges,
      'reason': reason,
      'status': status,
      'adminNote': adminNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
