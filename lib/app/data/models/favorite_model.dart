import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String? id;
  final String kostId;
  final String uid;
  final DateTime createdAt;

  FavoriteModel({
    this.id,
    required this.kostId,
    required this.uid,
    required this.createdAt,
  });

  factory FavoriteModel.fromDoc(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return FavoriteModel(
      id: doc.id,
      kostId: json['kost_id'],
      uid: json['uid'],
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'kost_id': kostId,
    'uid': uid,
    'created_at': createdAt,
  };
}
