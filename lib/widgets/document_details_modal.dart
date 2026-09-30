import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document_item.dart';
import '../services/document_service.dart';

class DocumentDetailsModal extends StatelessWidget {
  final DocumentItem document;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const DocumentDetailsModal({
    super.key,
    required this.document,
    required this.onOpen,
    required this.onDelete,
    required this.onShare,
  });

  static void show(
    BuildContext context, {
    required DocumentItem document,
    required VoidCallback onOpen,
    required VoidCallback onDelete,
    required VoidCallback onShare,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DocumentDetailsModal(
        document: document,
        onOpen: onOpen,
        onDelete: onDelete,
        onShare: onShare,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // File icon & Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: document.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: document.accentColor.withOpacity(0.25),
                  ),
                ),
                child: Icon(
                  document.iconData,
                  color: document.accentColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.fileName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: document.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        document.typeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: document.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Metadata properties
          _buildInfoRow(
            context,
            icon: Icons.data_usage_rounded,
            title: 'File Size',
            value: document.formattedSize,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.history_rounded,
            title: 'Last Opened',
            value: dateFormat.format(document.lastOpened),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.folder_open_rounded,
            title: 'Path',
            value: document.filePath,
            isMonospace: true,
          ),

          const SizedBox(height: 28),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onOpen();
                  },
                  icon: const Icon(Icons.chrome_reader_mode_rounded, size: 20),
                  label: const Text('Open File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: document.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: () {
                  Navigator.pop(context);
                  onShare();
                },
                tooltip: 'Share Document',
                icon: const Icon(Icons.share_rounded, size: 20),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
                tooltip: 'Remove from Recents',
                style: IconButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isMonospace = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: secondaryColor),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: secondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: isMonospace ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }
}
