import 'package:flutter/material.dart';
import '../models/document_item.dart';
import '../services/document_service.dart';
import '../services/storage_service.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/document_card.dart';
import '../widgets/document_details_modal.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentItem> _recentDocs = [];
  bool _isLoading = true;
  bool _isPicking = false;

  String _searchQuery = '';
  DocumentType? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecents() async {
    setState(() => _isLoading = true);
    final docs = await StorageService.getRecentDocuments();
    if (mounted) {
      setState(() {
        _recentDocs = docs;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndOpen() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final doc = await DocumentService.pickDocument();
      if (doc != null) {
        await _loadRecents();
        if (mounted) {
          await _openDoc(doc);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking document: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  Future<void> _openDoc(DocumentItem doc) async {
    final result = await DocumentService.openDocument(doc);

    if (!mounted) return;

    // Refresh list to update lastOpened timestamp
    await _loadRecents();

    if (result.status == DocumentOpenStatus.success) {
      // Opened smoothly in native reader
      return;
    }

    if (result.status == DocumentOpenStatus.noAppAvailable) {
      _showNoAppDialog(doc, result.suggestedApp);
    } else if (result.status == DocumentOpenStatus.fileNotFound) {
      _showFileNotFoundDialog(doc);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showNoAppDialog(DocumentItem doc, String? suggestedApp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: doc.accentColor),
            const SizedBox(width: 10),
            const Text('Viewer App Needed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No application on this device can directly open ${doc.typeLabel} (.${doc.extension}) files.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            if (suggestedApp != null) ...[
              const SizedBox(height: 14),
              Text(
                'Recommended to install: $suggestedApp from your app store.',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFileNotFoundDialog(DocumentItem doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('File Not Found'),
        content: Text('The file "${doc.fileName}" is no longer at ${doc.filePath}. Would you like to remove it from recents?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.removeDocument(doc.id);
              await _loadRecents();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Recents?'),
        content: const Text('This will clear the history of recently opened documents. Your actual files will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAll();
      await _loadRecents();
    }
  }

  List<DocumentItem> get _filteredDocs {
    return _recentDocs.where((doc) {
      // Category filter
      if (_selectedCategory != null && doc.documentType != _selectedCategory) {
        return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return doc.fileName.toLowerCase().contains(query) ||
            doc.extension.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final filteredList = _filteredDocs;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFF2563EB),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('DocReader'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: widget.onToggleTheme,
          ),
          if (_recentDocs.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (val) {
                if (val == 'clear') _confirmClearAll();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_rounded, size: 18, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Clear History', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecents,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Hero Action Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick Pick Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                              : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Local Document Reader',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: primaryTextColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${_recentDocs.length} recents',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Open and view local PDF, Word (docx), Excel (xlsx), and PowerPoint (pptx) files smoothly.',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isPicking ? null : _pickAndOpen,
                              icon: _isPicking
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.file_open_rounded, size: 20),
                              label: Text(_isPicking ? 'Selecting file...' : 'Pick Document to Read'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_recentDocs.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      // Search bar
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search recent documents...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CategoryFilterChip(
                              label: 'All (${_recentDocs.length})',
                              isSelected: _selectedCategory == null,
                              onSelected: () => setState(() => _selectedCategory = null),
                            ),
                            const SizedBox(width: 8),
                            CategoryFilterChip(
                              label: 'PDF',
                              icon: Icons.picture_as_pdf_rounded,
                              activeColor: const Color(0xFFE53935),
                              isSelected: _selectedCategory == DocumentType.pdf,
                              onSelected: () => setState(() {
                                _selectedCategory = _selectedCategory == DocumentType.pdf
                                    ? null
                                    : DocumentType.pdf;
                              }),
                            ),
                            const SizedBox(width: 8),
                            CategoryFilterChip(
                              label: 'Word',
                              icon: Icons.description_rounded,
                              activeColor: const Color(0xFF1E88E5),
                              isSelected: _selectedCategory == DocumentType.word,
                              onSelected: () => setState(() {
                                _selectedCategory = _selectedCategory == DocumentType.word
                                    ? null
                                    : DocumentType.word;
                              }),
                            ),
                            const SizedBox(width: 8),
                            CategoryFilterChip(
                              label: 'Excel',
                              icon: Icons.table_chart_rounded,
                              activeColor: const Color(0xFF2E7D32),
                              isSelected: _selectedCategory == DocumentType.excel,
                              onSelected: () => setState(() {
                                _selectedCategory = _selectedCategory == DocumentType.excel
                                    ? null
                                    : DocumentType.excel;
                              }),
                            ),
                            const SizedBox(width: 8),
                            CategoryFilterChip(
                              label: 'PowerPoint',
                              icon: Icons.slideshow_rounded,
                              activeColor: const Color(0xFFE65100),
                              isSelected: _selectedCategory == DocumentType.powerpoint,
                              onSelected: () => setState(() {
                                _selectedCategory = _selectedCategory == DocumentType.powerpoint
                                    ? null
                                    : DocumentType.powerpoint;
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RECENT DOCUMENTS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: secondaryTextColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            '${filteredList.length} files',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Document List or Empty State
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_recentDocs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(onPickFile: _pickAndOpen),
              )
            else if (filteredList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  onPickFile: _pickAndOpen,
                  isFiltering: true,
                  activeFilterName: _selectedCategory != null
                      ? _selectedCategory.toString().split('.').last.toUpperCase()
                      : null,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = filteredList[index];
                      return DocumentCard(
                        key: ValueKey(doc.id),
                        document: doc,
                        onTap: () => _openDoc(doc),
                        onDetails: () => DocumentDetailsModal.show(
                          context,
                          document: doc,
                          onOpen: () => _openDoc(doc),
                          onShare: () => DocumentService.shareDocument(doc),
                          onDelete: () async {
                            await StorageService.removeDocument(doc.id);
                            await _loadRecents();
                          },
                        ),
                        onShare: () => DocumentService.shareDocument(doc),
                        onDelete: () async {
                          await StorageService.removeDocument(doc.id);
                          await _loadRecents();
                        },
                      );
                    },
                    childCount: filteredList.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}
