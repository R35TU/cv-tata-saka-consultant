import 'package:flutter/material.dart';

class FolderItem extends StatefulWidget {
  final String folderName;
  final int fileCount;
  final List<String> files;

  const FolderItem({
    super.key,
    required this.folderName,
    required this.fileCount,
    required this.files,
  });

  @override
  State<FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<FolderItem> {
  bool _isExpanded = false;

  IconData _getFileIcon(String filename) {
    if (filename.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (filename.toLowerCase().endsWith('.txt')) {
      return Icons.description_rounded;
    } else {
      return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileIconColor(String filename) {
    if (filename.toLowerCase().endsWith('.pdf')) {
      return const Color(0xFFEF5350); // Red for PDF
    } else if (filename.toLowerCase().endsWith('.txt')) {
      return const Color(0xFFFFB300); // Amber for TXT
    } else {
      return const Color(0xFF78909C); // Blue grey for others
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFF0F1F5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x03000000),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Ensures folder background color transitions clip cleanly
      child: Column(
        children: [
          // 1. Folder Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              color: _isExpanded ? const Color(0xFFE5EAFF) : const Color(0xFFF5F6F8), // Active light blue or light grey
              child: Row(
                children: [
                  // Folder Icon
                  const Icon(
                    Icons.folder_rounded,
                    color: Color(0xFFFFC107), // Yellow folder color
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  
                  // Folder Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.folderName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.fileCount} File',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF8E8E93),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Chevron icon
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
                    color: const Color(0xFF1E1E1E),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          
          // 2. Files List (Visible when expanded)
          if (_isExpanded && widget.files.isNotEmpty)
            Container(
              color: Colors.white,
              child: Column(
                children: List.generate(widget.files.length, (index) {
                  final filename = widget.files[index];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            // File Icon
                            Icon(
                              _getFileIcon(filename),
                              color: _getFileIconColor(filename),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            
                            // Filename
                            Expanded(
                              child: Text(
                                filename,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider line between files, but not after the last file
                      if (index < widget.files.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF0F1F5),
                          indent: 16.0,
                          endIndent: 16.0,
                        ),
                    ],
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
