import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document_item.dart';

class DocumentCard extends StatelessWidget {
  final DocumentItem document;
  final VoidCallback onTap;
  final VoidCallback onDetails;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onDetails,
    required this.onShare,
    required this.onDelete,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onDetails,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Type Icon Badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: document.accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: document.accentColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      document.iconData,
                      color: document.accentColor,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.fileName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: document.accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              document.typeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: document.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            document.formattedSize,
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '•',
                              style: TextStyle(color: secondaryTextColor, fontSize: 10),
                            ),
                          ),
                          Text(
                            _formatTimeAgo(document.lastOpened),
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing context actions
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                  tooltip: 'More actions',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'open':
                        onTap();
                        break;
                      case 'details':
                        onDetails();
                        break;
                      case 'share':
                        onShare();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'open',
                      child: Row(
                        children: [
                          Icon(Icons.launch_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Open'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Details'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text('Remove from Recents', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
