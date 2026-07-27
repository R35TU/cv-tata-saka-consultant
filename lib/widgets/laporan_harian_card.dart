import 'package:flutter/material.dart';

/// Reusable card for an individual daily report entry.
/// Shows a document icon, report title, and creation timestamp.
class LaporanHarianCard extends StatelessWidget {
  final String title;
  final String createdAt; // e.g. "04 Januari 2025 - 10:48"
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  const LaporanHarianCard({
    super.key,
    required this.title,
    required this.createdAt,
    this.iconColor = const Color(0xFF0D47A1),
    this.iconBackgroundColor = const Color(0xFFE8F0FE),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFE8EAED), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Document icon box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                Icons.description_outlined,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dibuat : $createdAt',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFA0A0A0),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
