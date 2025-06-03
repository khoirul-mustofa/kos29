import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kos29/app/helper/logger_app.dart';
import '../data/models/kos_registration.dart';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload a single file and return its download URL
  Future<String> uploadFile(XFile file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(File(file.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      logger.e('uploudFile: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  // Upload multiple files and return their download URLs
  Future<List<String>> uploadFiles(List<XFile> files, String basePath) async {
    try {
      final urls = <String>[];
      for (var i = 0; i < files.length; i++) {
        final path = '$basePath/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final url = await uploadFile(files[i], path);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      logger.e('uploudFiles: $e');
      throw Exception('Failed to upload files: $e');
    }
  }

  // Save kos registration to Firestore
  Future<void> saveKosRegistration(KosRegistration registration) async {
    try {
      if (registration.id == null) {
        throw Exception('Registration ID is required');
      }
      await _firestore
          .collection('kos_registrations')
          .doc(registration.id)
          .set(registration.toJson());
    } catch (e) {
      logger.e('saveKosRegistration: $e');
      throw Exception('Failed to save registration: $e');
    }
  }
} 