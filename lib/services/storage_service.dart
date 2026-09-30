import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_item.dart';

class StorageService {
  static const String _recentDocsKey = 'recent_documents_v1';

  static Future<List<DocumentItem>> getRecentDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentDocsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
      final items = list
          .map((item) => DocumentItem.fromMap(item as Map<String, dynamic>))
          .toList();

      // Sort by lastOpened descending
      items.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
      return items;
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveDocument(DocumentItem doc) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getRecentDocuments();

    // Check if item already exists by filePath
    final existingIndex = items.indexWhere((item) => item.filePath == doc.filePath);
    if (existingIndex >= 0) {
      // Update with new lastOpened time and size
      items[existingIndex] = doc.copyWith(
        id: items[existingIndex].id,
        lastOpened: DateTime.now(),
      );
    } else {
      items.insert(0, doc);
    }

    // Keep at most 100 recent documents
    final trimmed = items.take(100).toList();
    final encoded = jsonEncode(trimmed.map((e) => e.toMap()).toList());
    await prefs.setString(_recentDocsKey, encoded);
  }

  static Future<void> removeDocument(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getRecentDocuments();
    items.removeWhere((item) => item.id == id);
    final encoded = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_recentDocsKey, encoded);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentDocsKey);
  }

  static Future<bool> fileExistsOnDisk(String path) async {
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }
}
