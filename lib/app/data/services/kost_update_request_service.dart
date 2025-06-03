import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kos29/app/data/models/kost_update_request_model.dart';

class KostUpdateRequestService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _collection = 'kost_update_requests';

  Future<List<KostUpdateRequestModel>> getRequestsByKostId(
    String kostId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('kostId', isEqualTo: kostId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => KostUpdateRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get requests: $e');
    }
  }

  Future<void> submitRequest({
    required String kostId,
    required Map<String, dynamic> requestedChanges,
    required String reason,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final request = KostUpdateRequestModel(
        id: _firestore.collection(_collection).doc().id,
        kostId: kostId,
        userId: userId,
        requestedChanges: requestedChanges,
        reason: reason,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(request.id)
          .set(request.toMap());
    } catch (e) {
      throw Exception('Failed to submit request: $e');
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to cancel request: $e');
    }
  }
}
