import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String? id;
  final String userId;
  final double rating;
  final String comment;
  final String kostId;
  final bool hidden;
  final String? ownerResponse;
  final String ownerId;
  final DateTime createdAt;

  ReviewModel({
    this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.kostId,
    required this.hidden,
    required this.ownerResponse,
    required this.ownerId,
    required this.createdAt,
  });

  factory ReviewModel.fromDoc(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: json['userId'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      kostId: json['kostId'],
      hidden: json['hidden'],
      ownerResponse: json['ownerResponse'],
      ownerId: json['ownerId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'rating': rating,
    'comment': comment,

    'kostId': kostId,
    'hidden': hidden,
    'ownerResponse': ownerResponse,
    'createdAt': createdAt,
  };
}
