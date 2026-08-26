import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectCard extends StatelessWidget {
  final String projectId;
  final String title;
  final String location;
  final String status; // "Progres" or "Selesai"
  final String imageUrl;
  final double physicalProgress; // Unused for Activity, kept for backward compatibility if needed
  final double financialProgress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    this.projectId = '',
    required this.title,
    required this.location,
    required this.status,
    this.physicalProgress = 0.0,
    this.financialProgress = 0.0,
    required this.imageUrl,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status.toLowerCase() == 'selesai';
    
    // Status color mapping
    final Color badgeDotColor = isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);
    final Color badgeBgColor = isCompleted ? const Color(0xFFE5EAFF) : const Color(0xFFE8F9EE);
    final Color badgeTextColor = isCompleted ? const Color(0xFF001AFF) : const Color(0xFF00C853);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          context.push('/projects/$projectId');
        },
        onLongPressStart: (details) async {
          if (onEdit == null && onDelete == null) return;
          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
          
          final value = await showMenu<String>(
            context: context,
            position: RelativeRect.fromRect(
              details.globalPosition & const Size(40, 40),
              Offset.zero & overlay.size,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            items: [
              if (onEdit != null)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: const [
                      Icon(Icons.edit_rounded, color: Color(0xFF1E1E1E), size: 18),
                      SizedBox(width: 8),
                      Text('Edit Kontrak', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF1E1E1E))),
                    ],
                  ),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: const [
                      Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3D00), size: 18),
                      SizedBox(width: 8),
                      Text('Hapus Kontrak', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFFFF3D00))),
                    ],
                  ),
                ),
            ],
          );
          
          if (value == 'edit') onEdit?.call();
          if (value == 'delete') onDelete?.call();
        },
        child: Container(
        margin: const EdgeInsets.only(bottom: 18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFF0F1F5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x04000000), // Very subtle shadow
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Details
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1E1E),
                      fontFamily: 'Inter',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFA0A0A0),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: badgeDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
