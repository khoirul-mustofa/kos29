import 'package:kos29/app/data/models/review_model.dart';
import 'package:kos29/app/data/models/user_model.dart';

class ReviewWithUserModel {
  final ReviewModel review;
  final UserModel user;

  ReviewWithUserModel({required this.review, required this.user});
}
