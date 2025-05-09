import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String userId;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final String kostId;
  final bool hidden;
  final String? ownerResponse;

  ReviewModel({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.timestamp,
    required this.kostId,
    required this.hidden,
    required this.ownerResponse,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    userId: json['userId'],
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'],
    timestamp: (json['timestamp'] as Timestamp).toDate(),
    kostId: json['kostId'],
    hidden: json['hidden'],
    ownerResponse: json['ownerResponse'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'timestamp': timestamp,
    'kostId': kostId,
    'hidden': hidden,
    'ownerResponse': ownerResponse,
  };
}
