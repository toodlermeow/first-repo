import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../models/document_item.dart';
import 'storage_service.dart';

enum DocumentOpenStatus {
  success,
  noAppAvailable,
  fileNotFound,
  permissionDenied,
  cancelled,
  error,
}

class DocumentOpenResult {
  final DocumentOpenStatus status;
  final String message;
  final String? suggestedApp;

  DocumentOpenResult({
    required this.status,
    required this.message,
    this.suggestedApp,
  });
}

class DocumentService {
  static const List<String> supportedExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
  ];

  /// Opens the native system file picker to select supported documents.
  static Future<DocumentItem?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final platformFile = result.files.single;
      final path = platformFile.path;
      if (path == null) {
        return null;
      }

      final file = File(path);
      final exists = await file.exists();
      final size = exists ? await file.length() : platformFile.size;
      final fileName = platformFile.name;
      final ext = p.extension(path).replaceFirst('.', '').toLowerCase();

      final doc = DocumentItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: path,
        fileName: fileName,
        extension: ext.isNotEmpty ? ext : (platformFile.extension ?? ''),
        sizeInBytes: size,
        lastOpened: DateTime.now(),
      );

      // Save to recents
      await StorageService.saveDocument(doc);
      return doc;
    } catch (e) {
      rethrow;
    }
  }

  /// Opens a document by its file path using native viewer/intents.
  static Future<DocumentOpenResult> openDocument(DocumentItem doc) async {
    try {
      final file = File(doc.filePath);
      if (!await file.exists()) {
        return DocumentOpenResult(
          status: DocumentOpenStatus.fileNotFound,
          message: 'The file "${doc.fileName}" could not be found at its original location. It may have been moved or deleted.',
        );
      }

      // Update last opened timestamp in storage
      await StorageService.saveDocument(doc.copyWith(lastOpened: DateTime.now()));

      // Launch file using native intents/viewers
      final result = await OpenFilex.open(doc.filePath);

      switch (result.type) {
        case ResultType.done:
          return DocumentOpenResult(
            status: DocumentOpenStatus.success,
            message: 'Document opened successfully.',
          );

        case ResultType.noAppToOpen:
          final suggestion = _getSuggestedApp(doc.documentType);
          return DocumentOpenResult(
            status: DocumentOpenStatus.noAppAvailable,
            message: 'No compatible app was found on your device to open ${doc.typeLabel} files.',
            suggestedApp: suggestion,
          );

        case ResultType.fileNotFound:
          return DocumentOpenResult(
            status: DocumentOpenStatus.fileNotFound,
            message: 'File not found on device.',
          );

        case ResultType.permissionDenied:
          return DocumentOpenResult(
            status: DocumentOpenStatus.permissionDenied,
            message: 'Permission denied to read this file. Please grant file access in Settings.',
          );

        case ResultType.error:
        default:
          return DocumentOpenResult(
            status: DocumentOpenStatus.error,
            message: result.message.isNotEmpty
                ? result.message
                : 'Failed to open file. Please ensure a compatible viewer is installed.',
          );
      }
    } catch (e) {
      return DocumentOpenResult(
        status: DocumentOpenStatus.error,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Shares the document via native share sheet.
  static Future<void> shareDocument(DocumentItem doc) async {
    final file = File(doc.filePath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(doc.filePath)],
        subject: doc.fileName,
        text: 'Document: ${doc.fileName}',
      );
    }
  }

  static String _getSuggestedApp(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return 'Adobe Acrobat Reader, Google Drive, or Google PDF Viewer';
      case DocumentType.word:
        return 'Microsoft Word, Google Docs, or WPS Office';
      case DocumentType.excel:
        return 'Microsoft Excel, Google Sheets, or WPS Office';
      case DocumentType.powerpoint:
        return 'Microsoft PowerPoint, Google Slides, or WPS Office';
      case DocumentType.other:
        return 'a compatible viewer app';
    }
  }
}
