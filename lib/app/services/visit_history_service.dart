import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:kos29/app/helper/logger_app.dart';
import 'package:path_provider/path_provider.dart';

class VisitHistoryService {
  final String _fileName = 'visit_history.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    if (!file.existsSync()) {
      await file.writeAsString(jsonEncode([]));
    }

    return file;
  }

  Future<void> saveVisit(String kostId) async {
    try {
      final file = await _getFile();
      final content = await file.readAsString();

      final List<dynamic> jsonList =
          content.isNotEmpty ? jsonDecode(content) : [];

      jsonList.removeWhere((item) => item['kostId'] == kostId);

      jsonList.add({
        'kostId': kostId,
        'visitedAt': DateTime.now().toIso8601String(),
      });

      await file.writeAsString(jsonEncode(jsonList));

      if (kDebugMode) {
        log('✅ Visit saved: $kostId');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.e('⛔ Error saving visit: $e');
      }
    }
  }

  Future<List<Map<String, String>>> getVisitedKosts() async {
    final file = await _getFile();
    final content = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    if (kDebugMode) {
      log('✅ Visited IDs: ${jsonList.length}');
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
      log('✅ History cleared');
    }
  }
}
