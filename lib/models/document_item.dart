import 'package:flutter/material.dart';

enum DocumentType {
  pdf,
  word,
  excel,
  powerpoint,
  other,
}

class DocumentItem {
  final String id;
  final String filePath;
  final String fileName;
  final String extension;
  final int sizeInBytes;
  final DateTime lastOpened;

  DocumentItem({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.extension,
    required this.sizeInBytes,
    required this.lastOpened,
  });

  DocumentType get documentType {
    final ext = extension.toLowerCase().replaceAll('.', '');
    switch (ext) {
      case 'pdf':
        return DocumentType.pdf;
      case 'doc':
      case 'docx':
        return DocumentType.word;
      case 'xls':
      case 'xlsx':
        return DocumentType.excel;
      case 'ppt':
      case 'pptx':
        return DocumentType.powerpoint;
      default:
        return DocumentType.other;
    }
  }

  String get typeLabel {
    switch (documentType) {
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.word:
        return 'Word';
      case DocumentType.excel:
        return 'Excel';
      case DocumentType.powerpoint:
        return 'PowerPoint';
      case DocumentType.other:
        return extension.toUpperCase().replaceAll('.', '');
    }
  }

  Color get accentColor {
    switch (documentType) {
      case DocumentType.pdf:
        return const Color(0xFFE53935); // Crimson Red
      case DocumentType.word:
        return const Color(0xFF1E88E5); // Azure Blue
      case DocumentType.excel:
        return const Color(0xFF2E7D32); // Emerald Green
      case DocumentType.powerpoint:
        return const Color(0xFFE65100); // Deep Orange
      case DocumentType.other:
        return const Color(0xFF757575); // Slate Grey
    }
  }

  IconData get iconData {
    switch (documentType) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_rounded;
      case DocumentType.word:
        return Icons.description_rounded;
      case DocumentType.excel:
        return Icons.table_chart_rounded;
      case DocumentType.powerpoint:
        return Icons.slideshow_rounded;
      case DocumentType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  String get formattedSize {
    if (sizeInBytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = sizeInBytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(size < 10 && i > 0 ? 1 : 0)} ${suffixes[i]}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'extension': extension,
      'sizeInBytes': sizeInBytes,
      'lastOpened': lastOpened.toIso8601String(),
    };
  }

  factory DocumentItem.fromMap(Map<String, dynamic> map) {
    return DocumentItem(
      id: map['id'] as String? ?? UniqueKey().toString(),
      filePath: map['filePath'] as String? ?? '',
      fileName: map['fileName'] as String? ?? 'Untitled',
      extension: map['extension'] as String? ?? '',
      sizeInBytes: (map['sizeInBytes'] as num?)?.toInt() ?? 0,
      lastOpened: map['lastOpened'] != null
          ? DateTime.tryParse(map['lastOpened'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  DocumentItem copyWith({
    String? id,
    String? filePath,
    String? fileName,
    String? extension,
    int? sizeInBytes,
    DateTime? lastOpened,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      extension: extension ?? this.extension,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      lastOpened: lastOpened ?? this.lastOpened,
    );
  }
}
