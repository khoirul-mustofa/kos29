import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kos29/app/data/models/kost_update_request_model.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:uuid/uuid.dart';

class KostUpdateRequestService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Submit new update request
  Future<String> submitUpdateRequest({
    required String kostId,
    required Map<String, dynamic> requestedChanges,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final requestId = const Uuid().v4();
      final request = KostUpdateRequestModel(
        id: requestId,
        kostId: kostId,
        userId: user.uid,
        status: 'pending',
        requestedChanges: requestedChanges,
        reason: 'Update request',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('kost_update_requests')
          .doc(requestId)
          .set(request.toMap());

      return requestId;
    } catch (e) {
      logger.e('Error submitting update request: $e');
      rethrow;
    }
  }

  // Get update requests for a specific kost
  Stream<List<KostUpdateRequestModel>> getKostUpdateRequests(String kostId) {
    return _firestore
        .collection('kost_update_requests')
        .where('kostId', isEqualTo: kostId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => KostUpdateRequestModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get update requests for current user
  Stream<List<KostUpdateRequestModel>> getUserUpdateRequests() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('kost_update_requests')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => KostUpdateRequestModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get all pending update requests (for admin)
  Stream<List<KostUpdateRequestModel>> getPendingUpdateRequests() {
    return _firestore
        .collection('kost_update_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => KostUpdateRequestModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Update request status (for admin)
  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? adminNote,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updates = {
        'status': status,
        'adminNote': adminNote,
        'reviewedBy': user.uid,
        'reviewedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      await _firestore
          .collection('kost_update_requests')
          .doc(requestId)
          .update(updates);

      // If approved, update the kost data
      if (status == 'approved') {
        final requestDoc =
            await _firestore
                .collection('kost_update_requests')
                .doc(requestId)
                .get();

        if (requestDoc.exists) {
          final request = KostUpdateRequestModel.fromFirestore(requestDoc);

          // Update kost data with requested changes
          await _firestore
              .collection('kosts')
              .doc(request.kostId)
              .update(request.requestedChanges);
        }
      }
    } catch (e) {
      logger.e('Error updating request status: $e');
      rethrow;
    }
  }

  // Cancel update request (for user)
  Future<void> cancelUpdateRequest(String requestId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final requestDoc =
          await _firestore
              .collection('kost_update_requests')
              .doc(requestId)
              .get();

      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      final request = KostUpdateRequestModel.fromFirestore(requestDoc);

      if (request.userId != user.uid) {
        throw Exception('Not authorized to cancel this request');
      }

      if (request.status != 'pending') {
        throw Exception('Can only cancel pending requests');
      }

      await _firestore
          .collection('kost_update_requests')
          .doc(requestId)
          .delete();
    } catch (e) {
      logger.e('Error canceling update request: $e');
      rethrow;
    }
  }
}
