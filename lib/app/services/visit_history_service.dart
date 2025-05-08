import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:path_provider/path_provider.dart';

class VisitHistoryService {
  final String _fileName = 'visit_history.json';

  // Ambil path file lokal
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    // Jika belum ada, buat file kosong
    if (!file.existsSync()) {
      await file.writeAsString(jsonEncode([]));
    }

    return file;
  }

  // Simpan kunjungan baru
  Future<void> saveVisit(String kostId) async {
    try {
      final file = await _getFile();
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);

      // Hindari duplikat
      if (!jsonList.contains(kostId)) {
        jsonList.add({
          'kostId': kostId,
          'visitedAt': DateTime.now().toIso8601String(),
        });
        await file.writeAsString(jsonEncode(jsonList));
      }
      if (kDebugMode) {
        logger.d('✅ Visit saved: $kostId');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.e('⛔ Error saving visit: $e');
      }
    }
  }

  // Ambil semua ID kost yang pernah dikunjungi

  Future<List<Map<String, String>>> getVisitedKosts() async {
    final file = await _getFile();
    final content = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    if (kDebugMode) {
      logger.d('✅ Visited IDs: ${jsonList.length}');
      logger.i('data jsonList: $jsonList');
    }
    return jsonList
        .map(
          (e) => {
            "kostId": e['kostId'] as String,
            "visitedAt": e['visitedAt'] as String,
          },
        )
        .toList();
  }

  // (Opsional) Hapus riwayat
  Future<void> clearHistory() async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode([]));
    if (kDebugMode) {
      logger.d('✅ History cleared');
    }
  }
}
