import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onPickFile;
  final bool isFiltering;
  final String? activeFilterName;

  const EmptyState({
    super.key,
    required this.onPickFile,
    this.isFiltering = false,
    this.activeFilterName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (isFiltering) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 36,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                activeFilterName != null
                    ? 'No $activeFilterName documents'
                    : 'No documents match your query',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting another category or pick a new document from your storage.',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Minimalist icon cluster
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  Icons.folder_open_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'No documents opened yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a local document from your storage to start reading. Your recently opened files will appear here.',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Supported format badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildFormatBadge(context, 'PDF', const Color(0xFFE53935)),
                _buildFormatBadge(context, 'DOCX', const Color(0xFF1E88E5)),
                _buildFormatBadge(context, 'XLSX', const Color(0xFF2E7D32)),
                _buildFormatBadge(context, 'PPTX', const Color(0xFFE65100)),
              ],
            ),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: onPickFile,
              icon: const Icon(Icons.file_upload_outlined, size: 20),
              label: const Text('Pick Document'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
